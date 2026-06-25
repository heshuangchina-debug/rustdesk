# YhloVnc 编译指南

## 环境要求

### 1. 安装 Rust
```powershell
# 使用官方安装脚本（推荐）
iwr https://win.rustup.rs -OutFile rustup-init.exe
.\rustup-init.exe -y

# 或者使用 winget
winget install Rustlang.Rustup
```

### 2. 安装 Flutter SDK
```powershell
# 下载 Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# 或者使用 winget
winget install Google.FlutterSDK

# 将 Flutter 添加到 PATH
$env:PATH = "$env:USERPROFILE\AppData\Local\Flutter\bin;$env:PATH"
```

### 3. 安装 Windows 编译工具
- Visual Studio 2022 或更高版本（包含 "使用 C++ 的桌面开发" 工作负载）
- Windows 10/11 SDK

### 4. 安装 vcpkg（用于依赖管理）
```powershell
git clone https://github.com/microsoft/vcpkg.git
.\vcpkg\bootstrap-vcpkg.bat
```

## 编译步骤

### 方式一：使用构建脚本（推荐）

#### Windows (MSVC)
```powershell
cd D:\claude\rustdesk
.\flutter\build.ps1
```

#### Windows (MinGW)
```powershell
cd D:\claude\rustdesk
.\flutter\build_mingw.ps1
```

### 方式二：手动编译

#### 1. 编译 Rust 核心库
```powershell
cd D:\claude\rustdesk

# 设置编译目标
$env:RUSTFLAGS = "-C target-feature=+crt-static"
$env:CARGO_NET_GIT_FETCH_WITH_CLI = "true"

# 使用 vcpkg 编译依赖
$env:VCPKG_ROOT = "D:\path\to\vcpkg"
$env:PATH = "$env:VCPKG_ROOT;$env:PATH"

# 编译 Windows 版本
rustup target add x86_64-pc-windows-msvc
cargo build --release --target x86_64-pc-windows-msvc -p librustdesk
```

#### 2. 编译 Flutter 应用
```powershell
cd D:\claude\rustdesk\flutter

# 获取依赖
flutter pub get

# 构建 Windows 应用
flutter build windows --release -o ..\output
```

## 输出位置

编译完成后，安装包将在 `D:\claude\rustdesk\output` 目录中：

- Windows: `rustdesk_x.x.x.exe` 或 `rustdesk_x.x.x.msi`
- 安装程序可分发给用户

## 常见问题

### 问题 1: 缺少 Visual Studio Build Tools
```
error: Linker link.exe not found
```
解决方案：安装 Visual Studio Build Tools 2022

### 问题 2: vcpkg 依赖库缺失
```powershell
# 安装常用依赖
vcpkg install libvpx:x64-windows-static libyuv:x64-windows-static libopus:x64-windows-static
```

### 问题 3: Flutter 编译错误
```powershell
# 清理并重新获取依赖
flutter clean
flutter pub get
```

## 快速验证

编译前可以验证环境：
```powershell
rustc --version
cargo --version
flutter --version
vcpkg version
```