# Build arguments
ARG CUDA_VERSION=12.1.1
ARG CUDNN_VERSION=8
ARG UBUNTU_VERSION=22.04
ARG PYTHON_VERSION=3.10
ARG TORCH_VERSION=2.4.0
ARG TORCHVISION_VERSION=0.19.0
ARG TORCHAUDIO_VERSION=2.4.0
ARG XFORMERS_VERSION=0.0.27.post2

FROM nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-runtime-ubuntu${UBUNTU_VERSION}

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set up Python
RUN ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python${PYTHON_VERSION}

# Install Python dependencies
RUN pip install --no-cache-dir \
    torch==${TORCH_VERSION} \
    torchvision==${TORCHVISION_VERSION} \
    torchaudio==${TORCHAUDIO_VERSION} \
    xformers==${XFORMERS_VERSION} \
    flash-attn \
    jupyter \
    ipywidgets \
    huggingface_hub \
    modelscope

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

# Expose Jupyter port
EXPOSE 8888

# Default command
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''"] 