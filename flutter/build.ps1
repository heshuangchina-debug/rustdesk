#Requires -RunAsAdministrator

<#
.SYNOPSIS
    YhloVnc Windows 编译脚本
.DESCRIPTION
    编译 YhloVnc Windows 安装包
.PARAMETER Configuration
    编译配置: Release (默认) 或 Debug
.PARAMETER OutputPath
    输出目录，默认: ..\output
#>

param(
    [ValidateSet("Release", "Debug")]
    [string]$Configuration = "Release",

    [string]$OutputPath = "..\output"
)

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  YhloVnc 编译脚本" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 设置工作目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = $ScriptDir
$FlutterDir = Join-Path $ProjectRoot "flutter"
$OutputDir = Join-Path $ProjectRoot $OutputPath

# 检查环境
Write-Host "[1/4] 检查编译环境..." -ForegroundColor Yellow

if (-not (Get-Command rustc -ErrorAction SilentlyContinue)) {
    Write-Host "  ✗ Rust 未安装" -ForegroundColor Red
    Write-Host "  请先运行 .\prepare_build.ps1 安装依赖" -ForegroundColor Yellow
    exit 1
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "  ✗ Flutter 未安装" -ForegroundColor Red
    Write-Host "  请先运行 .\prepare_build.ps1 安装依赖" -ForegroundColor Yellow
    exit 1
}

Write-Host "  ✓ 环境检查通过" -ForegroundColor Green

# 清理旧的输出
Write-Host ""
Write-Host "[2/4] 清理旧的构建文件..." -ForegroundColor Yellow
if (Test-Path $OutputDir) {
    Remove-Item -Path $OutputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
Write-Host "  ✓ 输出目录已准备: $OutputDir" -ForegroundColor Green

# 编译 Rust 核心库
Write-Host ""
Write-Host "[3/4] 编译 Rust 核心库..." -ForegroundColor Yellow
Push-Location $ProjectRoot

try {
    # 设置编译选项
    $env:RUSTFLAGS = "-C target-feature=+crt-static"
    $env:CARGO_NET_GIT_FETCH_WITH_CLI = "true"

    # 添加 Windows 目标
    rustup target add x86_64-pc-windows-msvc 2>$null

    # 编译
    cargo build --release -p librustdesk 2>&1 | ForEach-Object {
        Write-Host "  $_"
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Rust 编译失败"
    }

    Write-Host "  ✓ Rust 核心库编译完成" -ForegroundColor Green

} finally {
    Pop-Location
}

# 编译 Flutter 应用
Write-Host ""
Write-Host "[4/4] 编译 Flutter 应用..." -ForegroundColor Yellow
Push-Location $FlutterDir

try {
    # 获取依赖
    flutter pub get 2>&1 | ForEach-Object {
        Write-Host "  $_"
    }

    # 构建 Windows 应用
    flutter build windows --$Configuration -o $OutputDir 2>&1 | ForEach-Object {
        Write-Host "  $_"
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Flutter 编译失败"
    }

    Write-Host "  ✓ Flutter 应用编译完成" -ForegroundColor Green

} finally {
    Pop-Location
}

# 完成
Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "  ✓ 编译完成！" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "输出文件:" -ForegroundColor Cyan
Get-ChildItem -Path $OutputDir -File | ForEach-Object {
    Write-Host "  - $($_.Name) ($([math]::Round($_.Length / 1MB, 2)) MB)" -ForegroundColor White
}
Write-Host ""
Write-Host "安装包位置: $OutputDir" -ForegroundColor Cyan