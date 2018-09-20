FROM golang:1.11.0-stretch
RUN apt-get update -y  && apt-get upgrade -y

ARG UPX_VER=3.94

RUN apt-get install -y \
    xz-utils \ 
    hfsprogs \ 
    zip \ 
    golang-glide \ 
    build-essential \ 
    libgtk-3-dev \ 
    libwebkit2gtk-4.0-dev

RUN wget --quiet https://github.com/upx/upx/releases/download/v${UPX_VER}/upx-${UPX_VER}-amd64_linux.tar.xz 2>&1 && \
    tar -xJf ./upx-${UPX_VER}-amd64_linux.tar.xz && \
    mv upx-${UPX_VER}-amd64_linux/upx /usr/bin/ && \
    chmod +x /usr/bin/upx
