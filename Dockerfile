ARG PYTORCH="1.10.0"
ARG CUDA="11.3"
ARG CUDNN="8"

FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-devel

ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"

# To fix GPG key error when running apt-get update
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

RUN apt-get update && apt-get install -y git ninja-build libglib2.0-0 libsm6 libxrender-dev libxext6 libgl1-mesa-glx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN pip install -U pip

RUN conda clean --all

RUN pip install \
    numpy==1.21 \
    tqdm \
    open3d==0.9.0.0 \
    einops==0.3.2 \
    scikit-learn==1.0.1 \
    tqdm==4.62.3 \
    h5py==3.6.0

# Install Grad-PU
RUN apt update
RUN apt install -y cmake libcgal-dev
ADD . /Grad-PU
RUN cd /Grad-PU/models/Chamfer3D && python setup.py install
RUN cd /Grad-PU/models/pointops && python setup.py install
RUN cd /Grad-PU/evaluation_code && /bin/bash compile.sh

WORKDIR /Grad-PU
