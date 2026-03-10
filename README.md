# OpenClaw Windows 部署指南

[![License](https://img.shields.io/github/license/ANKCHEN2024/openclaw_win)](LICENSE)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-2026.3.8-green)](https://docs.openclaw.ai/)

OpenClaw AI Gateway Windows 部署指南和配置工具

## 简介

OpenClaw 是一个自托管的 AI Gateway，可以将 WhatsApp、Telegram、Discord、iMessage 等聊天应用连接到 AI 编码助手。本项目提供 Windows 平台的部署指南和配置工具。

## 功能特性

- **官方命令安装** - 使用 `npm install -g openclaw` 官方命令安装
- **可视化配置** - 中文安装向导和升级向导网页
- **自动监测** - 安装过程自动监测和日志显示
- **网页配置** - 在浏览器中完成所有配置
- **自动升级** - 一键检查更新并升级到最新版本
- **API 接入指南** - 内置阿里云百炼、硅基流动配置指南

## 系统要求

- Windows 10/11 (64-bit)
- Node.js 22.x 或更高版本
- 管理员权限（用于安装 Node.js）

## 快速开始

### 第一步：安装 Node.js

1. 下载 Node.js 22.x LTS 版本：[https://nodejs.org/en/download/](https://nodejs.org/en/download/)
2. 运行安装程序，按默认设置完成安装

### 第二步：安装 OpenClaw

使用官方命令安装最新版本：

```bash
npm install -g openclaw@latest
```

### 第三步：运行安装向导

1. 下载本项目的 `install-wizard.html` 文件
2. 双击打开 `install-wizard.html`
3. 按照向导完成环境检查和配置

或者手动配置：

```bash
# 运行诊断修复
npx openclaw doctor --fix

# 设置网关模式
npx openclaw config set gateway.mode local

# 设置身份验证模式
npx openclaw config set gateway.auth.mode none

# 设置 Agent 权限
npx openclaw config set agents.defaults.permissions.allowBrowser true
npx openclaw config set agents.defaults.permissions.allowReadFiles true
npx openclaw config set agents.defaults.permissions.allowWriteFiles true
npx openclaw config set agents.defaults.permissions.allowExecute true
npx openclaw config set agents.defaults.permissions.allowTerminal true
```

### 第四步：启动 Gateway

```bash
npx openclaw gateway
```

然后打开浏览器访问：http://127.0.0.1:18789/

## 项目结构

```
openclaw_win/
├── OpenClaw_Installer/
│   ├── redist/              # 依赖包
│   ├── scripts/             # PowerShell 脚本
│   ├── api-guide.html       # API 接入指南
│   ├── install-wizard.html  # 安装向导
│   └── upgrade-wizard.html  # 升级向导
├── .gitignore
├── README.md
└── LICENSE
```

## 使用安装向导

### 安装向导 (`install-wizard.html`)

提供可视化的安装流程：

1. **环境检查** - 自动检测 Node.js、NPM、网络连接等
2. **安装 OpenClaw** - 显示安装进度和日志
3. **基础配置** - 网关模式、身份验证、Agent 权限等
4. **完成** - 启动网关、查看文档、打开控制面板

### 升级向导 (`upgrade-wizard.html`)

提供一键升级功能：

1. **版本检查** - 检测当前版本和最新版本
2. **更新日志** - 显示新功能、修复、优化内容
3. **自动升级** - 备份、下载、安装、迁移、验证
4. **重启网关** - 升级完成后重启服务

## API 接入指南

安装完成后，打开 `api-guide.html` 查看详细的 API 配置指南：

- **阿里云百炼** - Qwen 系列模型配置（新用户 100 万 tokens 免费额度）
- **硅基流动** - DeepSeek、Qwen 等模型配置（注册送约 2000 万 tokens）
- **模型推荐** - 高性价比模型推荐
- **费用参考** - 各平台免费额度和定价

## 配置说明

默认配置：

| 配置项 | 值 |
|--------|-----|
| Agent 权限 | FULL (完全权限) |
| 身份验证 | 无验证 (None) |
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

# 检查更新
npm view openclaw version

# 升级 OpenClaw
npm install -g openclaw@latest
```

## 升级 OpenClaw

### 方式一：使用升级向导

1. 打开 `upgrade-wizard.html`
2. 点击"检查更新"
3. 如有新版本，点击"立即升级"
4. 升级完成后重启网关

### 方式二：命令行升级

```bash
# 升级到最新版本
npm install -g openclaw@latest

# 运行诊断修复
npx openclaw doctor --fix

# 重启网关
npx openclaw gateway
```

## 相关链接

- [OpenClaw 官方文档](https://docs.openclaw.ai/)
- [阿里云百炼](https://dashscope.aliyuncs.com/)
- [硅基流动](https://cloud.siliconflow.cn/i/XT034RLE)

## 许可证

[MIT License](LICENSE)

## 贡献

欢迎提交 Issue 和 Pull Request！

## 免责声明

本项目仅供学习和研究使用。使用前请阅读 OpenClaw 官方文档和各 AI 服务提供商的使用条款。
