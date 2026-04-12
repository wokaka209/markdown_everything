# MarkItDown Environment Manager
# 智能环境管理器 - 自动检测并设置 Python/Conda 环境
# 流程: Python检测 -> Conda检测 -> 虚拟环境创建 -> 依赖安装

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("check", "setup", "run", "convert", "help")]
    [string]$Command = "help",

    [Parameter(Mandatory=$false)]
    [ValidateSet("conda", "venv", "auto")]
    [string]$EnvironmentType = "auto",

    [Parameter(Mandatory=$false)]
    [ValidateSet("default", "tsinghua", "aliyun", "douban", "custom")]
    [string]$Mirror = "default",

    [Parameter(Mandatory=$false)]
    [string]$CustomMirror,

    [Parameter(Mandatory=$false)]
    [string[]]$RunCommand,

    [Parameter(Mandatory=$false)]
    [string]$InputFile,

    [Parameter(Mandatory=$false)]
    [string]$OutputDir
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFile = Join-Path $ScriptDir "environment.log"
$VenvDir = Join-Path $ScriptDir ".venv"

$script:PipTimeout = 120
$script:PipRetries = 3

$script:IsWindows = $PSVersionTable.Platform -eq 'Win32NT' -or $null -eq $PSVersionTable.Platform
$script:IsLinux = $PSVersionTable.Platform -eq 'Unix' -and (Test-Path "/proc/version")
$script:IsMacOS = $PSVersionTable.Platform -eq 'Unix' -and (Test-Path "/System/Library/CoreServices/SystemVersion.plist")

if ($script:IsWindows) {
    $script:DefaultCondaPaths = @(
        "$env:USERPROFILE\.conda",
        "$env:USERPROFILE\Anaconda3",
        "$env:USERPROFILE\Miniconda3",
        "C:\.conda",
        "C:\Anaconda3",
        "C:\Miniconda3"
    )
} else {
    $script:DefaultCondaPaths = @(
        "$HOME/.conda",
        "$HOME/anaconda3",
        "$HOME/miniconda3",
        "/opt/anaconda3",
        "/opt/miniconda3"
    )
}

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )

    $colors = @{
        "INFO" = "Cyan"
        "SUCCESS" = "Green"
        "WARNING" = "Yellow"
        "ERROR" = "Red"
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = $colors[$Level]
    $logMessage = "[$timestamp] [$Level] $Message"

    Write-Host $logMessage -ForegroundColor $color
    Add-Content -Path $LogFile -Value $logMessage -Encoding UTF8
}

function Get-OperatingSystem {
    if ($script:IsWindows) { return "Windows" }
    elseif ($script:IsMacOS) { return "macOS" }
    elseif ($script:IsLinux) { return "Linux" }
    else { return "Unknown" }
}

function Test-PythonVersion {
    try {
        $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
        if (-not $pythonCmd) {
            return $null
        }

        $versionOutput = python --version 2>&1
        if ($versionOutput -match 'Python (\d+)\.(\d+)\.(\d+)') {
            $major = [int]$Matches[1]
            $minor = [int]$Matches[2]
            $patch = [int]$Matches[3]

            $fullVersion = "$major.$minor.$patch"

            if ($major -gt 3 -or ($major -eq 3 -and $minor -gt 11)) {
                Write-Log "Python 版本: $fullVersion (满足要求 >= 3.11)" "SUCCESS"
                return @{
                    Available = $true
                    Version = $fullVersion
                    Major = $major
                    Minor = $minor
                    Patch = $patch
                }
            } elseif ($major -eq 3 -and $minor -eq 11) {
                Write-Log "Python 版本: $fullVersion (满足要求 >= 3.11)" "SUCCESS"
                return @{
                    Available = $true
                    Version = $fullVersion
                    Major = $major
                    Minor = $minor
                    Patch = $patch
                }
            } else {
                Write-Log "Python 版本过低: $fullVersion (需要 >= 3.11)" "ERROR"
                return @{
                    Available = $true
                    Version = $fullVersion
                    MeetsRequirement = $false
                }
            }
        }
    } catch {
    }

    return $null
}

