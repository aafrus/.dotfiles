# ▓▓▒░ root
# check for doas so aliases can be used on different systems
# add whitespace for hack to make aliases woth with {sudo,doas}
command -v doas >/dev/null && \
    alias sudo='doas ' || \
    alias sudo='sudo '

# ▓▓▒░ unix
# openbsd's ls(1) doesn't provide the `--color` option.
command -v gls >/dev/null && \
    alias ls="gls -hF --color=auto" || \
    alias ls="ls -hF --color=auto"

# ▓▓▒░ root

command -v doas >/dev/null && \
    alias sudo='doas ' || \
    alias sudo='sudo '

# ▓▓▒░ sys
                                                                        alias \
    ll="ls -lahF --color=auto"                                                \
    lsl="ls -lhF --color=auto"                                                \
    llrt="ls -lahFrt --color=auto"                                            \
                                                                              \
    cp="cp -r"                                                                \
    rmrf="rm -rf"                                                             \
    scp="scp -r"                                                              \
    mod="chmod +x"                                                            \
    up="cd ../"                                                               \
    mkdir="mkdir -p"                                                          \
    l="ln -sv"                                                                \
                                                                              \
    xsel="xsel -b"                                                            \
    fuck='sudo $(fc -ln -1)'                                                  \
    dd="dd status=progress"                                                   \
                                                                              \
    term="urxvtc -hold -e "                                                   \
                                                                              \
    reboot="sudo reboot"                                                      \
    sctl="systemctl"                                                          \
    peel="tar xf"                                                             \


# ▓▓▒░ info
                                                                        alias \
    psef="ps -ef"                                                             \
    jobs="jobs -l"                                                            \
    \?is="whereis"                                                            \
    history="history -i"                                                      \
    disks='echo "┌──┄";echo "├┄ m o u n t . p o i n t s"; echo "└──┄┄────┄┄"; lsblk -a; echo ""; echo "┌──┄";echo "├┄ d i s k . u s a g e"; echo "└──┄┄────┄┄"; sudo df -h -x tmpfs -x devtmpfs;' \
    ag="ag --color --color-line-number '0;35' --color-match '46;30' --color-path '4;36'" \
    tree='tree -CAFa -I "CVS|*.*.package|.svn|.git|.hg|node_modules|bower_components" --dirsfirst'

# ▓▓▒░ text editor
                                                                        alias \
    v="nvim"                                                                   \

# ▓▓▒░ git
                                                                        alias \
    g="git"                                                                   \
    gi="git init"                                                             \
    ga="git add"                                                              \
    gaa="git add --all"                                                       \
    gu="git restore --staged"                                                 \
    gb="git branch -vv"                                                       \
    gcl="git clone"                                                           \
    gc="git commit -m"                                                        \
    gca="git commit --amend --no-edit"                                        \
    gs="git status -sb"                                                       \
    gsm="git status -sbuno"                                                   \
    gd="git diff"                                                             \
    gds="git diff --staged"                                                   \
    gf="git fetch && git log --pretty=format:'%C(always,yellow)%h%Creset %s %Cred%d' ..@{u}" \
    gm="git merge"                                                            \
    gr="git rebase"                                                           \
    gp="git push"                                                             \
    gpf="git push --force-with-lease"                                         \
    gpl="git pull"                                                            \
    gsw="git switch"                                                          \
    gl="git log --graph --oneline --decorate --all"                           \
    glg="git log --graph --pretty=format:'%C(yellow)%h%Creset %s %C(dim)%cr%Creset'" \
    gao="git remote add origin"                                               \
    gpsu='{ branch=$(git_current_branch) || exit 1; git push --set-upstream origin "$branch"; }' \
                                                                              \




# ▓▓▒░ pacman
                                                                        alias \
    pac="sudo pacman"                                                         \
    pacman="sudo pacman"                                                      \
    update="sudo paccache -rfk2 && pacman -S --noconfirm archlinux-keyring && pacman -Syu --noconfirm && sudo netbird-update"

# ▓▓▒░ devops
                                                                        alias \
    ap="ansible-playbook"                                                     \
                                                                              \
    lxc-ls="lxc-ls -f"                                                        \
    lxls="lxc-ls -f"                                                          \
    lxst="lxc-start"                                                          \
    lxsp="lxc-stop"                                                           \
    lxat="lxc-attach"                                                         \
                                                                              \
    docker="sudo docker"                                                      \
    docker-compose="sudo docker-compose"                                      \
    dtail="docker logs -tf --tail='50'"                                       \
    dps="docker ps"                                                           \
    dpsa="docker ps -a"                                                       \
    dstart="docker start"                                                     \
    dstop="docker stop"                                                       \
    drm="docker rm"                                                           \
    drmi="docker rmi"                                                         \
    dcomp="docker-compose -f ./docker-compose.yml"                            \
                                                                              \
    tf="terraform"                                                            \
    tfi="terraform init"                                                      \
    tfa="terraform apply --auto-approve"                                      \
    tfp="terraform plan"                                                      \
    tfd="terraform destroy"                                                   \
                                                                              \
    kc="KUBECONFIG=./kubeconfig.yml kubectl"                                  \
    k="kubectl"                                                               \

# ▓▓▒░ suffix
                                                                     alias -s \
    md=nvim                                                                   \
    {png,jpg,jpeg}=sxiv                                                       \
    pdf=zathura                                                               \
    mp4=mpv

# ▓▓▒░ misc
                                                                        alias \
    mixer="alsamixer"                                                         \
    news="newsboat"                                                           \
    gifview="gifview -a"                                                      \
    feh="feh -g 640x480"                                                      \
    tidy="python3 ~/.local/bin/tidy"                                          \
    sys="~/.local/bin/sysinfo"                                                \
    s="exec zsh"                                                              \
