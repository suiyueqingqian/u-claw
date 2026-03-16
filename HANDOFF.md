# Handoff Document — U-Claw Linux Remote Access

## Current Status

- U盘已就绪：Ventoy + Ubuntu 24.04 ISO + persistence + u-claw-linux scripts
- 所有源码已推送到 GitHub main 分支
- website/guide.html 已添加快速命令参考卡片
- enable-ssh.sh 已添加到 bootable/linux-setup/

## Linux 启动后需要做的事

1. 从 U 盘启动 → Ventoy 菜单选 Ubuntu
2. 如果首次使用，格式化持久化：
   ```
   sudo bash /media/*/Ventoy/u-claw-linux/format-persistence.sh
   ```
   然后重启
3. 连接 WiFi
4. 安装 OpenClaw：
   ```
   sudo bash /media/*/Ventoy/u-claw-linux/setup-openclaw.sh
   ```
5. 启用 SSH（让 Mac mini 远程控制）：
   ```
   sudo bash /media/*/Ventoy/u-claw-linux/enable-ssh.sh
   ```

## SSH 连接信息

- **用户名**: ubuntu (Live USB 默认用户)
- **密码**: 运行 enable-ssh.sh 时设置
- **IP 地址**: 运行 enable-ssh.sh 后会显示，格式类似 192.168.x.x
- **前提**: 两台机器在同一个 WiFi/局域网下

## Mac mini Claude Code 接手方法

1. 用户在 Linux 上运行 `enable-ssh.sh`，获取 IP 和设置密码
2. 用户告诉 Mac mini 上的 Claude Code：IP 地址和密码
3. Mac mini Claude Code 通过 Bash 工具执行：
   ```
   ssh ubuntu@<IP> 'command'
   ```
   或建立持久连接进行调试

## 文件位置（Linux 上）

| 路径 | 说明 |
|------|------|
| `/media/*/Ventoy/u-claw-linux/` | U 盘上的脚本 |
| `/opt/u-claw/` | 安装后的 OpenClaw |
| `/opt/u-claw/start-openclaw.sh` | 启动脚本 |
| `/opt/u-claw/data/.openclaw/openclaw.json` | 配置文件 |

## 注意事项

- Live USB 每次重启后，除了持久化分区内的数据，其他都会重置
- SSH server 需要每次重启后重新安装（除非持久化生效）
- 持久化生效后，apt 安装的包会保留
