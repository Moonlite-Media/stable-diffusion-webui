# Use an official Python runtime as the base image
FROM nvidia/cuda:12.2.2-runtime-ubuntu22.04

# Set environment variables
ENV STABLE_DIFFUSION_API_PORT=7861
ENV WORKDIR /app

# Create a working directory and set permissions
RUN mkdir -p $WORKDIR
WORKDIR $WORKDIR

# Install Python, pip, and other necessary dependencies
RUN apt-get update && \
    apt-get install -y python3 python3-pip git wget && \
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
RUN pip install -r requirements.txt

# Install other external dependencies
RUN pip install python-dotenv
RUN pip install insightface

# Run the application
CMD ["python", "launch.py", "--nowebui", "--deforum-api", "--api", "--skip-torch-cuda-test"]
