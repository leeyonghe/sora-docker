variable "CUDA_VERSION" {
  default = "12.1.1"
}

variable "CUDNN_VERSION" {
  default = "8"
}

variable "UBUNTU_VERSION" {
  default = "22.04"
}

variable "PYTHON_VERSION" {
  default = "3.10"
}

variable "TORCH_VERSION" {
  default = "2.4.0"
}

variable "TORCHVISION_VERSION" {
  default = "0.19.0"
}

variable "TORCHAUDIO_VERSION" {
  default = "2.4.0"
}

variable "XFORMERS_VERSION" {
  default = "0.0.27.post2"
}

group "default" {
  targets = ["opensora"]
}

target "opensora" {
  dockerfile = "Dockerfile"
  context = "."
  platforms = ["linux/amd64"]
  args = {
    CUDA_VERSION = CUDA_VERSION
    CUDNN_VERSION = CUDNN_VERSION
    UBUNTU_VERSION = UBUNTU_VERSION
    PYTHON_VERSION = PYTHON_VERSION
    TORCH_VERSION = TORCH_VERSION
    TORCHVISION_VERSION = TORCHVISION_VERSION
    TORCHAUDIO_VERSION = TORCHAUDIO_VERSION
    XFORMERS_VERSION = XFORMERS_VERSION
  }
  cache-from = ["type=registry,ref=opensora:cache"]
  cache-to = ["type=registry,ref=opensora:cache,mode=max"]
  tags = ["opensora:latest"]
  output = ["type=docker"]
} 