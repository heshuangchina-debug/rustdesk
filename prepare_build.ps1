#Requires -RunAsAdministrator

<#
.SYNOPSIS
    YhloVnc 编译准备脚本 - 检查和安装编译依赖
.DESCRIPTION
    此脚本检查编译 YhloVnc 所需的依赖环境，并尝试安装缺失的组件
#>

param(
    [switch]$SkipRustInstall,
    [switch]$SkipFlutterInstall,
    [switch]$SkipVSInstall
)

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  YhloVnc 编译环境检查与配置" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 检查函数
function Test-Command {
    param($Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Test-IsElevated {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# 1. 检查 Rust
Write-Host "[1/5] 检查 Rust 环境..." -ForegroundColor Yellow
if (Test-Command "rustc") {
    $rustVersion = (rustc --version) -replace "rustc ", ""
    Write-Host "  ✓ Rust 已安装: $rustVersion" -ForegroundColor Green
} else {
    if (-not $SkipRustInstall) {
        Write-Host "  ✗ Rust 未安装，正在安装..." -ForegroundColor Red
        Write-Host "  请访问 https://rustup.rs 下载安装" -ForegroundColor Yellow
        # 尝试静默安装
        try {
            Invoke-WebRequest -Uri "https://win.rustup.rs" -OutFile "$env:TEMP\rustup-init.exe" -UseBasicParsing
            Start-Process -FilePath "$env:TEMP\rustup-init.exe" -ArgumentList "-y", "--default-toolchain", "stable" -Wait
            Write-Host "  ✓ Rust 安装完成" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Rust 安装失败，请手动安装: https://rustup.rs" -ForegroundColor Red
        }
    } else {
        Write-Host "  ✗ Rust 未安装 (跳过安装)" -ForegroundColor Red
    }
}

# 2. 检查 Flutter
Write-Host ""
Write-Host "[2/5] 检查 Flutter SDK..." -ForegroundColor Yellow
if (Test-Command "flutter") {
    $flutterVersion = (flutter --version | Select-Object -First 1)
    Write-Host "  ✓ Flutter 已安装: $flutterVersion" -ForegroundColor Green
} else {
    if (-not $SkipFlutterInstall) {
        Write-Host "  ✗ Flutter 未安装" -ForegroundColor Red
        Write-Host "  请访问 https://flutter.dev 下载 Flutter SDK" -ForegroundColor Yellow
    } else {
        Write-Host "  ✗ Flutter 未安装 (跳过安装)" -ForegroundColor Red
    }
}

# 3. 检查 Visual Studio Build Tools
Write-Host ""
Write-Host "[3/5] 检查 Visual Studio Build Tools..." -ForegroundColor Yellow
$vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vsWhere) {
    $vsVersion = & $vsWhere -latest -property displayVersion -format value 2>$null
    $vsWorkloads = & $vsWhere -latest -requires Microsoft.VisualStudio.Workload.VCTools -format value 2>$null
    if ($vsWorkloads) {
        Write-Host "  ✓ Visual Studio 已安装: $vsVersion" -ForegroundColor Green
        Write-Host "  ✓ C++ 开发工具已安装" -ForegroundColor Green
    } else {
        Write-Host "  △ Visual Studio 已安装但缺少 C++ 工作负载" -ForegroundColor Yellow
        Write-Host "  请在 Visual Studio Installer 中添加 '使用 C++ 的桌面开发'" -ForegroundColor Yellow
    }
} else {
    if (-not $SkipVSInstall) {
        Write-Host "  ✗ Visual Studio Build Tools 未安装" -ForegroundColor Red
        Write-Host "  请访问 https://visualstudio.microsoft.com/downloads 下载 Visual Studio Build Tools" -ForegroundColor Yellow
    } else {
        Write-Host "  ✗ Visual Studio Build Tools 未安装 (跳过安装)" -ForegroundColor Red
    }
}

# 4. 检查 vcpkg
Write-Host ""
Write-Host "[4/5] 检查 vcpkg..." -ForegroundColor Yellow
$vcpkgPath = "$env:USERPROFILE\vcpkg"
if (Test-Path $vcpkgPath) {
    Write-Host "  ✓ vcpkg 已安装: $vcpkgPath" -ForegroundColor Green
} else {
    Write-Host "  △ vcpkg 未安装 (可选)" -ForegroundColor Yellow
    Write-Host "  运行: git clone https://github.com/microsoft/vcpkg.git $vcpkgPath" -ForegroundColor Yellow
    Write-Host "       $vcpkgPath\bootstrap-vcpkg.bat" -ForegroundColor Yellow
}

# 5. 环境总结
Write-Host ""
Write-Host "[5/5] 环境总结..." -ForegroundColor Yellow
Write-Host ""

$allReady = (Test-Command "rustc") -and (Test-Command "flutter")
if ($allReady) {
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "  ✓ 环境准备就绪，可以开始编译！" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "下一步操作:" -ForegroundColor Cyan
    Write-Host "  1. cd D:\claude\rustdesk\flutter" -ForegroundColor White
    Write-Host "  2. flutter pub get" -ForegroundColor White
    Write-Host "  3. flutter build windows --release -o ..\output" -ForegroundColor White
} else {
    Write-Host "======================================" -ForegroundColor Yellow
    Write-Host "  △ 请先安装缺失的依赖" -ForegroundColor Yellow
    Write-Host "======================================" -ForegroundColor Yellow
}