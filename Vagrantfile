# Vagrant configuration for a self-contained Remote Linux Lab VM.
# Provides a local Ubuntu 22.04 environment with tooling mirroring the Docker image.
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "remote-linux-lab"

  # Forward SSH to a stable TCP port so host tools like scp can connect easily.
  config.vm.network "forwarded_port", guest: 22, host: 2222, auto_correct: true

  # Lightweight provisioning that mirrors the Docker image dependencies.
  config.vm.provision "shell", inline: <<-SHELL
    set -euxo pipefail
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      curl \
      dnsutils \
      git \
      htop \
      iproute2 \
      iputils-ping \
      jq \
      locales \
      net-tools \
      openssh-server \
      python3 \
      sudo \
      tmux \
      unzip \
      vim \
      nano
    locale-gen en_US.UTF-8
    systemctl enable ssh
  SHELL

  # Sync the repository so changes inside the VM are available on the host.
  config.vm.synced_folder ".", "/workspace"

  # Use the shared folder as working directory for quick starts.
  config.vm.provision "shell", inline: <<-SHELL
    echo "cd /workspace" >> /home/vagrant/.bashrc
  SHELL
end
