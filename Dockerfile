FROM golang:1.15.0-buster

COPY template/sources.list /etc/apt/sources.list

RUN apt-get update -y  && apt-get upgrade -y

RUN curl -O https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh && bash script.deb.sh

ARG UPX_VER=3.96
ARG APP_IMAGE_VER=12
ARG MIGRATE_VERSION=v4.12.2

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

RUN go get -u -d github.com/golang-migrate/migrate/cmd/migrate && \
    cd $GOPATH/src/github.com/golang-migrate/migrate/cmd/migrate && \
    git checkout $MIGRATE_VERSION && \
    go build -tags 'postgres' -ldflags="-X main.Version=$(git describe --tags)" -o $GOPATH/bin/migrate $GOPATH/src/github.com/golang-migrate/migrate/cmd/migrate && \
    cp $GOPATH/bin/migrate /usr/bin/migrate

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
    rm -rf $GOPATH/src && \
    rm -rf /var/lib/apt/lists/* && \
    rm /tmp/appimagetool.AppImage

RUN /usr/bin/upx --help
RUN /usr/bin/appimagetool --help
RUN /usr/bin/migrate --help
