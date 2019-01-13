FROM golang:1.11.4-stretch

ARG UPX_VER=3.94
ARG APP_IMAGE_VER=11

COPY template/sources.list /etc/apt/sources.list

RUN dpkg --add-architecture i386

RUN apt-get update -y && apt-get upgrade -y

RUN apt-get install -y \
    xz-utils \
    hfsprogs \
    zip \
    golang-glide \
    build-essential \
    appstream \
    gcc-multilib \
    libwebkit2gtk-4.0-dev \
    libgtk-3-dev \
    libsoup2.4-dev \
    libglib2.0-dev

RUN apt-get install -y \
    libwebkit2gtk-4.0-dev:i386 \
    pkg-config:i386 \
    libgtk-3-dev:i386 \
    libsoup2.4-dev:i386 \
    libgdk-pixbuf2.0-dev:i386 \
    libpango1.0-dev:i386 \
    libatk1.0-dev:i386 \
    libatk-bridge2.0-dev:i386 \
    libcairo2-dev:i386 \
    libfontconfig1-dev:i386 \
    libxkbcommon-dev:i386

RUN wget --quiet https://github.com/upx/upx/releases/download/v${UPX_VER}/upx-${UPX_VER}-amd64_linux.tar.xz 2>&1 && \
    tar -xJf ./upx-${UPX_VER}-amd64_linux.tar.xz && \
    mv upx-${UPX_VER}-amd64_linux/upx /usr/bin/ && \
    chmod +x /usr/bin/upx

RUN wget https://github.com/AppImage/AppImageKit/releases/download/${APP_IMAGE_VER}/appimagetool-x86_64.AppImage -O /tmp/appimagetool.AppImage && \
    chmod +x /tmp/appimagetool.AppImage

RUN mkdir -p /opt/appimagetool && \
    cd /opt/appimagetool && \
    /tmp/appimagetool.AppImage --appimage-extract

RUN ln -s /opt/appimagetool/squashfs-root/AppRun /usr/bin/appimagetool && \
    chmod +x /usr/bin/appimagetool

RUN apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm /tmp/appimagetool.AppImage

RUN /usr/bin/upx --help
RUN /usr/bin/appimagetool --help

