# YhloVnc 修改总结

本文档记录了从 RustDesk 到 YhloVnc 的所有代码修改。

## 修改概览

| 序号 | 修改项 | 状态 |
|------|--------|------|
| 1 | 软件名称改为 YhloVnc | ✅ 完成 |
| 2 | URL 替换为 www.szyhlo.com | ✅ 完成 |
| 3 | 主界面文字修改 | ✅ 完成 |
| 4 | 关于页面修改 | ✅ 完成 |
| 5 | 安装包默认设置 | ✅ 完成 |
| 6 | 取消用户协议链接 | ✅ 完成 |
| 7 | 屏蔽工具栏功能 | ✅ 完成 |
| 8 | 默认设置修改 | ✅ 完成 |
| 9 | 硬编码服务器配置 | ✅ 完成 |
| 10 | 添加透明浮窗 | ✅ 完成 |
| 11 | 实现隐私屏功能 | ✅ 完成 |
| 12 | 编译安装包 | ⏳ 待执行 |

## 详细修改

### 1. 软件名称修改为 YhloVnc

#### Windows 配置
- `flutter/windows/runner/Runner.rc` - ProductName, FileDescription
- `flutter/windows/runner/main.cpp` - 库文件名和函数名
- `flutter/windows/CMakeLists.txt` - 项目名称

#### Android 配置
- `flutter/android/app/src/main/AndroidManifest.xml` - 应用名称
- `flutter/android/app/src/main/res/values/strings.xml` - 应用名称
- `flutter/android/app/src/main/kotlin/com/carriez/flutter_hbb/MainService.kt` - 通知标题
- `flutter/android/app/src/main/kotlin/com/carriez/flutter_hbb/FloatingWindowService.kt` - 菜单文字
- `flutter/android/app/src/main/kotlin/com/carriez/flutter_hbb/BootReceiver.kt` - Toast 消息
- `flutter/android/app/src/main/kotlin/ffi.kt` - 库加载名称

#### macOS 配置
- `flutter/macos/Runner/Info.plist` - CFBundleName, CFBundleDisplayName, URL Schemes
- `flutter/macos/Runner/Configs/AppInfo.xcconfig` - PRODUCT_NAME
- `flutter/macos/Runner/MainFlutterWindow.swift` - 函数名
- `flutter/macos/Runner.xcodeproj/project.pbxproj` - 库文件名, Bundle ID

#### Linux 配置
- `flutter/linux/main.cc` - 库文件名和函数名
- `flutter/linux/my_application.cc` - 图标名称, 窗口标题
- `flutter/linux/CMakeLists.txt` - 项目名称

#### iOS 配置
- `flutter/ios/Runner/Info.plist` - CFBundleName, CFBundleDisplayName
- `flutter/ios/Runner/GoogleService-Info.plist` - Project ID, Bundle ID

### 2. URL 替换

所有 `rustdesk.com` 链接替换为 `www.szyhlo.com`:
- `flutter/lib/common.dart`
- `flutter/lib/desktop/pages/desktop_home_page.dart`
- `flutter/lib/desktop/pages/connection_page.dart`
- `flutter/lib/desktop/pages/desktop_setting_page.dart`
- `flutter/lib/desktop/pages/install_page.dart`
- `flutter/lib/mobile/pages/connection_page.dart`
- `flutter/lib/mobile/pages/settings_page.dart`

### 3. 界面文字修改

#### 中文翻译文件 `src/lang/cn.rs`
- `Ready` → `就绪,已连接至亚辉龙加密网络`
- `Control Remote Desktop` → `亚辉龙远程系统`
- `Connect` → `亚辉龙远程系统`
- `About RustDesk` → `关于 YhloVnc`
- `Slogan_tip` → `关于此软件的任何问题，请咨询流程IT部运维小组！`

### 4. 关于页面修改

- `flutter/lib/desktop/pages/desktop_setting_page.dart` - 注释掉隐私声明链接
- `flutter/lib/mobile/pages/settings_page.dart` - 注释掉隐私声明

### 5. 安装包默认设置

- `flutter/lib/desktop/pages/install_page.dart` - 打印机默认不勾选 (已有默认值 false)
- `flutter/lib/desktop/pages/install_page.dart` - 注释掉用户协议超链接

### 6. 屏蔽工具栏功能

- `flutter/lib/common/widgets/toolbar.dart` - 注释掉 REC 菜单
- `flutter/lib/desktop/widgets/remote_toolbar.dart` - 注释掉 Chat、VoiceCall、Record 菜单

### 7. 默认设置修改

#### `libs/hbb_common/src/config.rs`
- `kOptionScrollStyle` 默认值: `scrollauto` → `scrollbar`
- `kOptionLockAfterSessionEnd` 默认值: `N` → `Y`
- `kOptionEnableCheckUpdate` 特殊处理: 默认 false

#### `flutter/lib/common.dart`
- `option2bool()` 函数添加 `kOptionEnableCheckUpdate` 特殊处理

### 8. 硬编码服务器配置

#### `src/flutter_ffi.rs`
```rust
// Hardcoded server configuration
config::Config::set_option("custom-rendezvous-server".into(), "192.168.0.28".into());
config::Config::set_option("key".into(), "vcUVyDqvO2JU5RkPZIIBMr9LgkiaWVVrhnatt4ezFFY=".into());
```

### 9. 透明浮窗功能

#### `flutter/lib/desktop/pages/remote_page.dart`
- 添加 `_RemotePeerFloatingWidget` 类
- 位置: 页面右上角 (`top: 60, right: 10`)
- 功能:
  - 显示会话数量
  - 展开显示对方用户名、ID、IP
  - 红色断开连接按钮

### 10. 隐私屏功能

#### `flutter/lib/desktop/pages/remote_page.dart`
- 添加隐私屏状态管理
- 隐私屏内容:
  - 黑色背景
  - 绿色圆点 + "yhlovnc隐私保护中"
  - "正在远程工作中，请勿操作。" (24px 字体)
  - "按ctrl+p退出隐私保护"
- 快捷键: Ctrl+P 退出隐私保护并进入锁屏状态

#### `flutter/lib/models/state_model.dart`
- `privacyScreenEnabled = true` - 默认启用

## 编译说明

### 环境要求
- Rust (stable)
- Flutter SDK
- Visual Studio 2022 (C++ 开发工具)
- Windows 10/11 SDK

### 编译步骤
```powershell
# 1. 检查环境
.\prepare_build.ps1

# 2. 编译
cd flutter
.\build.ps1
```

### 输出位置
`D:\claude\rustdesk\output\`

## 注意事项

1. **库文件名变更**: `librustdesk.dll` → `libyhlovnc.dll`，需要同步修改 Rust 端的输出文件名

2. **进程名变更**: `rustdesk.exe` → `yhlovnc.exe`，确保所有引用都正确更新

3. **包名保持**: Flutter 包名仍为 `flutter_hbb`，应用 ID 保持 `com.carriez.rustdesk`

4. **服务端兼容**: 本修改仅修改客户端，不影响与服务端的通信协议兼容性