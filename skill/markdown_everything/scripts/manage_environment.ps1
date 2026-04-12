# MarkItDown Environment Manager
# 跨平台Conda环境管理器 - 支持Windows、Linux、macOS
# 支持 pip fallback（conda 不可用时自动使用 pip）

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("check", "list", "exists", "create", "remove", "install", "setup", "run", "convert", "help")]
    [string]$Command = "help",

    [Parameter(Mandatory=$false)]
    [string]$EnvironmentName = "markitdown",

    [Parameter(Mandatory=$false)]
    [string]$PythonVersion = "3.12",

    [Parameter(Mandatory=$false)]
    [switch]$Force,

    [Parameter(Mandatory=$false)]
    [switch]$UsePip,

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

# ============================================
# 跨平台配置和检测
# ============================================

$script:IsWindows = $PSVersionTable.Platform -eq 'Win32NT' -or $null -eq $PSVersionTable.Platform
$script:IsLinux = $PSVersionTable.Platform -eq 'Unix' -and (Test-Path "/proc/version")
$script:IsMacOS = $PSVersionTable.Platform -eq 'Unix' -and (Test-Path "/System/Library/CoreServices/SystemVersion.plist")

if ($script:IsWindows) {
    $script:PathSeparator = "\"
    $script:EnvSeparator = ";"
    $script:DefaultCondaPaths = @(
        "$env:USERPROFILE\.conda",
        "$env:USERPROFILE\Anaconda3",
        "$env:USERPROFILE\Miniconda3",
        "C:\.conda",
        "C:\Anaconda3",
        "C:\Miniconda3"
    )
    $script:PythonExeName = "python.exe"
    $script:CondaExeName = "conda.exe"
    $script:PipExeName = "pip.exe"
} else {
    $script:PathSeparator = "/"
    $script:EnvSeparator = ":"
    $script:DefaultCondaPaths = @(
        "$HOME/.conda",
        "$HOME/anaconda3",
        "$HOME/miniconda3",
        "/opt/anaconda3",
        "/opt/miniconda3"
    )
    $script:PythonExeName = "python"
    $script:CondaExeName = "conda"
    $script:PipExeName = "pip"
}

# ============================================
# 日志函数
# ============================================

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

# ============================================
# 跨平台工具函数
# ============================================

function Get-OperatingSystem {
    if ($script:IsWindows) { return "Windows" }
    elseif ($script:IsMacOS) { return "macOS" }
    elseif ($script:IsLinux) { return "Linux" }
    else { return "Unknown" }
}

function Test-PathCrossPlatform {
    param([string]$Path)
    try {
        return Test-Path $Path
    } catch {
        return $false
    }
}

function Get-CondaExePath {
    $condaCmd = Get-Command conda -ErrorAction SilentlyContinue
    if ($condaCmd) {
        return $condaCmd.Source
    }

    foreach ($basePath in $script:DefaultCondaPaths) {
        $condaPath = Join-Path $basePath "bin" $script:CondaExeName
        if ($script:IsWindows) {
            $condaPath = Join-Path $basePath $script:CondaExeName
        }

        if (Test-PathCrossPlatform $condaPath) {
            return $condaPath
        }
    }

    return $null
}

function Get-PythonExePath {
    param([string]$EnvName)

    if ($script:IsWindows) {
        $pythonPath = Join-Path $basePath "envs" $EnvName "Scripts" $script:PythonExeName
    } else {
        $pythonPath = Join-Path $basePath "envs" $EnvName "bin" $script:PythonExeName
    }

    foreach ($basePath in $script:DefaultCondaPaths) {
        $pythonPath = Join-Path $basePath "envs" $EnvName

        if ($script:IsWindows) {
            $pythonPath = Join-Path $pythonPath "Scripts" $script:PythonExeName
        } else {
            $pythonPath = Join-Path $pythonPath "bin" $script:PythonExeName
        }

        if (Test-PathCrossPlatform $pythonPath) {
            return $pythonPath
        }
    }

    return $null
}

# ============================================
# Conda管理函数
# ============================================

function Test-CondaAvailable {
    try {
        $condaPath = Get-CondaExePath
        if ($condaPath) {
            $version = conda --version 2>&1
            $os = Get-OperatingSystem
            Write-Log "Found conda ($os): $version" "SUCCESS"
            Write-Log "Conda path: $condaPath" "INFO"
            return $true
        } else {
            Write-Log "Conda not found in PATH." "WARNING"
            Write-Log "Will try to use pip as fallback..." "INFO"
            return $false
        }
    } catch {
        Write-Log "Error checking conda: $_" "WARNING"
        Write-Log "Will try to use pip as fallback..." "INFO"
        return $false
    }
}

