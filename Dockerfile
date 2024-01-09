# Start with an NVIDIA-optimized PyTorch base image
FROM nvcr.io/nvidia/pytorch:23.12-py3

# Install some dependencies
RUN apt update && apt install -y bzip2 ca-certificates curl git sudo vim && rm -rf /var/lib/apt/lists/*

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user && \
    echo "user ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/90-user

# All users can use /home/user as their home directory
ENV HOME=/home/user

# Switch to the user
USER user

# Install Miniconda for x86_64 architecture
RUN curl -so ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p ~/miniconda && \
    rm ~/miniconda.sh
ENV PATH=/home/user/miniconda/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false

# Install packages for an lpr environment
COPY lpr_env.yaml $HOME
RUN conda env create -f=$HOME/lpr_env.yaml && conda clean -ya
ENV CONDA_DEFAULT_ENV=lpr
ENV CONDA_PREFIX=/home/user/miniconda/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH

# Set the working directory in the container
WORKDIR ${HOME}

# Install Apex
#RUN git clone https://github.com/NVIDIA/apex && cd apex && pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./

WORKDIR ${HOME}/workspace

# Copy workspace into the container
COPY workspace ${HOME}/workspace

# Set a default command, if needed
CMD ["bash"]
