#===============================================================================
#
# Copyright (c) 2020, NVIDIA CORPORATION. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ==============================================================================

ARG FROM_IMAGE_NAME=nvcr.io/nvidia/tensorflow:20.06-tf1-py3
FROM ${FROM_IMAGE_NAME}

ENV DEBIAN_FRONTEND=noninteractive

RUN rm -rf /workspace && mkdir -p /workspace
ADD . /workspace
WORKDIR /workspace

RUN apt-get update && \
    apt-get install -y libsm6 libxext6 libxrender-dev python3-tk cmake && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Make sure python and pip points to pip3 and python3
RUN python -m pip install --upgrade pip && \
    pip --no-cache-dir --no-cache install \
        Cython \
        matplotlib \
        opencv-python-headless \
        mpi4py \
        Pillow \
        pytest \
        pyyaml && \
    git clone https://github.com/pybind/pybind11 /opt/pybind11 && \
    cd /opt/pybind11 && cmake . && make -j96 install && pip install . && \
    pip --no-cache-dir --no-cache install \
        'git+https://github.com/NVIDIA/cocoapi#egg=pycocotools&subdirectory=PythonAPI' && \
    pip --no-cache-dir --no-cache install \
        'git+https://github.com/NVIDIA/dllogger'


# Update protobuf 3 to 3.3.0
RUN \
    curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v3.3.0/protoc-3.3.0-linux-x86_64.zip && \
    unzip -u protoc-3.3.0-linux-x86_64.zip -d protoc3 && \
    mv protoc3/bin/* /usr/local/bin/ && \
    mv protoc3/include/* /usr/local/include/

ARG OPEN_MPI_PATH=/opt/amazon/openmpi
ARG AMAZON_EFA_PATH=/opt/amazon/efa
ENV LD_LIBRARY_PATH=/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib:/usr/local/cuda/lib64:/opt/amazon/efa/lib:/opt/amazon/openmpi/lib:$LD_LIBRARY_PATH
ENV PATH=/opt/amazon/openmpi/bin/:$PATH

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y --allow-downgrades --allow-change-held-packages \
    --no-install-recommends \
    build-essential \
    wget \
    curl \
    vim \
    ssh \
    libboost-all-dev \
    python3 \
    python3-dev \
    python3-distutils \
    libssl-dev \
    coreutils \
    git \
    libudev-dev \
    dh-autoreconf

RUN apt-get install -y --no-install-recommends openssh-client openssh-server && \
  mkdir -p /var/run/sshd

# Make the installed python default
RUN rm -rf /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python

# Install pip
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

# Install EFA and OpenMPI
RUN cd /tmp && \
  curl -O https://s3-us-west-2.amazonaws.com/aws-efa-installer/aws-efa-installer-1.9.3.tar.gz && \
  tar -xf aws-efa-installer-1.9.3.tar.gz && \
  apt-get remove -y libmlx5-1 ibverbs-utils libibverbs-dev libibverbs1 && \
  export DEBIAN_FRONTEND=noninteractive && \
  cd aws-efa-installer && \
  yes y | ./efa_installer.sh -y --skip-kmod --skip-limit-conf --no-verify && \
  cd /tmp && \
  rm -rf aws-efa-installer && \
  echo export PATH="$OPEN_MPI_PATH/bin:$PATH" >> /root/.bashrc && \
  echo export LD_LIBRARY_PATH="$OPEN_MPI_PATH/lib:$AMAZON_EFA_PATH/lib:$LD_LIBRARY_PATH" >> /root/.bashrc && \
  source /root/.bashrc

RUN cd /tmp && \
  git clone https://github.com/NVIDIA/nccl.git -b v2.7.5-1 && \
  cd nccl && make -j64 src.build CUDA_HOME=/usr/local/cuda BUILDDIR=/usr/local NVCC_GENCODE="-gencode=arch=compute_70,code=sm_70 -gencode=arch=compute_60,code=sm_60" && \
  rm -rf /tmp/nccl

RUN cd /tmp && \
  git clone https://github.com/aws/aws-ofi-nccl.git -b aws && \
  cd aws-ofi-nccl && \
  ./autogen.sh && \
  ./configure --with-libfabric=/opt/amazon/efa --with-mpi=/opt/amazon/openmpi --with-cuda=/usr/local/cuda --with-nccl=/usr/local --prefix=/usr/local && \
  make && \
  make install && \
  rm -rf /tmp/aws-ofi-nccl

# Install CMAKE, MPI4PY
RUN pip install -U cmake mpi4py boto3>=1.14.3

RUN cd herring && \
    export LD_LIBRARY_PATH="$OPEN_MPI_PATH/lib:$AMAZON_EFA_PATH/lib:$LD_LIBRARY_PATH" && \
    export PATH="$OPEN_MPI_PATH/bin:$PATH" && \
    HERRING_TF=1 python setup.py develop

