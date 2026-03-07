# OpenClaw Windows Installer

[![Release](https://img.shields.io/github/v/release/ANKCHEN2024/openclaw_win?include_prereleases)](https://github.com/ANKCHEN2024/openclaw_win/releases)
[![License](https://img.shields.io/github/license/ANKCHEN2024/openclaw_win)](LICENSE)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-2026.3.2-green)](https://docs.openclaw.ai/)

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

1. 前往 [Releases](https://github.com/ANKCHEN2024/openclaw_win/releases) 页面
2. 下载最新版本的 `OpenClaw_Setup_v*.exe`
3. 双击运行安装程序
4. 按照安装向导完成安装
5. 安装完成后会自动打开控制面板

### 方式二：从源码构建

```bash
# 克隆仓库
git clone https://github.com/ANKCHEN2024/openclaw_win.git
cd openclaw_win

# 下载依赖到 redist 目录
# Node.js 22.x MSI: https://nodejs.org/en/download/

# 编译安装程序（需要 Inno Setup 6）
# 打开 OpenClaw_Installer/scripts/OpenClaw_Setup.iss 编译
```

## 下载链接

| 文件 | 说明 | 下载地址 |
|------|------|----------|
| OpenClaw_Setup_v*.exe | 完整安装包 | [Releases](https://github.com/ANKCHEN2024/openclaw_win/releases) |
| Node.js 22.x MSI | Node.js 安装包 | [nodejs.org](https://nodejs.org/en/download/) |

## 项目结构

```
openclaw_win/
├── OpenClaw_Installer/
│   ├── bin/                 # 可执行文件
│   ├── docs/                # 文档
│   ├── redist/              # 依赖包（需下载）
│   ├── scripts/             # 安装脚本
│   ├── output/              # 输出目录
│   └── api-guide.html       # API 接入指南
├── .gitignore
├── README.md
└── LICENSE
```

## API 接入指南

安装完成后，程序会提示打开 API 接入指南，包含：

- **阿里云百炼** - Qwen 系列模型配置（新用户 100 万 tokens 免费额度）
- **硅基流动** - DeepSeek、Qwen 等模型配置（注册送约 2000 万 tokens）
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

# 设置 API Key (硅基流动)
npx openclaw config set providers.siliconflow.apiKey "your-api-key"

# 设置 API Key (阿里云百炼)
npx openclaw config set providers.dashscope.apiKey "your-api-key"

# 切换模型
npx openclaw config set agents.defaults.model "siliconflow"
```

## 相关链接

- [OpenClaw 官方文档](https://docs.openclaw.ai/)
- [阿里云百炼](https://dashscope.aliyuncs.com/)
- [硅基流动](https://siliconflow.cn)

## 许可证

[MIT License](LICENSE)

## 贡献

欢迎提交 Issue 和 Pull Request！

## 免责声明

本项目仅供学习和研究使用。使用前请阅读 OpenClaw 官方文档和各 AI 服务提供商的使用条款。
