FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    dnsutils \
    git \
    iproute2 \
    iputils-ping \
    jq \
    less \
    locales \
    net-tools \
    openssh-client \
    procps \
    python3 \
    python3-pip \
    sudo \
    tmux \
    unzip \
    vim \
    nano \
    htop \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen en_US.UTF-8

ARG LAB_USER=lab
ARG LAB_UID=1000
ARG LAB_GID=1000

RUN groupadd --gid "$LAB_GID" "$LAB_USER" && \
    useradd --uid "$LAB_UID" --gid "$LAB_GID" --create-home --shell /bin/bash "$LAB_USER" && \
    echo "$LAB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-lab-user

WORKDIR /workspace
COPY . /workspace
RUN chown -R "$LAB_USER":"$LAB_USER" /workspace && \
    chmod +x scripts/*.sh

USER "$LAB_USER"

ENTRYPOINT ["/bin/bash"]
