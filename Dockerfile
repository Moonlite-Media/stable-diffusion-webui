# Use an official CUDA runtime as the base image
FROM nvidia/cuda:12.2.2-runtime-ubuntu22.04

# Set environment variables
ENV WORKDIR /app

# Create a working directory
RUN mkdir -p $WORKDIR
WORKDIR $WORKDIR

# Create the outputs/img2img-images folder
RUN mkdir -p /home/ec2-user/apps/media_root

RUN apt-get update

# Install Python, pip, and other necessary dependencies
RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    git \
    wget \
    libgl1 && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip to the latest version
RUN pip install --upgrade pip

# Install the 'xformers' Python package
RUN pip install xformers

# Install additional system packages
RUN apt-get update && apt-get install -y ffmpeg libsm6 libxext6 libgl1 python3.10-venv --no-install-recommends google-perftools wget

# Clone the stable-diffusion-webui repository
RUN git clone https://github.com/Moonlite-Media/stable-diffusion-webui.git .

# Copy local files into the container
COPY . .

# Set up models folder and download required models
RUN mkdir -p models && \
    cd models && \
    mkdir -p Stable-diffusion && \
    wget -q https://huggingface.co/stabilityai/stable-diffusion-2/resolve/main/768-v-ema.safetensors

# Set up loras folder and downloaded required loras
RUN cd models && \
    mkdir -p Lora && \
    cd Lora && \
    wget -q "https://civitai.com/api/download/models/7657?type=Model&format=SafeTensor&size=full&fp=fp16" \
    wget -q "https://civitai.com/api/download/models/678485?type=Model" \
    wget -q "https://civitai.com/api/download/models/630255?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/637299?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/635271?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/627728?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/640781?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/621148?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/630663?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/612920?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/611327?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/318915?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/213507?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/77019?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/865690?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/72282?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/104225?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/376609?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/233018?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/236248?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/143715?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/489577?type=Model&format=SafeTensor" \
    wget -q "https://civitai.com/api/download/models/46621?type=Model&format=SafeTensor "

# Set up extensions folder and clone repositories
RUN mkdir -p extensions && \
    cd extensions && \
    git clone https://github.com/cheald/sd-webui-loractl.git && \
    git clone https://github.com/Mikubill/sd-webui-controlnet && \
    git clone https://github.com/deforum-art/sd-webui-deforum

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install other external dependencies in a single command
RUN pip install --no-cache-dir python-dotenv insightface

# Run the application
CMD ["python", "launch.py", "--nowebui", "--deforum-api", "--listen", "--api", "--port", "7861"]