function Test-PipAvailable {
    try {
        $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
        if ($pythonCmd) {
            $version = python --version 2>&1
            Write-Log "Found Python: $version" "SUCCESS"
            Write-Log "Python path: $($pythonCmd.Source)" "INFO"
            return $true
        } else {
            Write-Log "Python not found in PATH." "ERROR"
            return $false
        }
    } catch {
        Write-Log "Error checking Python: $_" "ERROR"
        return $false
    }
}

function Install-MarkitdownWithPip {
    Write-Log "Installing markitdown with all optional dependencies using pip..." "INFO"

    try {
        python -m pip install 'markitdown[all]' 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Log "Markitdown installed successfully using pip" "SUCCESS"
            return $true
        } else {
            Write-Log "Failed to install markitdown using pip" "ERROR"
            return $false
        }
    } catch {
        Write-Log "Failed to install markitdown using pip: $_" "ERROR"
        return $false
    }
}

function Invoke-PythonRun {
    param([string[]]$Command)

    if (-not (Test-PipAvailable)) {
        Write-Log "Python not available" "ERROR"
        return $false
    }

    $cmdString = $Command -join " "
    Write-Log "Running with Python: $cmdString" "INFO"

    try {
        python $Command
        return $?
    } catch {
        Write-Log "Failed to run command: $_" "ERROR"
        return $false
    }
}

function Convert-Document {
    param(
        [string]$InputPath,
        [string]$OutputPath
    )

    if (-not $InputPath) {
        Write-Log "Input file path is required for convert command" "ERROR"
        return $false
    }

    if (-not (Test-Path $InputPath)) {
        Write-Log "Input file not found: $InputPath" "ERROR"
        return $false
    }

    $resolvedInput = Resolve-Path $InputPath
    $inputFileName = [System.IO.Path]::GetFileName($resolvedInput)
    $inputBaseName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedInput)

    if ($OutputPath) {
        if (-not (Test-Path $OutputPath)) {
            try {
                New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
                Write-Log "Created output directory: $OutputPath" "INFO"
            } catch {
                Write-Log "Failed to create output directory: $_" "ERROR"
                return $false
            }
        }
        $resolvedOutput = Resolve-Path $OutputPath
        $outputFile = Join-Path $resolvedOutput "$inputBaseName.md"
    } else {
        $outputFile = Join-Path (Get-Location) "$inputBaseName.md"
        $OutputPath = Get-Location
    }

    Write-Log "Converting document..." "INFO"
    Write-Log "  Input: $resolvedInput" "INFO"
    Write-Log "  Output: $outputFile" "INFO"

    $condaAvailable = Test-CondaAvailable
    $success = $false

    if ($condaAvailable -and (Test-EnvironmentExists -EnvName $EnvironmentName)) {
        Write-Log "Using conda environment: $EnvironmentName" "INFO"
        conda run -n $EnvironmentName python "convert_document.py" $resolvedInput -o $outputFile
        $success = $?
    } elseif (-not $condaAvailable -or $UsePip) {
        Write-Log "Using pip fallback..." "INFO"
        if (Test-PipAvailable) {
            python "convert_document.py" $resolvedInput -o $outputFile
            $success = $?
        } else {
            Write-Log "Python not available for pip fallback" "ERROR"
            return $false
        }
    } else {
        Write-Log "Environment '$EnvironmentName' not found. Setting up..." "WARNING"
        if (Complete-Setup -ForceRecreate $false) {
            conda run -n $EnvironmentName python "convert_document.py" $resolvedInput -o $outputFile
            $success = $?
        } else {
            return $false
        }
    }

    if ($success) {
        Write-Log "Document converted successfully: $outputFile" "SUCCESS"
        Write-Log "Output directory: $OutputPath" "INFO"
        return $true
    } else {
        Write-Log "Failed to convert document" "ERROR"
        return $false
    }
}

function Get-EnvironmentList {
    Write-Log "Listing all conda environments..."
    $os = Get-OperatingSystem
    Write-Log "Operating System: $os" "INFO"

    try {
        conda env list
        return $true
    } catch {
        Write-Log "Failed to list environments: $_" "ERROR"
        return $false
    }
}

