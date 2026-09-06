# 本地开发

文档和脚本开发可在不连接 Docker Engine 的情况下完成大部分静态检查。推荐在 Linux 或 Git Bash 环境验证 Bash 行为，并同时解析两套 Compose 配置。

```shell
bash -n init-once.sh start.sh stop.sh update.sh
bash -n compose-cli-preference.inc compose-merge.inc services-merge.inc
docker compose --env-file env.example -f docker-compose.yml config
docker compose --env-file env.example -f compose-v2/compose.yaml --project-directory . config
```

业务片段还需与主配置一起解析。不要为了测试脚本而在开发者的默认 Docker Context 中执行真实 `up`、`down`、`prune`、克隆或构建动作。