function Test-CondaAvailable {
    try {
        $condaCmd = Get-Command conda -ErrorAction SilentlyContinue
        if (-not $condaCmd) {
            foreach ($basePath in $script:DefaultCondaPaths) {
                $condaPath = Join-Path $basePath "condabin" "conda.bat"
                if ($script:IsWindows) {
                    $condaPath = Join-Path $basePath "conda.bat"
                }

                if (Test-Path $condaPath) {
                    $version = & $condaPath --version 2>&1
                    Write-Log "找到 Conda: $version" "SUCCESS"
                    return $condaPath
                }
            }
            return $null
        }

        $version = conda --version 2>&1
        Write-Log "找到 Conda: $version" "SUCCESS"
        return $condaCmd.Source
    } catch {
        return $null
    }
}

function Test-CondaEnvironmentExists {
    param([string]$EnvName)

    try {
        $envList = conda env list 2>&1 | Out-String
        $pattern = "(^|\s)${EnvName}(\s|$)"
        if ($envList -imatch $pattern) {
            return $true
        }
    } catch {
    }

    return $false
}

function Get-PythonExePath {
    param([string]$EnvName)

    foreach ($basePath in $script:DefaultCondaPaths) {
        if ($script:IsWindows) {
            $pythonPath = Join-Path $basePath "envs" $EnvName "Scripts" "python.exe"
        } else {
            $pythonPath = Join-Path $basePath "envs" $EnvName "bin" "python"
        }

        if (Test-Path $pythonPath) {
            return $pythonPath
        }
    }

    return $null
}

function Get-VenvPythonExe {
    if ($script:IsWindows) {
        return Join-Path $VenvDir "Scripts" "python.exe"
    } else {
        return Join-Path $VenvDir "bin" "python"
    }
}

function Get-PipMirrorIndex {
    param([string]$MirrorType, [string]$CustomIndex)

    switch ($MirrorType) {
        "tsinghua" { return "https://pypi.tuna.tsinghua.edu.cn/simple" }
        "aliyun" { return "https://mirrors.aliyun.com/pypi/simple/" }
        "douban" { return "https://pypi.doubanio.com/simple/" }
        "custom" { return $CustomIndex }
        default { return $null }
    }
}

function Install-Package {
    param(
        [string]$PythonExe,
        [string]$Package,
        [string]$MirrorType,
        [string]$CustomMirror
    )

    Write-Log "安装 $Package..." "INFO"
    Write-Log "使用镜像: $MirrorType" "INFO"

    $mirrorIndex = Get-PipMirrorIndex -MirrorType $MirrorType -CustomIndex $CustomMirror
    $installArgs = @("-m", "pip", "install", "--no-cache-dir", $Package)

    if ($mirrorIndex) {
        $trustedHost = $mirrorIndex -replace 'https?://', '' -replace '/simple.*$', ''
        $installArgs += @("-i", $mirrorIndex, "--trusted-host", $trustedHost)
    }

    $attempt = 0
    $success = $false

    while ($attempt -lt $script:PipRetries -and -not $success) {
        $attempt++
        if ($attempt -gt 1) {
            $waitTime = [math]::Pow(2, $attempt - 1)
            Write-Log "重试 $attempt/$($script:PipRetries)，等待 $waitTime 秒..." "WARNING"
            Start-Sleep -Seconds $waitTime
        }

        try {
            & $PythonExe @installArgs 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
                Write-Log "$Package 安装成功" "SUCCESS"
                $success = $true
            } else {
                Write-Log "安装尝试 $attempt 失败" "WARNING"
            }
        } catch {
            Write-Log "安装尝试 $attempt 失败: $_" "WARNING"
        }
    }

    if (-not $success) {
        Write-Log "$Package 安装失败" "ERROR"
        return $false
    }

    return $true
}

