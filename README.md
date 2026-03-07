# OpenClaw Windows Installer

OpenClaw AI Gateway Windows 自动部署安装程序

## 简介

OpenClaw 是一个自托管的 AI Gateway，可以将 WhatsApp、Telegram、Discord、iMessage 等聊天应用连接到 AI 编码助手。本项目提供 Windows 平台的一键安装部署方案。

## 功能特性

- **一键安装** - 自动安装 Node.js 22 和 OpenClaw
- **离线部署** - 所有依赖预下载，支持离线安装
- **中文界面** - 完整的中文安装向导
- **自动配置** - Agent FULL 权限、禁用 Token 认证
- **开机自启** - 可选的开机自动启动功能
- **API 接入指南** - 内置阿里云百炼、硅基流动配置指南

## 系统要求

- Windows 10/11 (64-bit)
- 管理员权限

## 快速开始

### 方式一：下载安装包（推荐）

1. 从 [Releases](../../releases) 页面下载最新的 `OpenClaw_Setup_v*.exe`
2. 双击运行安装程序
3. 按照安装向导完成安装
4. 安装完成后会自动打开控制面板

### 方式二：从源码构建

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/openclaw-win.git
cd openclaw-win

# 下载依赖
cd OpenClaw_Installer/redist
# 下载 Node.js 22.x MSI: https://nodejs.org/

# 编译安装程序（需要 Inno Setup 6）
# 打开 OpenClaw_Installer/scripts/OpenClaw_Setup.iss 编译
```

## 项目结构

```
openclaw-win/
├── OpenClaw_Installer/
│   ├── bin/                 # 可执行文件
│   ├── docs/                # 文档
│   ├── redist/              # 依赖包（需下载）
│   │   ├── node-v22.x-x64.msi
│   │   └── ...
│   ├── scripts/             # 安装脚本
│   │   ├── OpenClaw_Setup.iss
│   │   ├── install.ps1
│   │   └── ...
│   ├── output/              # 输出目录
│   └── api-guide.html       # API 接入指南
├── .gitignore
├── README.md
└── LICENSE
```

## API 接入指南

安装完成后，程序会提示打开 API 接入指南，包含：

- **阿里云百炼** - Qwen 系列模型配置
- **硅基流动** - DeepSeek、Qwen 等模型配置
- **模型推荐** - 高性价比模型推荐
- **费用参考** - 各平台免费额度和定价

## 配置说明

安装后默认配置：

| 配置项 | 值 |
|--------|-----|
| Agent 权限 | FULL (完全权限) |
| Token 认证 | 已禁用 |
| 控制面板 | http://127.0.0.1:18789/ |
| 配置文件 | `%APPDATA%\.openclaw\openclaw.json` |

## 常用命令

```bash
# 启动 Gateway
npx openclaw gateway

# 查看配置
npx openclaw config list

# 设置 API Key
npx openclaw config set providers.siliconflow.apiKey "your-api-key"

# 切换模型
npx openclaw config set agents.defaults.model "siliconflow"
```

## 相关链接

- [OpenClaw 官方文档](https://docs.openclaw.ai/)
- [阿里云百炼](https://dashscope.aliyuncs.com/)
- [硅基流动](https://siliconflow.cn)

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 免责声明

本项目仅供学习和研究使用。使用前请阅读 OpenClaw 官方文档和各 AI 服务提供商的使用条款。
