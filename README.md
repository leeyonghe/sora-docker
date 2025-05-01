# Open-Sora 개발 환경 설정

이 문서는 [Open-Sora](https://github.com/hpcaitech/Open-Sora) 프로젝트의 개발 환경을 Docker로 설정하는 방법을 설명합니다.

## 원본 프로젝트 정보

Open-Sora는 HPC-AI Tech에서 개발한 오픈소스 비디오 생성 모델입니다. 주요 특징은 다음과 같습니다:

- 고품질 비디오 생성
- 다양한 해상도 지원 (256x256 ~ 768x768)
- 텍스트-비디오, 이미지-비디오 생성 지원
- 효율적인 훈련 및 추론

자세한 내용은 [원본 저장소](https://github.com/hpcaitech/Open-Sora)를 참조하세요.

## 개발 환경 설정

이 저장소는 Open-Sora를 쉽게 실행할 수 있는 Docker 기반 개발 환경을 제공합니다.

### 사전 요구사항

- Docker 설치
- NVIDIA Docker 설치
- NVIDIA GPU 드라이버 설치
- CUDA 12.1 이상 지원 GPU

### 설치 및 실행 방법

#### 방법 1: Docker Compose 사용 (권장)

1. 저장소 클론:
```bash
git clone https://github.com/hpcaitech/Open-Sora.git
cd Open-Sora
```

2. Docker 이미지 빌드:
```bash
docker-compose build
```

3. 컨테이너 실행:
```bash
docker-compose up -d
```

#### 방법 2: Docker Buildx Bake 사용 (고급)

Docker Buildx Bake는 더 빠른 빌드와 캐시 최적화를 제공합니다.

1. Buildx Bake 활성화:
```bash
docker buildx create --use
```

2. 이미지 빌드:
```bash
docker buildx bake
```

3. 특정 버전으로 빌드:
```bash
docker buildx bake --set opensora.args.CUDA_VERSION=12.1.1 --set opensora.args.PYTHON_VERSION=3.10
```

4. 컨테이너 실행:
```bash
docker run --gpus all -p 8888:8888 -v $(pwd):/workspace opensora:latest
```

### Jupyter Notebook 접속
- 웹 브라우저에서 `http://localhost:8888` 접속

## 모델 다운로드

Jupyter Notebook에서 다음 명령을 실행하여 모델을 다운로드할 수 있습니다:

```python
# Huggingface에서 다운로드
!pip install "huggingface_hub[cli]"
!huggingface-cli download hpcai-tech/Open-Sora-v2 --local-dir ./ckpts

# 또는 ModelScope에서 다운로드
!pip install modelscope
!modelscope download hpcai-tech/Open-Sora-v2 --local_dir ./ckpts
```

## 사용 예시

Jupyter Notebook에서 다음 코드를 실행하여 비디오를 생성할 수 있습니다:

```python
# 256x256 해상도로 텍스트-비디오 생성
!torchrun --nproc_per_node 1 --standalone scripts/diffusion/inference.py configs/diffusion/inference/t2i2v_256px.py --save-dir samples --prompt "비가 내리는 바다"

# 768x768 해상도로 텍스트-비디오 생성 (다중 GPU)
!torchrun --nproc_per_node 8 --standalone scripts/diffusion/inference.py configs/diffusion/inference/t2i2v_768px.py --save-dir samples --prompt "비가 내리는 바다"
```

## 주의사항

1. GPU 메모리:
   - 256x256 해상도: 최소 8GB GPU 메모리 필요
   - 768x768 해상도: 최소 24GB GPU 메모리 필요

2. 저장 공간:
   - 모델 체크포인트: 약 20GB
   - 생성된 비디오: 비디오 크기에 따라 다름

3. 성능:
   - GPU 성능에 따라 생성 시간이 달라질 수 있습니다.
   - 더 빠른 생성을 위해 flash attention 3가 설치되어 있습니다.

## 문제 해결

1. GPU 관련 문제:
   - `nvidia-smi` 명령어로 GPU 상태 확인
   - NVIDIA 드라이버가 최신 버전인지 확인

2. 메모리 부족:
   - `--offload True` 옵션 사용
   - 더 작은 배치 크기 사용

3. 기타 문제:
   - 컨테이너 재시작: `docker-compose restart`
   - 로그 확인: `docker-compose logs -f`

## 라이선스

이 개발 환경 설정은 원본 Open-Sora 프로젝트와 동일한 라이선스를 따릅니다. 자세한 내용은 [원본 저장소](https://github.com/hpcaitech/Open-Sora)를 참조하세요. 