function New-VenvEnvironment {
    param([string]$PythonExe)

    Write-Log "创建虚拟环境..." "INFO"

    if (Test-Path $VenvDir) {
        Write-Log "虚拟环境已存在: $VenvDir" "INFO"
        return $true
    }

    try {
        & $PythonExe -m venv $VenvDir 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Log "虚拟环境创建成功: $VenvDir" "SUCCESS"
            return $true
        } else {
            Write-Log "虚拟环境创建失败" "ERROR"
            return $false
        }
    } catch {
        Write-Log "虚拟环境创建失败: $_" "ERROR"
        return $false
    }
}

function Setup-WithConda {
    $condaPath = Test-CondaAvailable
    if (-not $condaPath) {
        return $false
    }

    $envName = "markitdown"
    $envExists = Test-CondaEnvironmentExists -EnvName $envName

    if ($envExists) {
        Write-Log "Conda 环境 '$envName' 已存在" "INFO"
        $pythonExe = Get-PythonExePath -EnvName $envName
        if ($pythonExe) {
            if (Install-Package -PythonExe $pythonExe -Package 'markitdown[all]' -MirrorType $Mirror -CustomMirror $CustomMirror) {
                Write-Log "Conda 环境设置完成" "SUCCESS"
                return $true
            }
        }
    } else {
        Write-Log "创建 Conda 环境..." "INFO"
        try {
            conda create -n $envName python=3.11 -y 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
                Write-Log "Conda 环境创建成功" "SUCCESS"
                $pythonExe = Get-PythonExePath -EnvName $envName
                if ($pythonExe) {
                    if (Install-Package -PythonExe $pythonExe -Package 'markitdown[all]' -MirrorType $Mirror -CustomMirror $CustomMirror) {
                        Write-Log "Conda 环境设置完成" "SUCCESS"
                        return $true
                    }
                }
            }
        } catch {
            Write-Log "Conda 环境创建失败: $_" "ERROR"
        }
    }

    return $false
}

function Setup-WithVenv {
    $pythonInfo = Test-PythonVersion
    if (-not $pythonInfo -or -not $pythonInfo.Available) {
        Write-Log "Python 不可用" "ERROR"
        return $false
    }

    if ($pythonInfo.MeetsRequirement -eq $false) {
        Write-Log "Python 版本不满足要求 (需要 >= 3.11)" "ERROR"
        return $false
    }

    $pythonExe = (Get-Command python).Source

    if (Test-Path $VenvDir) {
        Write-Log "虚拟环境已存在: $VenvDir" "INFO"
    } else {
        if (-not (New-VenvEnvironment -PythonExe $pythonExe)) {
            return $false
        }
    }

    $venvPython = Get-VenvPythonExe
    if (Install-Package -PythonExe $venvPython -Package 'markitdown[all]' -MirrorType $Mirror -CustomMirror $CustomMirror) {
        Write-Log "虚拟环境设置完成" "SUCCESS"
        return $true
    }

    return $false
}

function Setup-Environment {
    Write-Log "======================================" "INFO"
    Write-Log "环境检测开始" "INFO"
    Write-Log "======================================" "INFO"

    Write-Log "" "INFO"
    Write-Log "步骤 1: 检测 Python 环境" "INFO"
    $pythonInfo = Test-PythonVersion
    if (-not $pythonInfo) {
        Write-Log "未找到 Python，请先安装 Python 3.11+" "ERROR"
        Write-Log "下载地址: https://www.python.org/downloads/" "INFO"
        return $false
    }

    if ($pythonInfo.MeetsRequirement -eq $false) {
        Write-Log "Python 版本过低: $($pythonInfo.Version)，需要 >= 3.11" "ERROR"
        Write-Log "请升级 Python: https://www.python.org/downloads/" "INFO"
        return $false
    }

    Write-Log "" "INFO"
    Write-Log "步骤 2: 检测 Conda 环境" "INFO"
    $condaPath = Test-CondaAvailable

    if ($condaPath) {
        Write-Log "Conda 可用" "INFO"
        if ($EnvironmentType -eq "venv") {
            Write-Log "用户指定使用 venv，将跳过 Conda" "WARNING"
        } else {
            Write-Log "使用 Conda 环境" "INFO"
            if (Setup-WithConda) {
                return $true
            }
            Write-Log "Conda 设置失败，尝试使用 venv..." "WARNING"
        }
    } else {
        Write-Log "Conda 不可用" "INFO"
    }

    if ($EnvironmentType -eq "conda") {
        Write-Log "用户指定使用 Conda，但 Conda 不可用" "ERROR"
        return $false
    }

    Write-Log "" "INFO"
    Write-Log "步骤 3: 创建虚拟环境 (venv)" "INFO"
    if (Setup-WithVenv) {
        return $true
    }

    return $false
}

