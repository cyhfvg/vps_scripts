# External Scripts

外部脚本统一存放在 `external_scripts/`。`download/` 仅作为临时测试目录使用，不参与脚本更新或运行。

更新方式：

```bash
bash scripts/update_scripts/update_external_scripts.sh
```

更新器会先备份现有 `external_scripts/` 到 `backups/external_scripts/<timestamp>/`，再按 `config/external_scripts.conf` 更新。

## 清单

| 本地文件 | 来源 | 用途 |
| --- | --- | --- |
| `yabs.sh` | `https://yabs.sh` | YABS 综合性能测试 |
| `ip_check_place.sh` | `IP.Check.Place` | XY-IP 质量体检 |
| `net_check_place.sh` | `Net.Check.Place` | XY 网络质量检测 |
| `nodeloc_aggregate.sh` | `abc.sd` | NodeLoc 聚合测试 |
| `ecs.sh` | `https://gitlab.com/spiritysdx/za/-/raw/main/ecs.sh` | 融合怪测试 |
| `media_unlock_test.sh` | `media.ispvps.com` | 应用解锁测试 |
| `curltime.sh` | `https://nodebench.mereith.com/scripts/curltime.sh` | 响应时间测试 |
| `ssh_tool.sh` | `https://raw.githubusercontent.com/eooce/ssh_tool/main/ssh_tool.sh` | SSH 工具箱 |
| `jcnfbox.sh` | `https://raw.githubusercontent.com/Netflixxp/jcnf-box/main/jcnfbox.sh` | Jcnf 常用工具包 |
| `kejilion.sh` | `https://raw.githubusercontent.com/kejilion/sh/main/kejilion.sh` | 科技 Lion 工具箱 |
| `box.sh` | `https://raw.githubusercontent.com/BlueSkyXN/SKY-BOX/main/box.sh` | BlueSkyXN 工具箱 |
| `speedtest.sh` | `https://raw.githubusercontent.com/i-abc/Speedtest/main/speedtest.sh` | 三网测速 |
| `AutoTrace.sh` | `https://raw.githubusercontent.com/Chennhaoo/Shell_Bash/master/AutoTrace.sh` | AutoTrace 三网回程路由 |
| `memoryCheck.sh` | `https://raw.githubusercontent.com/uselibrary/memoryCheck/main/memoryCheck.sh` | 超售检测 |
| `sing-box-yg.sh` | `https://raw.githubusercontent.com/yonggekkk/sing-box-yg/main/sb.sh` | 勇哥 Singbox |
| `fscarmen-sing-box.sh` | `https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh` | Fscarmen Singbox |
| `x-ui-yg.sh` | `https://gitlab.com/rwkgyg/x-ui-yg/raw/main/install.sh` | 勇哥 X-UI |
| `3x-ui.sh` | `https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh` | 3X-UI 官方 |
| `3x-ui-optimized.sh` | `https://raw.githubusercontent.com/xeefei/3x-ui/master/install.sh` | 3X-UI 优化版 |
| `nezha-agent-cleaner.sh` | `https://raw.githubusercontent.com/everett7623/Nezha-cleaner/main/nezha-agent-cleaner.sh` | 哪吒 Agent 清理 |

## 静态审查摘要

未发现直接静默植入后门的典型模式，例如硬编码添加 SSH 公钥、隐藏新增管理员用户、反弹 shell、清理 shell 历史以掩盖痕迹等。

需要注意的高风险行为：

- `ssh_tool.sh` 功能非常宽，会修改 root 密码、开启 root SSH 登录、调整防火墙、添加 cron、下载并执行大量二级脚本，还包含大范围删除系统组件的功能菜单。
- `sing-box-yg.sh` 会禁用/清空防火墙规则、写入 cron、自启服务、后台运行 cloudflared/代理相关进程。
- `fscarmen-sing-box.sh`、`3x-ui.sh`、`3x-ui-optimized.sh` 会安装并启用系统服务，下载发行版二进制和 systemd/init 脚本。
- `ecs.sh`、`nodeloc_aggregate.sh`、`jcnfbox.sh`、`box.sh`、`net_check_place.sh`、`ip_check_place.sh` 内部仍有二级远程下载执行入口。
- `AutoTrace.sh` 会下载 besttrace、nexttrace、curl-impersonate 等二进制组件。

这些行为符合对应工具的功能定位，但运行前应按需逐项确认，不建议在生产机器上无交互批量执行。
