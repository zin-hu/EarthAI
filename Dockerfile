FROM ubuntu:22.04
RUN apt-get update \
    && apt-get install -y \
        python3 \
        python3-venv \
        python3-pip \
        libgdal-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && export CPLUS_INCLUDE_PATH=/usr/include/gdal \
    && export C_INCLUDE_PATH=/usr/include/gdal
CMD ["/bin/bash"]
