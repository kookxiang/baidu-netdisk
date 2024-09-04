FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble

ENV LANG=zh_CN.UTF-8

VOLUME /data

RUN \
    echo "precedence ::ffff:0:0/96 100" > /etc/gai.conf
    apt-get update && \
    apt-get install --no-install-recommends -y at-spi2-common fonts-noto-cjk fonts-noto-cjk-extra libatk-bridge2.0-0t64 libatk1.0-0t64 libatspi2.0-0t64 libcolord2 libgtk-3-0t64 libsecret-1-0 libsecret-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

RUN \
    mkdir -p /config/.config/baidunetdisk && \
    ln -fs /data /config/.config/baidunetdisk && \
    curl -4Lo baidunetdisk.deb https://pkg-ant.baidu.com/issue/netdisk/LinuxGuanjia/4.17.7/baidunetdisk_4.17.7_amd64.deb && \
    dpkg -x baidunetdisk.deb / && \
    rm -rf baidunetdisk.deb && \
    echo "/opt/baidunetdisk/baidunetdisk --no-sandbox" > /defaults/autostart
