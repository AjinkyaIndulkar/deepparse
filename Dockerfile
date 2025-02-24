# syntax = docker/dockerfile:experimental
FROM pytorch/pytorch:1.11.0-cuda11.3-cudnn8-runtime

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --upgrade pip
RUN CFLAGS="-g0 -Os -DNDEBUG -Wl,--strip-all -I/usr/include:/usr/local/include -L/usr/lib:/usr/local/lib" \
    DEEPPARSE_RELEASE_BUILD=1 \
    pip3 install --no-cache-dir \
    --compile \
    --global-option=build_ext \
    --global-option="-j 4" \
    --no-deps -U git+https://github.com/GRAAL-Research/deepparse.git@stable

RUN find /opt/conda/lib/ -follow -type f -name '*.a' -delete \
    && find /opt/conda/lib/ -follow -type f -name '*.pyc' -delete \
    && find /opt/conda/lib/ -follow -type f -name '*.txt' -delete \
    && find /opt/conda/lib/ -follow -type f -name '*.mc' -delete \
    && find /opt/conda/lib/ -follow -type f -name '*.js.map' -delete \
    && find /opt/conda/lib/ -name '*.c' -delete \
    && find /opt/conda/lib/ -name '*.pxd' -delete \
    && find /opt/conda/lib/ -follow -type f -name '*.md' -delete \
    && find /opt/conda/lib/ -follow -type f -name '*.png' -delete \
    && find /opt/conda/lib/ -follow -type f -name '*.jpg' -delete \
    && find /opt/conda/lib/ -follow -type f -name '*.jpeg' -delete \
    && find /opt/conda/lib/ -name '*.pyd' -delete \
    && find /opt/conda/lib/ -name '__pycache__' | xargs rm -r

ENV PATH /opt/conda/bin:$PATH