function Test-EnvironmentExists {
    param([string]$EnvName)

    try {
        $envList = conda env list 2>&1 | Out-String
        $pattern = "(^|\s)${EnvName}(\s|$)"
        if ($envList -imatch $pattern) {
            Write-Log "Environment '$EnvName' found" "INFO"
            return $true
        } else {
            Write-Log "Environment '$EnvName' not found" "INFO"
            return $false
        }
    } catch {
        Write-Log "Error checking environments: $_" "ERROR"
        return $false
    }
}

function New-Environment {
    param(
        [string]$EnvName,
        [string]$PythonVer,
        [bool]$ForceRecreate
    )

    if (Test-EnvironmentExists -EnvName $EnvName) {
        if ($ForceRecreate) {
            Write-Log "Environment '$EnvName' exists. Recreating with -Force flag..." "WARNING"
            Remove-Environment -EnvName $EnvName
        } else {
            Write-Log "Environment '$EnvName' already exists. Use -Force to recreate." "WARNING"
            return $true
        }
    }

    Write-Log "Creating new conda environment '$EnvName' with Python $PythonVer..." "INFO"
    Write-Log "Platform: $(Get-OperatingSystem)" "INFO"

    try {
        conda create -n $EnvName python=$PythonVer -y 2>&1 | Out-Null
        Write-Log "Environment '$EnvName' created successfully" "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to create environment: $_" "ERROR"
        return $false
    }
}

function Remove-Environment {
    param([string]$EnvName)

    Write-Log "Removing environment '$EnvName'..." "WARNING"

    try {
        conda env remove -n $EnvName -y 2>&1 | Out-Null
        Write-Log "Environment '$EnvName' removed successfully" "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to remove environment: $_" "ERROR"
        return $false
    }
}

function Install-Markitdown {
    param([string]$EnvName)

    if (-not (Test-EnvironmentExists -EnvName $EnvName)) {
        Write-Log "Environment '$EnvName' does not exist. Cannot install markitdown." "ERROR"
        return $false
    }

    Write-Log "Installing markitdown with all optional dependencies in '$EnvName'..." "INFO"

    $pythonExe = Get-PythonExePath -EnvName $EnvName

    try {
        if ($pythonExe -and (Test-PathCrossPlatform $pythonExe)) {
            Write-Log "Using Python: $pythonExe" "INFO"
            & $pythonExe -m pip install 'markitdown[all]' 2>&1 | Out-Null
        } else {
            Write-Log "Python not found in expected path, using conda run" "INFO"
            conda run -n $EnvName $script:PipExeName install 'markitdown[all]' 2>&1 | Out-Null
        }

        Write-Log "Markitdown installed successfully in '$EnvName'" "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to install markitdown: $_" "ERROR"
        return $false
    }
}

function Invoke-ActivateAndRun {
    param(
        [string]$EnvName,
        [string[]]$Command
    )

    if (-not (Test-EnvironmentExists -EnvName $EnvName)) {
        Write-Log "Environment '$EnvName' does not exist" "ERROR"
        return $false
    }

    $cmdString = $Command -join " "
    Write-Log "Activating environment '$EnvName' and running: $cmdString" "INFO"
    Write-Log "Platform: $(Get-OperatingSystem)" "INFO"

    try {
        conda run -n $EnvName $Command
        return $true
    } catch {
        Write-Log "Failed to run command: $_" "ERROR"
        return $false
    }
}

function Complete-Setup {
    param([bool]$ForceRecreate)

    if (-not (Test-CondaAvailable)) {
        return $false
    }

    if (Test-EnvironmentExists -EnvName $EnvironmentName) {
        if ($ForceRecreate) {
            Write-Log "Environment exists. Recreating with -Force flag..." "WARNING"
            Remove-Environment -EnvName $EnvironmentName
        } else {
            Write-Log "Environment '$EnvironmentName' already exists" "INFO"
            Write-Log "Setup completed successfully!" "SUCCESS"
            return $true
        }
    }

    if (-not (New-Environment -EnvName $EnvironmentName -PythonVer $PythonVersion -ForceRecreate $false)) {
        return $false
    }

    if (-not (Install-Markitdown -EnvName $EnvironmentName)) {
        return $false
    }

    Write-Log "Setup completed successfully!" "SUCCESS"
    return $true
}

