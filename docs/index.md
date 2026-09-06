# g2rain-deploy 工程文档

本仓库是 G2rain 的交付与运维编排入口，用 Shell 和 Docker Compose 组织基础设施、平台后端、前端应用及可选业务模块。

## 导航

- [项目元数据](project.yaml)
- [本地工程基线](architecture/local-baseline.md)
- [架构与职责](architecture/overview.md)
- [部署拓扑](architecture/topology.md)
- [配置与合并模型](architecture/configuration-model.md)
- [运行流程](architecture/runtime-flows.md)
- [差异与风险](architecture/deviations.md)
- [命令参考](operations/commands.md)
- [首次安装](operations/installation.md)
- [启动、停止与更新](operations/lifecycle.md)
- [备份与回滚](operations/backup-and-rollback.md)
- [安全、密钥与数据](security/secrets-and-data.md)
- [本地开发](development/local-development.md)
- [Shell 与 Compose 约定](development/conventions.md)
- [验证策略](development/testing.md)
- [完成标准](development/definition-of-done.md)
- [Git 工作流](development/git-workflow.md)
- [需求记录](requirements/README.md)
- [架构决策](decisions/README.md)

## 当前验证

2026-09-06 已完成 10 个 Shell/Include 文件的 Bash 语法检查；Compose V1、V2 的主配置和默认 CMS 合并配置均可解析。未启动容器、未验证运行时健康状态，也未执行安装、更新、停止或清理操作。
