if not type -q fisher
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
end

set -gx EDITOR "nvim"
alias vim=nvim
alias python=python3
alias bat=batcat
alias cat=batcat


set fzf_dir_opts --bind "enter:execute($EDITOR {} &> /dev/tty)"

