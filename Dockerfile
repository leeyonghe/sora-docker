# Build arguments
ARG CUDA_VERSION=12.2.2
ARG UBUNTU_VERSION=22.04
ARG PYTHON_VERSION=3.10

FROM nvidia/cuda:${CUDA_VERSION}-cudnn8-devel-ubuntu${UBUNTU_VERSION}

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/workspace
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    python3.10 \
    python3.10-dev \
    python3.10-venv \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set up Python
RUN ln -s /usr/bin/python3.10 /usr/bin/python
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

# Install Python dependencies
RUN pip install --no-cache-dir \
    packaging \
    setuptools \
    wheel \
    ninja

# Install PyTorch and other dependencies
RUN pip install --no-cache-dir \
    torch>=2.4.0 \
    torchvision \
    torchaudio \
    xformers==0.0.27.post2 \
    --extra-index-url https://download.pytorch.org/whl/cu121

# Install flash-attn
RUN pip install --no-cache-dir flash-attn --no-build-isolation

# Install flash attention 3
RUN git clone https://github.com/Dao-AILab/flash-attention && \
    cd flash-attention && \
    git checkout 4f0640d5 && \
    cd hopper && \
    python setup.py install && \
    cd ../.. && \
    rm -rf flash-attention

# Set up workspace
WORKDIR /workspace

# Clone Open-Sora
RUN git clone https://github.com/hpcaitech/Open-Sora.git . && \
    pip install -v .

# Create necessary directories
RUN mkdir -p /workspace/ckpts /workspace/samples

# Default command
CMD ["/bin/bash"]
