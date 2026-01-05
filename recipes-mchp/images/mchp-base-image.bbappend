IMAGE_INSTALL:append = "\
    packagegroup-mchp-apps \
    packagegroup-mchp-security \
"

IMAGE_INSTALL:append:mpfs-video-kit-h264:mpfs-video-kit-h264-mm  = " \
    ffmpeg \
    apache2 \
    php \
    php-cli \
    php-fpm \
    php-cgi \
    php-modphp \
    sudo \
    v4l2-start-service \
    v4l-utils \
    videokit-webdemo \
    fswebcam \
    x264 \
    python3-asyncua \
    openssl \
    openssl-engines \
"

