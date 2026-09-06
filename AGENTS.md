# G2rain Deploy 协作约定

## 项目定位

本仓库负责 G2rain 平台的 Docker Compose 编排、首次初始化、服务启停、源码镜像构建、持续更新和业务部署扩展。脚本会操作源码目录、容器、镜像、网络、数据与密钥，修改前必须先确认作用范围。

## 工作入口

- 先阅读 `docs/index.md`、`docs/project.yaml` 和任务涉及的运维、安全文档。
- 以 Shell 脚本、Compose 文件、`services.conf`、扩展片段和配置模板为当前行为事实来源。
- 修改参数、服务映射、Compose 合并、数据卷、端口、健康检查、密钥或清理行为时，同步更新 `docs/`。
- 不执行 `start.sh`、`stop.sh --cleanup`、`update.sh`、`init-once.sh` 或生成密钥脚本，除非用户明确授权对应环境和影响范围。

## 安全验证

```shell
bash -n init-once.sh start.sh stop.sh update.sh
docker compose --env-file env.example -f docker-compose.yml config
docker compose --env-file env.example -f compose-v2/compose.yaml --project-directory . config
```

以上仅做静态解析；运行部署命令前还必须检查 `.env`、目标 Docker Context、数据备份和服务清单。

## 完成标准

- V1/V2 编排和业务片段保持一致，服务映射可解析。
- Shell 语法与 Compose 配置验证通过。
- 不提交真实凭据、生产私钥、运行时 `.env`、日志、数据、源码 checkout 或安装标记。
- 明确说明是否真正启动过容器、验证过健康状态或执行过回滚。
