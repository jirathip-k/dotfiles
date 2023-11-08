# Dotfiles

Install [dotter](https://github.com/SuperCuber/dotter) to manage dotfiles

# Neovim

- [Neovim](https://github.com/neovim/neovim)

## Install Hack Nerd Font

- [nerd-fonts](https://github.com/ryanoasis/nerd-fonts)

# Terminal

## Wezterm

## Kitty

## TMUX

```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source ~/.tmux.conf
```

Press prefix + I (capital i, as in Install) to fetch the plugin.

- [TPM](https://github.com/tmux-plugins/tpm)
- [Catppuccin](https://github.com/catppuccin/tmux)

## Fish

- [Fish shell](https://github.com/fish-shell/fish-shell)
- [Fish package manager](https://github.com/jorgebucaran/fisher)

```fish
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
```

```bash
chsh -s <path-to-fish-shell>
```

find path by `which fish` and add it to /etc/shells

- [Tide](https://github.com/IlanCosman/tide)

# Docker with minikube

```bash
minikube start --driver qemu --network socket_vmnet
val $(minikube docker-env)
```

[Guide](https://gist.github.com/juancsr/5927e6660d6ba5d2a34c61802d26e50a)

```fish
brew install docker docker-compose docker-buildx minikube qemu
```

```bash
echo "`minikube ip` docker.local" | sudo tee -a /etc/hosts > /dev/null
ln -s /opt/homebrew/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose
ln -s /opt/homebrew/opt/docker-buildx/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
```

- For full networking [socket_vmnet](https://github.com/lima-vm/socket_vmnet) is required

```bash
git clone https://github.com/lima-vm/socket_vmnet.git && cd socket_vmnet
sudo make install
```

## Build into image

```fish
docker build -t myenv .
```

## Use Image

```fish
docker run -it --rm myenv
```
