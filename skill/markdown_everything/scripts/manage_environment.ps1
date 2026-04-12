# MarkItDown Environment Manager
# 智能环境管理器 - 仅 Conda 环境检测与自动创建
# 流程: Conda检测 -> 环境检测 -> 自动创建 -> 依赖安装

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("check", "setup", "run", "convert", "help")]
    [string]$Command = "help",

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

$script:PipTimeout = 120
$script:PipRetries = 3
$script:EnvName = "markitdown"

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

function Test-CondaInstalled {
    Write-Log "======================================" "INFO"
    Write-Log "步骤 1: 检测 Conda 是否安装" "INFO"
    Write-Log "======================================" "INFO"

    try {
        $condaCmd = Get-Command conda -ErrorAction SilentlyContinue
        if ($condaCmd) {
            $version = conda --version 2>&1
            Write-Log "Conda 已安装: $version" "SUCCESS"
            return $condaCmd.Source
        }

        foreach ($basePath in $script:DefaultCondaPaths) {
            $condaBatPath = Join-Path $basePath "condabin" "conda.bat"
            $condaExePath = Join-Path $basePath "Scripts" "conda.exe"

            if ($script:IsWindows) {
                if (Test-Path $condaBatPath) {
                    $version = & $condaBatPath --version 2>&1
                    Write-Log "Conda 已安装: $version (路径: $basePath)" "SUCCESS"
                    return $condaBatPath
                }
                if (Test-Path $condaExePath) {
                    $version = & $condaExePath --version 2>&1
                    Write-Log "Conda 已安装: $version (路径: $basePath)" "SUCCESS"
                    return $condaExePath
                }
            } else {
                $condaBinPath = Join-Path $basePath "bin" "conda"
                if (Test-Path $condaBinPath) {
                    $version = & $condaBinPath --version 2>&1
                    Write-Log "Conda 已安装: $version (路径: $basePath)" "SUCCESS"
                    return $condaBinPath
                }
            }
        }

        Write-Log "系统未安装 Conda" "ERROR"
        Write-Log "请先安装 Miniconda 或 Anaconda" "INFO"
        Write-Log "下载链接: https://docs.conda.io/en/latest/miniconda.html" "INFO"
        return $null
    } catch {
        Write-Log "Conda 检测失败: $_" "ERROR"
        return $null
    }
}

function Test-CondaEnvironmentExists {
    param([string]$EnvName)

    Write-Log "检测 Conda 环境 '$EnvName'..." "INFO"

    try {
        $condaPath = Test-CondaInstalled
        if (-not $condaPath) {
            Write-Log "Conda 未安装，无法检测环境" "ERROR"
            return $false
        }

        $envList = conda env list 2>&1 | Out-String
        if ($envList -imatch "(^|\s)${EnvName}(\s|$)") {
            Write-Log "Conda 环境 '$EnvName' 已存在 ✓" "SUCCESS"
            return $true
        } else {
            Write-Log "Conda 环境 '$EnvName' 不存在，将自动创建" "INFO"
            return $false
        }
    } catch {
        Write-Log "环境检测失败: $_" "ERROR"
        return $false
    }
}

