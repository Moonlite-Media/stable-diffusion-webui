# Use an official CUDA runtime as the base image
FROM nvidia/cuda:12.2.2-runtime-ubuntu22.04

# Set environment variables
ENV WORKDIR /app

# Create a working directory
RUN mkdir -p $WORKDIR
WORKDIR $WORKDIR

# Install Python, pip, and other necessary dependencies
RUN apt-get update && \
    apt-get install -y python3 python3-pip git wget libgl1 && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

# Clone the stable-diffusion-webui repository
RUN git clone https://github.com/Moonlite-Media/stable-diffusion-webui.git .

# Set up models folder and download required models
RUN mkdir -p models && \
    cd models && \
    wget -q https://huggingface.co/stabilityai/stable-diffusion-2/resolve/main/768-v-ema.safetensors

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
CMD ["python", "launch.py", "--nowebui", "--deforum-api", "--api", "--skip-torch-cuda-test"]
