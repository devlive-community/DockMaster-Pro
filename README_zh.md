# DockMaster Pro

一款强大的 macOS 自定义多行 Dock 替代工具。

![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

[English](README.md) | [中文](README_zh.md)

## 功能特性

### 自定义 Dock 覆盖层
- **多行 / 多列布局** — 以网格形式展示图标，不再局限于单行
- **三个停靠位置** — 屏幕底部、左侧或右侧
- **可配置图标大小** — 32px 至 128px
- **自动隐藏** — 不用时隐藏，鼠标靠近时显示
- **可滚动溢出** — 内容超出可用空间时平滑滚动
- **最近应用** — 可切换的最近运行未固定应用区域

### Dock 分区
- **多个命名分区** — 将应用按逻辑分组
- **添加、重命名、排序、删除** — 完整的分区管理
- **视觉分隔线** — 分区之间清晰分隔
- **拖拽排序** — 直观地调整分区和项目顺序

### 丰富的动画系统
- **20 种悬停动画** — 弹跳、抖动、脉冲、3D 翻转、故障、Tada、心跳等
- **8 种启动动画** — 缩放、淡入、滑入、弹出等
- **7 种退出动画** — 缩小、淡出、溶解等
- **尊重无障碍设置** — 遵循 macOS 减弱动效设置

### 工作区
- **多个工作区** — 每个工作区拥有独立的 Dock 布局和固定应用
- **Spaces 绑定** — 将工作区绑定到 macOS Spaces，实现自动切换
- **自定义快捷键** — 分配键盘快捷键（如 Cmd+Opt+1）快速切换
- **快速切换** — 通过菜单栏快速切换工作区

### 主题引擎
- **3 个内置主题** — 暗色、亮色、极简
- **完整主题编辑器** — 自定义颜色、圆角、模糊、阴影、图标间距
- **导入 / 导出** — 以 `.dmtheme` 文件格式分享主题
- **自定义图标包** — 每个应用可单独替换图标
- **实时预览** — 迷你 Dock 实时预览主题效果

### 快速搜索
- **类 Spotlight 搜索** — 搜索应用、文件、文档、书签和最近项目
- **键盘导航** — 方向键导航，回车键打开
- **最近项目视图** — 搜索框为空时显示最近使用的项目
- **全局快捷键** — Option+Space 打开

### 系统监控小组件
- **CPU 和内存** — 迷你环形图表显示使用百分比
- **网络速度** — 实时下载/上传速度
- **可展开** — 点击查看详细指标

### 原生 Dock 替换
- **隐藏 macOS Dock** — 无缝替换系统原生 Dock
- **退出时自动恢复** — 退出应用时恢复原始 Dock 设置

### 菜单栏集成
- **菜单栏图标** — 可配置图标（Dock、网格、圆形、星形）
- **工作区切换器** — 快速访问所有工作区
- **设置入口** — 一键打开偏好设置

### 国际化
- **4 种语言** — 英语、简体中文、繁体中文、日语
- **应用内切换** — 无需重启即可切换语言

## 系统要求

- macOS 13.0 (Ventura) 或更高版本
- Apple Silicon (arm64)

## 安装

### 从 Release 安装
从 [Releases](https://github.com/qianmoQ/DockMaster/releases) 下载最新的 `.zip` 文件，解压后将 `DockMaster Pro.app` 拖入应用程序文件夹。

### 从源码构建

```bash
# 克隆仓库
git clone https://github.com/qianmoQ/DockMaster.git
cd DockMaster

# Release 构建
./build.sh

# Debug 构建
./build.sh --debug

# 带代码签名构建
./build.sh --sign "Developer ID Application: Your Name (TEAMID)"
```

构建后的应用位于 `build/DockMaster Pro.app`。

## 权限

DockMaster Pro 需要以下权限：

- **辅助功能** — 控制 Dock 进程和管理其他应用
- **Apple 事件** — 启动和与其他应用交互

请在 **系统设置 > 隐私与安全性 > 辅助功能** 中授予权限。

## 项目结构

```
DockMasterPro/
├── App/                    # 入口点与应用代理
├── Core/                   # 业务逻辑引擎
│   ├── DockEngine/         # Dock 布局管理
│   ├── ThemeEngine/        # 主题加载、编辑、导入/导出
│   ├── WorkspaceManager/   # 工作区 CRUD 与切换
│   ├── SearchEngine/       # 全局搜索控制器
│   └── SystemMonitor/      # CPU、内存、网络监控
├── Features/               # UI 功能模块
│   ├── DockOverlay/        # 主 Dock 覆盖层 UI
│   ├── QuickSearch/        # 类 Spotlight 搜索面板
│   ├── StatusWidget/       # 系统监控小组件
│   └── ContextMenu/        # 右键上下文菜单
├── Settings/               # 偏好设置 UI 与视图模型
├── Models/                 # 数据模型与偏好设置
├── Services/               # 系统集成服务
├── Support/                # 国际化、错误、日志
└── Extensions/             # SwiftUI 与 AppKit 扩展
```

## 许可证

MIT 许可证。详见 [LICENSE](LICENSE) 文件。
