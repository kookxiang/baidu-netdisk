FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    ELECTRON_DISABLE_GPU=1 \
    ELECTRON_DISABLE_SANDBOX=1 \
    QT_QPA_PLATFORM=xcb \
    XDG_RUNTIME_DIR=/tmp/runtime-root

VOLUME /data
VOLUME /root/.config/baidunetdisk

RUN apt-get update && \
    apt-get install --no-install-recommends -y ca-certificates curl && \
    curl -fsSL https://xpra.org/xpra.asc -o /usr/share/keyrings/xpra.asc && \
    curl -fsSL https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/noble/xpra-lts.sources -o /etc/apt/sources.list.d/xpra-lts.sources && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        dbus-x11 \
        locales \
        xpra \
        xpra-html5 \
        xpra-x11 \
        xauth \
        openbox \
        fonts-noto-cjk \
        libnss3 \
        libasound2t64 \
        libgtk-3-0 \
        libatk-bridge2.0-0 \
        libatk1.0-0 \
        libatspi2.0-0 \
        libsecret-1-0 \
        libcolord2 \
    && locale-gen zh_CN.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -4Lo /tmp/baidunetdisk.deb http://wppkg.baidupcs.com/issue/netdisk/LinuxGuanjia/4.17.7/baidunetdisk_4.17.7_amd64.deb && \
    dpkg -x /tmp/baidunetdisk.deb / && \
    rm -f /tmp/baidunetdisk.deb

EXPOSE 14500

CMD xpra start :100 \
      --bind-tcp=0.0.0.0:14500 \
      --html=on \
      --daemon=no \
      --exit-with-children \
      --printing=no \
      --file-transfer=no \
      --audio=no \
      --pulseaudio=no \
      --notifications=no \
      --system-tray=no \
      --mdns=no \
      --sharing=yes \
      --lock=no \
      --headerbar=no \
      --start-child="/opt/baidunetdisk/baidunetdisk --no-sandbox"