#                 ██
#                ░██
#  ██████  ██████░██
# ░░░░██  ██░░░░ ░██████
#    ██  ░░█████ ░██░░░██
#   ██    ░░░░░██░██  ░██
#  ██████ ██████ ░██  ░██
# ░░░░░░ ░░░░░░  ░░   ░░
# s h e l l  a l i a s e s

# colours
red="\e[31m"
green="\e[32m"
reset="\e[0m"

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
                                                                              \
    xsel="xsel -b"                                                            \
    fuck='sudo $(fc -ln -1)'                                                  \
    dd="dd status=progress"                                                   \
                                                                              \
    term="urxvtc -hold -e "                                                   \
                                                                              \
    reboot="sudo reboot"                                                      \
    systemctl="sudo systemctl"


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
    ga="git add"                                                              \
    gb="git branch"                                                           \
    gc="git commit -S -m"                                                     \
    gs="git status -sb"                                                       \
    gd="git diff"                                                             \
    gf="git fetch && git log --pretty=format:'%C(always,yellow)%h%Creset %s %Cred%d' ..@{u}" \
    gm="git merge"                                                            \
    gr="git rebase"                                                           \
    gp="git push"                                                             \
    gu="git unstage"                                                          \
    gg="git log --graph"                                                      \
    gco="git checkout"                                                        \
    gsm="git status -sbuno"                                                   \
    gpr="git request-pull"                                                    \
    ggg="git graphgpg"

    gcl() {
        git clone "${@}"
        test -n "${2}" && _dir=${2} || _dir=${1##*/}
        cd ${_dir%.git}
    }


# ▓▓▒░ pacman
                                                                        alias \
    pac="sudo pacman"                                                         \
    pacman="sudo pacman"                                                      \
    update="sudo paccache -r ; pacman -S --noconfirm archlinux-keyring ; pacman -Syu"

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
    kc="KUBECONFIG=./kubeconfig.yml kubectl"

# ▓▓▒░ fun(ctions)

    email() {
      echo $3 | mutt -s $2 $1
    }
