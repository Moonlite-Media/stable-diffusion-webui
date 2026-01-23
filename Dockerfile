# Use an official CUDA runtime as the base image
FROM nvidia/cuda:12.2.2-runtime-ubuntu22.04

# Set environment variables
ENV WORKDIR=/app
ENV PIP_TMPDIR=/app/pip-tmp

# Create a working directory
RUN mkdir -p $WORKDIR $PIP_TMPDIR
WORKDIR $WORKDIR

# Create the outputs/img2img-images folder
RUN mkdir -p /home/ec2-user/apps/media_root

# Install Python, pip, and other necessary dependencies
RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    git \
    wget \
    libgl1 \
    ffmpeg \
    libsm6 \
    libxext6 \
    python3.10-venv \
    google-perftools && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip to the latest version
RUN pip install --upgrade pip

# Install the 'xformers' Python package
RUN TMPDIR=$PIP_TMPDIR pip install --no-cache-dir xformers

# Clone the stable-diffusion-webui repository
RUN git clone https://github.com/Moonlite-Media/stable-diffusion-webui.git .

# Set up models folder and download required models
RUN mkdir -p models/Stable-diffusion && \
    wget -q -P models/Stable-diffusion https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors

# Set up extensions folder and clone repositories
RUN mkdir -p extensions && \
    cd extensions && \
    git clone https://github.com/cheald/sd-webui-loractl.git && \
    git clone https://github.com/Mikubill/sd-webui-controlnet && \
    git clone https://github.com/deforum-art/sd-webui-deforum

# Copy local files into the container (this overwrites/adds to the cloned repo)
COPY . .

# Install Python dependencies
RUN TMPDIR=$PIP_TMPDIR pip install --no-cache-dir -r requirements.txt

# Install other external dependencies
RUN TMPDIR=$PIP_TMPDIR pip install --no-cache-dir python-dotenv insightface

# Clean up pip temp directory
RUN rm -rf $PIP_TMPDIR

# Run the application
CMD ["python", "launch.py", "--nowebui", "--deforum-api", "--listen", "--api", "--port", "7861"]
