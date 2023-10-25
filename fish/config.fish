# Ensure essential system paths are present
if not contains /usr/local/bin $PATH
    set -gx PATH /usr/local/bin $PATH
end

if not contains /usr/bin $PATH
    set -gx PATH /usr/bin $PATH
end

if not contains /bin $PATH
    set -gx PATH /bin $PATH
end

# Add Go's path
set -gx PATH $PATH /usr/local/go/bin

# Add Go's tool path
set -gx PATH $PATH $HOME/go/bin

# Specific settings for macOS
if test (uname) = "Darwin"
    set -gx PATH /opt/homebrew/bin $PATH
end

set -gx EDITOR "nvim"
alias vim=nvim
alias python=python3

if status is-interactive
    and not set -q TMUX
    exec tmux
end


# Specific settings for Linux
if test (uname) = "Linux"
    alias bat=batcat
    alias cat=batcat
end


set fzf_dir_opts --bind "enter:execute($EDITOR {} &> /dev/tty)"