function New-CondaEnvironment {
    param([string]$EnvName)

    Write-Log "======================================" "INFO"
    Write-Log "步骤 2: 自动创建 Conda 环境" "INFO"
    Write-Log "======================================" "INFO"

    try {
        $condaPath = Test-CondaInstalled
        if (-not $condaPath) {
            Write-Log "无法创建环境: Conda 未安装" "ERROR"
            return $false
        }

        Write-Log "正在创建 Conda 环境 '$EnvName' (python=3.11)..." "INFO"
        $output = conda create -n $EnvName python=3.11 -y 2>&1
        $outputStr = $output | Out-String

        if ($LASTEXITCODE -eq 0 -or $outputStr -match "To activate this environment") {
            Write-Log "Conda 环境 '$EnvName' 创建成功 ✓" "SUCCESS"
            return $true
        } else {
            Write-Log "Conda 环境创建失败: $outputStr" "ERROR"
            return $false
        }
    } catch {
        Write-Log "Conda 环境创建失败: $_" "ERROR"
        return $false
    }
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

    Write-Log "======================================" "INFO"
    Write-Log "步骤 3: 安装依赖包" "INFO"
    Write-Log "======================================" "INFO"
    Write-Log "安装 $Package..." "INFO"
    Write-Log "使用镜像: $MirrorType" "INFO"

    $mirrorIndex = Get-PipMirrorIndex -MirrorType $MirrorType -CustomIndex $CustomMirror
    $installArgs = @("-m", "pip", "install", "--no-cache-dir", "--timeout", $script:PipTimeout, $Package)

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
            Write-Log "安装尝试 $attempt..." "INFO"
            & $PythonExe @installArgs 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
                Write-Log "$Package 安装成功 ✓" "SUCCESS"
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

function Setup-Environment {
    $envName = $script:EnvName
    $condaPath = Test-CondaInstalled

    if (-not $condaPath) {
        Write-Log "Conda 未安装，无法继续" "ERROR"
        return $false
    }

    Write-Log "======================================" "INFO"
    Write-Log "环境设置开始" "INFO"
    Write-Log "目标环境: $envName" "INFO"
    Write-Log "======================================" "INFO"

    $envExists = Test-CondaEnvironmentExists -EnvName $envName

    if ($envExists) {
        Write-Log "使用现有 Conda 环境" "INFO"
        $pythonExe = Get-PythonExePath -EnvName $envName
        if ($pythonExe) {
            if (Install-Package -PythonExe $pythonExe -Package 'markitdown[all]' -MirrorType $Mirror -CustomMirror $CustomMirror) {
                Write-Log "依赖安装完成 ✓" "SUCCESS"
                return $true
            }
        }
    } else {
        if (New-CondaEnvironment -EnvName $envName) {
            $pythonExe = Get-PythonExePath -EnvName $envName
            if ($pythonExe) {
                if (Install-Package -PythonExe $pythonExe -Package 'markitdown[all]' -MirrorType $Mirror -CustomMirror $CustomMirror) {
                    Write-Log "环境设置完成 ✓" "SUCCESS"
                    return $true
                }
            }
        }
    }

    return $false
}

function Get-EnvironmentPython {
    $condaPath = Test-CondaInstalled

    if ($condaPath) {
        $envName = $script:EnvName
        if (Test-CondaEnvironmentExists -EnvName $envName) {
            $pythonExe = Get-PythonExePath -EnvName $envName
            if ($pythonExe) {
                Write-Log "使用 Conda Python: $pythonExe" "INFO"
                return $pythonExe
            }
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

    Write-Log "转���文档..." "INFO"
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
MarkItDown 环境管理器 - Conda 环境检测与自动创建
================================================================================

平台: $os
版本: v5.0.0

用法: manage_environment.ps1 -Command <命令> [选项]

--------------------------------------------------------------------------------
环境检测与创建流程 (仅 Conda):
--------------------------------------------------------------------------------
  步骤 1: 检测 Conda 是否安装
  步骤 2: 检测 Conda 环境是否存在
  步骤 3: 自动创建 Conda 环境（如不存在）
  步骤 4: 安装 markitdown[all]

--------------------------------------------------------------------------------
命令:
--------------------------------------------------------------------------------
    check              检查 Conda 环境状态
    setup             自动设置 Conda 环境（推荐）
    run <命令>         运行命令
    convert           转换文档
    help              显示帮助

--------------------------------------------------------------------------------
选项:
--------------------------------------------------------------------------------
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
    # 检查环境状态
    .\manage_environment.ps1 -Command check

    # 自动设置环境（自动检测并创建 Conda 环境）
    .\manage_environment.ps1 -Command setup

    # 使用阿里云镜像设置环境
    .\manage_environment.ps1 -Command setup -Mirror aliyun

    # 运行脚本
    .\manage_environment.ps1 -Command run -RunCommand @("python", "--version")

    # 转换文档
    .\manage_environment.ps1 -Command convert -InputFile "doc.pdf" -OutputDir "C:\output"

--------------------------------------------------------------------------------
环境要求:
--------------------------------------------------------------------------------
    Conda (Miniconda/Anaconda) - 必需
    网络: PyPI 或国内镜像

--------------------------------------------------------------------------------
环境信息:
--------------------------------------------------------------------------------
    Conda 环境: $env:USERPROFILE\.conda\envs\$script:EnvName
    日志文件:  $LogFile

================================================================================

"@
}

Write-Host ""
Write-Host "MarkItDown 环境管理器 v5.0.0" -ForegroundColor Cyan
Write-Host "平台: $(Get-OperatingSystem)" -ForegroundColor Cyan
Write-Host ""

switch ($Command) {
    "check" {
        Write-Log "======================================" "INFO"
        Write-Log "Conda 环境状态检测" "INFO"
        Write-Log "======================================" "INFO"

        Write-Log "检测 Conda 安装状态..." "INFO"
        $condaPath = Test-CondaInstalled
        if ($condaPath) {
            Write-Log "Conda 已安装 ✓" "SUCCESS"
            Write-Log "" "INFO"
            Write-Log "检测 Conda 环境..." "INFO"
            $envExists = Test-CondaEnvironmentExists -EnvName $script:EnvName
        } else {
            Write-Log "Conda 未安装" "ERROR"
        }

        Write-Log "" "INFO"
        Write-Log "检测 Python 环境..." "INFO"
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
            Write-Log "环境设置完成！✓" "SUCCESS"
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