function Get-EnvironmentPython {
    $condaPath = Test-CondaAvailable

    if ($condaPath) {
        $envName = "markitdown"
        if (Test-CondaEnvironmentExists -EnvName $envName) {
            $pythonExe = Get-PythonExePath -EnvName $envName
            if ($pythonExe) {
                return $pythonExe
            }
        }
    }

    if (Test-Path $VenvDir) {
        $venvPython = Get-VenvPythonExe
        if (Test-Path $venvPython) {
            return $venvPython
        }
    }

    return $null
}

function Invoke-RunCommand {
    param([string[]]$Command)

    if ($null -eq $Command -or $Command.Count -eq 0) {
        Write-Log "请指定要运行的命令" "ERROR"
        return $false
    }

    $pythonExe = Get-EnvironmentPython
    if (-not $pythonExe) {
        Write-Log "未找到可用的 Python 环境" "ERROR"
        Write-Log "请先运行 setup 命令设置环境" "INFO"
        return $false
    }

    Write-Log "使用 Python: $pythonExe" "INFO"
    Write-Log "运行命令: $($Command -join ' ')" "INFO"

    try {
        $originalDir = Get-Location
        Set-Location $ScriptDir
        & $pythonExe $Command
        Set-Location $originalDir
        return $?
    } catch {
        Write-Log "命令执行失败: $_" "ERROR"
        return $false
    }
}

function Convert-Document {
    param([string]$InputPath, [string]$OutputPath)

    if (-not $InputPath) {
        Write-Log "请提供输入文件路径" "ERROR"
        return $false
    }

    if (-not (Test-Path $InputPath)) {
        Write-Log "输入文件不存在: $InputPath" "ERROR"
        return $false
    }

    $resolvedInput = Resolve-Path $InputPath
    $inputBaseName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedInput)

    if ($OutputPath) {
        if (-not (Test-Path $OutputPath)) {
            try {
                New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
                Write-Log "创建输出目录: $OutputPath" "INFO"
            } catch {
                Write-Log "创建输出目录失败: $_" "ERROR"
                return $false
            }
        }
        $resolvedOutput = Resolve-Path $OutputPath
        $outputFile = Join-Path $resolvedOutput "$inputBaseName.md"
    } else {
        $outputFile = Join-Path (Get-Location) "$inputBaseName.md"
        $OutputPath = Get-Location
    }

    Write-Log "转换文档..." "INFO"
    Write-Log "  输入: $resolvedInput" "INFO"
    Write-Log "  输出: $outputFile" "INFO"

    $pythonExe = Get-EnvironmentPython
    if (-not $pythonExe) {
        Write-Log "未找到可用的 Python 环境" "ERROR"
        return $false
    }

    Write-Log "使用 Python: $pythonExe" "INFO"

    try {
        $originalDir = Get-Location
        Set-Location $ScriptDir
        & $pythonExe "convert_document.py" $resolvedInput -o $outputFile 2>&1 | Out-Null
        Set-Location $originalDir

        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Log "文档转换成功: $outputFile" "SUCCESS"
            return $true
        } else {
            Write-Log "文档转换失败" "ERROR"
            return $false
        }
    } catch {
        Write-Log "文档转换失败: $_" "ERROR"
        return $false
    }
}

