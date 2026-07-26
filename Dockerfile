FROM ghcr.io/linuxserver/baseimage-selkies:ubuntunoble-7dd71f2f-ls145

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    ELECTRON_DISABLE_GPU=1 \
    ELECTRON_DISABLE_SANDBOX=1 \
    QT_QPA_PLATFORM=xcb \
    TITLE=百度网盘 \
    CUSTOM_PORT=14500

VOLUME /data
VOLUME /config

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        dbus-x11 \
        fonts-noto-cjk \
        libasound2t64 \
        libgbm1 \
        libgtk-3-0 \
        libnss3 \
        libsecret-1-0 \
        libxss1 \
        locales \
        xz-utils \
    && locale-gen zh_CN.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/helium && \
    curl -L https://github.com/imputnet/helium-linux/releases/download/0.7.10.1/helium-0.7.10.1-x86_64_linux.tar.xz | tar xJ -C /usr/local/helium --strip-components=1

RUN curl -4Lo /tmp/baidunetdisk.deb http://wppkg.baidupcs.com/issue/netdisk/LinuxGuanjia/4.17.7/baidunetdisk_4.17.7_amd64.deb && \
    dpkg -x /tmp/baidunetdisk.deb / && \
    rm -f /tmp/baidunetdisk.deb

COPY /root /

RUN chmod +x /usr/local/bin/start-baidu-netdisk

EXPOSE 14500
