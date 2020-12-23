#
# Python3 Dockerfile
#
# - Ubuntu 18.04
# - python 3.8.6
# - python dependencies from ./requirements.txt.
#
# Build using: docker build -t 'dxyang/jupyter_docker:0.1' .
#

# Pull base image.
# CUDA base image: nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
# Default base image: ubuntu:18.04
FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04

# Don't want to deal with interactive things
ENV DEBIAN_FRONTEND=noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Time
RUN apt-get update && apt-get install -y apt-utils locales && locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
RUN dpkg-reconfigure locales
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y tzdata && dpkg-reconfigure tzdata

# Some basic system dependencies
RUN apt-get update && apt-get install -y \
    fonts-powerline \
    git \
    man \
    software-properties-common \
    sudo \
    tmux \
    vim \
    zsh

# Dependencies suggested by pyenv
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev

# Setup python toolchain through pyenv instead of system (allows for updating pip)
ENV PYENV_ROOT "/.pyenv"
ENV PATH="/.pyenv/bin:/.pyenv/shims:$PATH"
RUN curl https://pyenv.run | bash
RUN pyenv install 3.8.6
RUN pyenv global 3.8.6
RUN pip install -U pip virtualenv setuptools wheel

# Pull base image.
COPY requirements.txt /requirements.txt

# Install some opencv and pygobject dependencies
RUN \
    sudo apt-get install -y \
        libcairo2-dev \
        libgirepository1.0-dev \
        libglib2.0-0 \
        libsm6 \
        libxext6 \
        libxrender-dev

# Install repo python requirements
RUN \
    pip --no-cache-dir install -r /requirements.txt

WORKDIR /opt/project
