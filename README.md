# 百度网盘 Docker 容器

这是一个为偶尔使用的百度网盘 Linux 客户端准备的轻量 Docker 封装，目标是「干净、可一次性运行、无需长期在宿主机上常驻」。镜像在构建时会从网络下载百度网盘的 Linux .deb 包并解包到镜像中，运行时通过 `xpra` 提供 HTML5 访问界面。

## ✨ 功能特性

- ⚡ **按需启动** - 只在需要时启动客户端，不占用长期桌面资源
- 🌐 **Web 访问** - 通过 `xpra` 暴露 HTML5 界面，浏览器直接访问
- 📁 **持久化存储** - 自动挂载下载数据目录和用户配置目录
- 🔐 **轻量隔离** - 完整的容器隔离，保护主机环境
- 🔄 **自动清理** - 支持一次性运行或长期服务模式

## 前置要求

- **Docker** 18.06+ 或 **Podman** 3.0+
- 至少 **2GB** 可用空间
- 支持的系统：Linux（推荐）、macOS、Windows（WSL2）

## 快速开始

### 方式一：Docker 直接运行（推荐新手）

最简单的使用方式：

```bash
docker run --rm -it \
    -p 14500:14500 \
    -v /path/to/local/data:/data \
    -v /path/to/local/config:/root/.config/baidunetdisk \
    ghcr.io/kookxiang/baidu-netdisk:master
```

然后在浏览器打开 `http://{YOUR_IP_ADDRESS}:14500/` 即可通过 xpra 的 HTML5 界面访问百度网盘应用。

**参数说明：**
- `-p 14500:14500` - 映射 xpra 服务端口
- `-v /path/to/local/data:/data` - 挂载本地下载目录（可选）
- `-v /path/to/local/config:/root/.config/baidunetdisk` - 挂载配置目录以保持登录状态

**首次使用必须操作：**

首次运行时需要在百度网盘的设置界面中手动选择下载路径，将其指向 `/data` 目录。否则默认会下载到容器内部目录，重启后会丢失。

### 方式二：Podman + Systemd 按需运行（推荐生产环境）

该方案自动在需要时启动容器，空闲后自动关闭，适合长期运行的场景。

**配置步骤：**

1. 复制示例配置文件：

```bash
# 用户级别运行（理论可行，没测试过）
mkdir -p ~/.config/systemd/user/
cp etc/systemd/system/* ~/.config/systemd/user/
cp etc/containers/systemd/* ~/.config/containers/systemd/

# 或系统级别运行（推荐）
sudo cp etc/systemd/system/* /etc/systemd/system/
sudo cp etc/containers/systemd/* /etc/containers/systemd/
```

2. 根据实际情况编辑配置文件（镜像地址、挂载路径等）

3. 启用并启动服务：

```bash
systemctl daemon-reload
systemctl enable --now baidu-netdisk-proxy.socket
```

**推荐配置：**
- 修改 `baidu-netdisk.container` 中下载目录和配置目录（默认保存至 named volume 中）
- 如需修改端口，只需要修改 `baidu-netdisk-proxy.socket` 中的端口配置，不需要修改容器内部的端口

**工作原理：**

```
用户访问 :14500
    ↓
baidu-netdisk-proxy.socket 拦截
    ↓
自动启动 baidu-netdisk-proxy.service
    ↓
依次启动 baidu-netdisk.service (Quadlet 容器)
    ↓
应用正常提供服务
    ↓
空闲 12 小时后自动停止整个服务链
```

## 高级配置

### 数据卷挂载

建议的挂载策略：

| 挂载点 | 用途 | 是否必须 | 说明 |
|-------|------|--------|------|
| `/data` | 下载文件存储 | ✓ 推荐 | 存放百度网盘下载的文件 |
| `/root/.config/baidunetdisk` | 应用配置 | ✓ 推荐 | 保存登录状态和偏好设置 |

## 本地构建镜像

如果需要修改镜像或使用最新代码：

```bash
docker build -t baidu-netdisk:local .

# 然后运行时使用
docker run --rm -it -p 14500:14500 baidu-netdisk:local
```

## 常见问题

### Q: 为什么连接后无法看到应用窗口？
A: 可能是 xpra 初始化缓慢。请等待 10-15 秒，然后刷新浏览器页面。

### Q: 如何修改下载目录？
A: 修改 `-v` 参数中的 `/path/to/local/data` 为实际的本地目录路径。

### Q: Systemd 方案无法启动怎么办？
A: 运行以下命令查看日志：
```bash
# 查看 socket 状态
systemctl status baidu-netdisk-proxy.socket

# 查看详细日志
journalctl -u baidu-netdisk-proxy.socket -xn
journalctl -u baidu-netdisk-proxy.service -xn
```

### Q: 容器占用太多磁盘空间？
A: 检查 `/root/.config/baidunetdisk` 下是否有缓存文件，可以安全删除。

## 安全与隐私

⚠️ **重要提示**

- 不建议直接对外提供服务（如暴露到互联网）
- 推荐在内网环境或通过 Nginx/反向代理等方式访问
- 确保定期备份重要配置（`.config/baidunetdisk` 目录）
- 容器内默认以 root 身份运行，请在可信环境中使用

## 许可证

MIT License - 详见 LICENSE 文件

## 贡献

欢迎提交 Issue 和 Pull Request！