function Show-Help {
    $os = Get-OperatingSystem
    Write-Host @"

================================================================================
MarkItDown Environment Manager - 跨平台Conda环境管理器
================================================================================

当前平台: $os

用法: manage_environment.ps1 -Command <命令> [选项]

--------------------------------------------------------------------------------
命令:
--------------------------------------------------------------------------------
    check               检查conda是否可用
    list                列出所有conda环境
    exists [名称]       检查指定环境是否存在（默认: markitdown）
    create [名称]       创建新环境（默认: markitdown）
    remove [名称]       移除指定环境（默认: markitdown）
    install [名称]      安装markitdown到指定环境（默认: markitdown）
    setup               完整设置环境（创建+安装）
    run [命令]          在指定环境中运行命令（默认: markitdown）
    help                显示此帮助信息

--------------------------------------------------------------------------------
选项:
--------------------------------------------------------------------------------
    -EnvironmentName <名称>    指定环境名称（默认: markitdown）
    -PythonVersion <版本>     指定Python版本（默认: 3.12）
    -Force                    强制重新创建环境

--------------------------------------------------------------------------------
使用示例:
--------------------------------------------------------------------------------
    # 检查环境
    .\manage_environment.ps1 -Command check

    # 列出所有环境
    .\manage_environment.ps1 -Command list

    # 完整设置环境
    .\manage_environment.ps1 -Command setup

    # 强制重新设置
    .\manage_environment.ps1 -Command setup -Force

    # 创建自定义环境
    .\manage_environment.ps1 -Command setup -EnvironmentName "myenv" -PythonVersion "3.11"

    # 在环境中运行命令
    .\manage_environment.ps1 -Command run -RunCommand @("python", "--version")

    # 转换文档
    .\manage_environment.ps1 -Command run -RunCommand @("python", "convert_document.py", "document.pdf")

--------------------------------------------------------------------------------
环境变量:
--------------------------------------------------------------------------------
    \$env:MARKITDOWN_ENV_NAME    覆盖默认环境名称（默认: markitdown）
    \$env:MARKITDOWN_PYTHON_VER 覆盖默认Python版本（默认: 3.12）

--------------------------------------------------------------------------------
跨平台支持:
--------------------------------------------------------------------------------
    Windows PowerShell: 推荐使用本脚本
    Linux/macOS Bash:   使用 manage_environment.sh

--------------------------------------------------------------------------------
日志:
--------------------------------------------------------------------------------
    日志文件: $LogFile

================================================================================

"@
}

function Get-ActivationCommand {
    $os = Get-OperatingSystem
    Write-Host ""
    Write-Host "=== Environment Setup Complete ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Platform: $os" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To activate the $EnvironmentName environment, run:" -ForegroundColor White
    Write-Host ""

    if ($script:IsWindows) {
        Write-Host "    conda activate $EnvironmentName" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Or use the following command to run markitdown:" -ForegroundColor White
        Write-Host ""
        Write-Host "    conda run -n $EnvironmentName python convert_document.py <file_path>" -ForegroundColor Yellow
    } else {
        Write-Host "    conda activate $EnvironmentName" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Or use the following command:" -ForegroundColor White
        Write-Host ""
        Write-Host "    conda run -n $EnvironmentName python convert_document.py <file_path>" -ForegroundColor Yellow
    }

    Write-Host ""
}

# ============================================
# 主程序入口
# ============================================

Write-Host ""
Write-Host "MarkItDown Environment Manager" -ForegroundColor Cyan
Write-Host "Platform: $(Get-OperatingSystem)" -ForegroundColor Cyan
Write-Host ""

switch ($Command) {
    "check" {
        Test-CondaAvailable
    }
    "list" {
        Get-EnvironmentList
    }
    "exists" {
        if (Test-EnvironmentExists -EnvName $EnvironmentName) {
            Write-Log "Environment '$EnvironmentName' exists" "SUCCESS"
            exit 0
        } else {
            Write-Log "Environment '$EnvironmentName' not found" "WARNING"
            exit 1
        }
    }
    "create" {
        New-Environment -EnvName $EnvironmentName -PythonVer $PythonVersion -ForceRecreate $Force
    }
    "remove" {
        Remove-Environment -EnvName $EnvironmentName
    }
    "install" {
        Install-Markitdown -EnvName $EnvironmentName
    }
    "setup" {
        $result = Complete-Setup -ForceRecreate $Force
        if ($result) {
            Get-ActivationCommand
            exit 0
        } else {
            exit 1
        }
    }
    "run" {
        if ($null -eq $RunCommand -or $RunCommand.Count -eq 0) {
            Write-Log "Please specify command to run" "ERROR"
            Show-Help
            exit 1
        }
        Invoke-ActivateAndRun -EnvName $EnvironmentName -Command $RunCommand
    }
    "help" {
        Show-Help
    }
}
