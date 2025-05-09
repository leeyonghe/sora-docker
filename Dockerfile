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
ENV PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:64,expandable_segments:True,garbage_collection_threshold:0.6
ENV CUDA_LAUNCH_BLOCKING=1
ENV OMP_NUM_THREADS=1
ENV MKL_NUM_THREADS=1
ENV PYTORCH_NO_CUDA_MEMORY_CACHING=1
ENV NCCL_DEBUG=INFO
ENV NCCL_IB_DISABLE=1
ENV NCCL_P2P_DISABLE=1
ENV TORCH_USE_CUDA_DSA=1
ENV PYTORCH_CUDA_ALLOC_CONF=backend=cudaMallocAsync
ENV CUDA_VISIBLE_DEVICES=0

# Install system dependencies
RUN echo 'Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::http::Timeout "120";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::https::Timeout "120";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::ftp::Timeout "120";' >> /etc/apt/apt.conf.d/80-retries && \
    sed -i 's/archive.ubuntu.com/ftp.daumkakao.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/ftp.daumkakao.com/g' /etc/apt/sources.list && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    python3.10 \
    python3.10-dev \
    python3.10-venv \
    python3-pip \
    build-essential \
    ninja-build \
    cmake \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set up Python
RUN ln -s /usr/bin/python3.10 /usr/bin/python
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

# Install Python dependencies
RUN pip install --no-cache-dir \
    packaging \
    setuptools>=64.0.0 \
    wheel \
    ninja \
    cmake \
    scikit-build \
    build

# Debug: Show Python and pip versions
RUN python --version && pip --version

# Set build environment variables
ENV MAX_JOBS=1
ENV CMAKE_BUILD_PARALLEL_LEVEL=1
ENV FORCE_CUDA=1
ENV TORCH_CUDA_ARCH_LIST="8.0;8.6;9.0"

# Install PyTorch first
RUN pip install --no-cache-dir \
    torch>=2.4.0 \
    torchvision \
    torchaudio \
    --extra-index-url https://download.pytorch.org/whl/cu121

# Install triton separately
RUN pip install --no-cache-dir triton==3.0.0

# Install xformers with memory optimizations
RUN pip install --no-cache-dir xformers==0.0.27.post2 --no-build-isolation

# Install flash-attn with minimal memory usage
RUN pip install --no-cache-dir \
    flash-attn==2.2.3.post2 \
    --no-build-isolation \
    --config-settings="--global-option=build_ext" \
    --config-settings="--global-option=-j1" \
    --no-deps

# Install tensornvme
RUN pip install --no-cache-dir git+https://github.com/hpcaitech/tensornvme.git

# Debug: Verify PyTorch installation
RUN python -c "import torch; print('PyTorch version:', torch.__version__); print('CUDA available:', torch.cuda.is_available())"

# Debug: Verify flash-attn installation
RUN python -c "import flash_attn; print('Flash Attention version:', flash_attn.__version__)"

# Set up workspace
WORKDIR /workspace

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Create necessary directories
RUN mkdir -p /workspace/ckpts /workspace/samples

# Default command
CMD ["/bin/bash"]
