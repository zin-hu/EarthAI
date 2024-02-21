FROM ubuntu:22.04
RUN apt-get update \
    && apt-get install -y \
        python3 \
        python3-pip \
        python3-gdal \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && export CPLUS_INCLUDE_PATH=/usr/include/gdal \
    && export C_INCLUDE_PATH=/usr/include/gdal
CMD ["/bin/bash"]

# docker build -t earth:0.1 .
# docker run -it --name earth -v $(pwd)/earthAI:/root/earthAI -d earth:0.1