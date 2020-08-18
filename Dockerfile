FROM golang:1.14.0-stretch

COPY template/sources.list /etc/apt/sources.list

RUN apt-get update -y  && apt-get upgrade -y

RUN curl -O https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh && bash script.deb.sh

ARG UPX_VER=3.96
ARG APP_IMAGE_VER=12

RUN apt-get install -y \
    xz-utils \ 
    hfsprogs \ 
    zip \ 
    git-lfs \
    golang-glide \ 
    build-essential \ 
    libgtk-3-dev \ 
    libwebkit2gtk-4.0-dev \
    libc6-dev-i386 \
    appstream

RUN curl -L https://packagecloud.io/golang-migrate/migrate/gpgkey | apt-key add - && \
    echo "deb https://packagecloud.io/golang-migrate/migrate/ubuntu/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/migrate.list  && \
    apt-get update && \
    apt-get install -y migrate
    
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
    rm -rf /var/lib/apt/lists/* && \
    rm /tmp/appimagetool.AppImage

RUN /usr/bin/upx --help
RUN /usr/bin/appimagetool --help
RUN /usr/bin/migrate --help
