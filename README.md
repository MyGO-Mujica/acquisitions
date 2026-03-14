# 🚀 DevOps CI/CD 练手项目 (Practice Project)

这是一个专注于 DevOps 实践与业务落地的练手项目。主要目的是通过一个真实完整的 Node.js 后端应用，跑通从代码提交、代码规范检查，到 Docker 镜像构建，再到远程 Hub 推送的整套 CI/CD（持续集成 / 持续交付）自动化流水线。

## 🛠️ DevOps 核心实践要点

### 1. 自动化流水线 (GitHub Actions)

本项目重度依赖 GitHub Actions 实现了强大的自动化工作流：

- **CI (持续集成)**:
  - 接入 ESLint 规范拦截，确保每次提交代码的格式和质量标准。
  - 接入配合跨平台环境 (`cross-env`) 的 Jest 测试框架，实现自动化测试报告拦截。
- **CD (持续交付/部署)**:
  - 自动化配置：监听 `main` 分支的业务 Push 及 PR 操作。
  - 自动触发基于被优化的 `Dockerfile` 流水线构建（支持多架构如 `linux/amd64`, `linux/arm64`）。
  - 依托 GitHub Actions 的独立服务器环境，自动通过 Docker Hub 认证并推送镜像 (`Push`)，从而完成待部署发版。

### 2. 本地与生产容器化部署 (Dockerization)

- **环境绝对隔离**: 提供并拆分了本地开发和生产环境独立的 `docker-compose.dev.yml` 与 `docker-compose.prod.yml` 编排文件。
- **自动化起步脚本**: 提供适配 Windows 的 `scripts/dev.ps1` 和 `scripts/prod.ps1` 脚本，抹平多环境的起步差异，做到本地机器只需配置凭证即可一键拉起包括外部组件在内的服务。

### 3. 云级基础设施 (Infrastructure)

在基础微架构上完全适配云原生与 Serverless 要求：

- 结合 **Neon Serverless Postgres** 设置数据库，实现基础设施侧的 Branch (分支隔离) 并引入了全自动的数据表迁移 (Drizzle Kit Migrate)。
- 依托 **Arcjet** 安全防护网，通过安全策略组件防御 API 层面的僵尸流量 (Bot) 攻击。

---

## ⚙️ GitHub Actions CI/CD 配置要求

此库中的工作流包含了自动向 Docker Hub 推送。如果其他人 Fork 本项目，需在仓库的 `Settings -> Secrets and variables -> Actions` (Repository Secrets) 中配置以下变量以跑通 CD 流程：

- `DOCKER_USERNAME`: 你的 Docker Hub 登录用户名 (作为 Registry 命名空间)。
- `DOCKER_PASSWORD`: Docker Hub 签发的 Personal Access Token（需要确保拥有 `Read & Write` 也就是 push 的权限）。
