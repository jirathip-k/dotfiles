# Common setting for both Linux and macOS
if not type -q fisher
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
end

set -gx EDITOR "nvim"
alias vim=nvim
alias python=python3

# Specific settings for macOS
if test (uname) = "Darwin"
    set -gx PATH /opt/homebrew/bin $PATH

    if status is-interactive
        and not set -q TMUX
        exec tmux
    end
end

# Specific settings for Linux
if test (uname) = "Linux"
    alias bat=batcat
    alias cat=batcat
end

