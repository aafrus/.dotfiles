# ---[ Prompt Configuration ]---
autoload -Uz colors && colors
setopt PROMPT_SUBST

# ---[ Git Symbols ]---
ICO_DIRTY="⚡"
ICO_AHEAD="▲"
ICO_BEHIND="▼"
ICO_DIVERGED="⥮"

# ---[ Colors ]---
COLOR_ROOT="%F{red}"
COLOR_USER="%F{cyan}"
COLOR_NORMAL="%F{white}"
PROMPT_STYLE="tiny"  # Change to 'classic', 'dual', 'mini' or 'ascii' if needed

# ---[ Git Prompt Function ]---
GIT_PROMPT() {
    # Only show in Git repos
    local test=$(git rev-parse --is-inside-work-tree 2>/dev/null)
    if [ ! "$test" ]; then
        case "$PROMPT_STYLE" in
            ascii) echo "$reset_color%F{cyan}▒░" ;;
            arrows) echo "$reset_color%F{cyan}" ;;
            *) echo "" ;;
        esac
        return
    fi

    # Get branch/tag info
    local ref=$(git name-rev --name-only HEAD | sed 's!remotes/!!' 2>/dev/null)
    if [[ "$ref" == "tags"* ]]; then
        local branch=$(git branch | grep -e "^*" | tr -d "*")
        ref="${branch/ /} ${ref}"
    fi

    # Check dirty status
    local dirty=""
    [[ $(git diff --shortstat 2>/dev/null | tail -n1) != "" ]] && dirty=$ICO_DIRTY

    # Check upstream status
    local stat=""
    case $(git status | sed -n 2p) in
        *ahead*) stat=$ICO_AHEAD ;;
        *behind*) stat=$ICO_BEHIND ;;
        *diverged*) stat=$ICO_DIVERGED ;;
    esac

    # Format based on style
    case "$PROMPT_STYLE" in
        classic) echo "${COLOR_NORMAL}─[${ref}${dirty}${stat}]" ;;
        tiny) echo "%F{241} [%F{244}${ref}${dirty}${stat}%F{241}]" ;;
        *) echo "${COLOR_USER}─[${COLOR_NORMAL}${ref}${dirty}${stat}${COLOR_USER}]" ;;
    esac
}

# ---[ Main Prompt ]---
case "$PROMPT_STYLE" in
    ascii)
        PROMPT='%{$bg[cyan]%} %F{black}%~ $(GIT_PROMPT)$reset_color 
%f'
        ;;
    dual)
        PROMPT='${COLOR_USER}┌[${COLOR_NORMAL}%~${COLOR_USER}]$(GIT_PROMPT)
${COLOR_USER}└─ - %f'
        ;;
    mini)
        PROMPT='${COLOR_USER}[${COLOR_NORMAL}%~${COLOR_USER}]$(GIT_PROMPT)── - %f'
        ;;
    tiny)
        if [[ -v VIMRUNTIME ]]; then
            PROMPT='%F{9} ──── ─${COLOR_NORMAL} '
        elif [[ -v SSH_TTY ]]; then
            PROMPT='%F{13} ${HOSTNAME}%F{3}_ ${COLOR_NORMAL}'
        else
            PROMPT='%F{11} ──── ─${COLOR_NORMAL} '
        fi
        RPROMPT='%F{15}%~ $(GIT_PROMPT) ${COLOR_NORMAL}'
        ;;
    *)
        PROMPT='%F{cyan}${USERNAME}@%F{white}[${HOSTNAME}]$(GIT_PROMPT)%F{white} : %~# '
        ;;
esac

# ---[ Auto-CD Function ]---
chpwd_auto_cd() {
    emulate -L zsh
    ls -lAhF --color=auto
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd chpwd_auto_cd