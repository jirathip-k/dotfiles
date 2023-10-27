
ARG BASE_IMAGE=ubuntu:22.04
FROM $BASE_IMAGE

LABEL maintainer="jirathip"
LABEL version="1.0"
LABEL description="Docker image with my dotfiles."


RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    cmake \
    gettext \
    libtool \
    libtool-bin \
    autoconf \
    automake \
    cmake \
    g++ \
    pkg-config \
    unzip \
    fzf \
    fd-find \
    bat \
    exa \
    fonts-font-awesome \
    xz-utils \
    ca-certificates \
    gnupg \
    software-properties-common \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

RUN apt-add-repository ppa:fish-shell/release-3 -y && \
    apt-get update && \
    apt-get install -y fish

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install Go
RUN curl -fLo go1.21.3.linux-amd64.tar.gz https://dl.google.com/go/go1.21.3.linux-amd64.tar.gz \
    && rm -rf /usr/local/go \
    && tar -C /usr/local -xzf go1.21.3.linux-amd64.tar.gz \
    && rm go1.21.3.linux-amd64.tar.gz

# Install Node.js
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install nodejs -y

# Install Python from deadsnakes
RUN add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install python3.10 -y

# Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

RUN curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish > /tmp/fisher.fish && \
    fish -c "source /tmp/fisher.fish; fisher install jorgebucaran/fisher"

RUN git clone https://github.com/jirathip-k/dotfiles.git ~/dotfiles

RUN git clone https://github.com/neovim/neovim.git ~/apps/neovim \
    && cd ~/apps/neovim \ 
    && make CMAKE_BUILD_TYPE=RelWithDebInfo \
    && make install

RUN mkdir -p ~/.config \
    && ln -s ~/dotfiles/nvim ~/.config/nvim \
    && ln -s ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf \
    && rm -rf ~/.config/fish/config.fish \
    && rm -rf ~/.config/fish/fish_plugins \
    && mkdir -p ~/.config/fish \
    && ln -s ~/dotfiles/fish/config.fish ~/.config/fish/config.fish \
    && ln -s ~/dotfiles/fish/fish_plugins ~/.config/fish/fish_plugins \
    && ln -s ~/dotfiles/git/.gitconfig ~/.gitconfig


RUN mkdir -p /root/.local/share/fonts \
    && cd /root/.local/share/fonts \
    && curl -fLo "Hack.tar.xz" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.tar.xz \
    && tar -xf "Hack.tar.xz" --wildcards '*.ttf' \
    && rm "Hack.tar.xz"

RUN fc-cache -f -v

RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" > /etc/apt/sources.list.d/charm.list && \
    apt-get update && \
    apt-get install -y glow

WORKDIR /root

CMD [ "fish" ]

