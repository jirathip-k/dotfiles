# Dotfiles

symlink

```
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/kitty ~/.config/kitty
ln -s ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
rm -rf ~/.config/fish/config.fish
rm -rf ~/.config/fish/fish_plugins
ln -s ~/dotfiles/fish/config.fish ~/.config/fish/config.fish
ln -s ~/dotfiles/fish/fish_plugins ~/.config/fish/fish_plugins
ln -s ~/dotfiles/git/.gitconfig ~/.gitconfig 
```

# Neovim

- MacOS

```bash
brew install ninja libtool automake cmake pkg-config gettext
```

Then clone and make from source [Neovim](https://github.com/neovim/neovim)

## Install Hack Nerd Font

- [nerd-fonts](https://github.com/ryanoasis/nerd-fonts)

## Markdown Renderer

- [Glow](https://github.com/charmbracelet/glow)

# Terminal

## Kitty

...

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


## Dependencies

TODO: Need to update when setting up new env

### MacOS


```bash
brew install fzf bat fd ripgrep
```

### Linux

```bash
suo apt install ...
```

## Utilities

```bash
cargo install exa
```

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