function Show-Help {
    $os = Get-OperatingSystem
    Write-Host @"

================================================================================
MarkItDown 环境管理器 - 智能环境检测与设置
================================================================================

平台: $os

用法: manage_environment.ps1 -Command <命令> [选项]

--------------------------------------------------------------------------------
环境检测流程:
--------------------------------------------------------------------------------
  步骤 1: 检测 Python >= 3.11
  步骤 2: 检测 Conda 环境
  步骤 3: 如无 Conda，创建 venv 虚拟环境
  步骤 4: 安装 markitdown[all]

--------------------------------------------------------------------------------
命令:
--------------------------------------------------------------------------------
    check              检查环境状态
    setup             自动设置环境（推荐）
    run <命令>         运行命令
    convert           转换文档
    help              显示帮助

--------------------------------------------------------------------------------
选项:
--------------------------------------------------------------------------------
    -EnvironmentType   环境类型:
                      - auto:   自动选择（默认，优先 Conda）
                      - conda:  强制使用 Conda
                      - venv:   强制使用 venv
    -Mirror <镜像源>  pip 镜像源:
                      - default:   官方 PyPI
                      - tsinghua:  清华大学镜像
                      - aliyun:    阿里云镜像（推荐）
                      - douban:    豆瓣镜像
                      - custom:    使用 -CustomMirror 指定
    -CustomMirror <URL> 自定义镜像地址

--------------------------------------------------------------------------------
使用示例:
--------------------------------------------------------------------------------
    # 检查环境
    .\manage_environment.ps1 -Command check

    # 自动设置环境（使用默认源）
    .\manage_environment.ps1 -Command setup

    # 使用阿里云镜像设置环境
    .\manage_environment.ps1 -Command setup -Mirror aliyun

    # 强制使用 venv
    .\manage_environment.ps1 -Command setup -EnvironmentType venv

    # 运行脚本
    .\manage_environment.ps1 -Command run -RunCommand @("python", "--version")

    # 转换文档
    .\manage_environment.ps1 -Command convert -InputFile "doc.pdf" -OutputDir "C:\output"

--------------------------------------------------------------------------------
环境要求:
--------------------------------------------------------------------------------
    Python >= 3.11
    可选: Conda (Miniconda/Anaconda)
    网络: PyPI 或国内镜像

--------------------------------------------------------------------------------
环境信息:
--------------------------------------------------------------------------------
    Conda 环境: C:\Users\<用户>\.conda\envs\markitdown
    Venv 目录:  $VenvDir

================================================================================

"@
}

Write-Host ""
Write-Host "MarkItDown 环境管理器" -ForegroundColor Cyan
Write-Host "平台: $(Get-OperatingSystem)" -ForegroundColor Cyan
Write-Host ""

switch ($Command) {
    "check" {
        Write-Log "检测 Python 环境..." "INFO"
        $pythonInfo = Test-PythonVersion
        if (-not $pythonInfo) {
            Write-Log "未找到 Python" "ERROR"
        } elseif ($pythonInfo.MeetsRequirement -eq $false) {
            Write-Log "Python 版本不满足要求" "ERROR"
        }

        Write-Log "" "INFO"
        Write-Log "检测 Conda 环境..." "INFO"
        $condaPath = Test-CondaAvailable
        if ($condaPath) {
            Write-Log "Conda 可用" "SUCCESS"
        } else {
            Write-Log "Conda 不可用" "WARNING"
        }

        Write-Log "" "INFO"
        Write-Log "检测本地环境..." "INFO"
        $pythonExe = Get-EnvironmentPython
        if ($pythonExe) {
            Write-Log "已设置 Python: $pythonExe" "SUCCESS"
        } else {
            Write-Log "未设置环境，请运行 setup 命令" "WARNING"
        }
    }
    "setup" {
        $result = Setup-Environment
        if ($result) {
            Write-Log "" "INFO"
            Write-Log "环境设置完成！" "SUCCESS"
            exit 0
        } else {
            Write-Log "" "ERROR"
            Write-Log "环境设置失败" "ERROR"
            exit 1
        }
    }
    "run" {
        $result = Invoke-RunCommand -Command $RunCommand
        exit $(if ($result) { 0 } else { 1 })
    }
    "convert" {
        $result = Convert-Document -InputPath $InputFile -OutputPath $OutputDir
        exit $(if ($result) { 0 } else { 1 })
    }
    "help" {
        Show-Help
    }
}
