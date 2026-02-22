#!/usr/bin/env bash
set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SETUP_DIR")"
NO_INSTALL=0

if [[ "${1:-}" == "--no-install" ]]; then
    NO_INSTALL=1
fi

log() {
    printf '[bootstrap] %s\n' "$*"
}

have() {
    command -v "$1" >/dev/null 2>&1
}

install_pkg() {
    local cmd="$1"
    local apt_pkg="$2"
    local pac_pkg="$3"
    local dnf_pkg="$4"

    if have "$cmd"; then
        return 0
    fi

    if [[ "$NO_INSTALL" -eq 1 ]]; then
        log "Missing '$cmd' (skip install due to --no-install)"
        return 1
    fi

    if have apt-get; then
        log "Installing $apt_pkg via apt-get"
        sudo apt-get update -y
        sudo apt-get install -y "$apt_pkg"
        return 0
    fi

    if have pacman; then
        log "Installing $pac_pkg via pacman"
        sudo pacman -Sy --noconfirm "$pac_pkg"
        return 0
    fi

    if have dnf; then
        log "Installing $dnf_pkg via dnf"
        sudo dnf install -y "$dnf_pkg"
        return 0
    fi

    log "No supported package manager found for '$cmd'"
    return 1
}

log "Checking base tools"
install_pkg git git git git || true
install_pkg stow stow stow stow || true
install_pkg zsh zsh zsh zsh || true
install_pkg rg ripgrep ripgrep ripgrep || true

if ! have stow; then
    log "stow is required; install it and rerun"
    exit 1
fi

log "Applying stow packages"
cd "$DOTFILES_DIR"
stow git ssh zsh

log "Creating hub structure"
"$SETUP_DIR/setup-hub.sh"

log "Creating local git identity files from templates (if missing)"
mkdir -p "$HOME/.config/git/local"
for name in default personal work school; do
    target="$HOME/.config/git/local/${name}.conf"
    template="$DOTFILES_DIR/git/.config/git/${name}.conf.example"
    if [[ ! -f "$target" && -f "$template" ]]; then
        cp "$template" "$target"
        chmod 600 "$target"
        log "Created $target"
    fi
done

log "Creating local ssh config files from templates (if missing)"
mkdir -p "$HOME/.ssh/config.d/local"
for name in personal work school homelab; do
    idx=""
    case "$name" in
        personal) idx="00" ;;
        work) idx="01" ;;
        school) idx="02" ;;
        homelab) idx="03" ;;
    esac
    target="$HOME/.ssh/config.d/local/${name}.conf"
    template="$DOTFILES_DIR/ssh/.ssh/config.d/${idx}-${name}.conf.example"
    if [[ ! -f "$target" && -f "$template" ]]; then
        cp "$template" "$target"
        chmod 600 "$target"
        log "Created $target"
    fi
    if [[ -f "$target" ]] && grep -qE '__GITEA_HOST__|__HOMELAB_HOST__|__HOMELAB_USER__' "$target"; then
        _vault_host=""
        _vault_user=""
        if [[ -f "$HOME/.config/local/vault-config" ]]; then
            _vault_host=$(grep VAULT_HOSTS "$HOME/.config/local/vault-config" \
                | cut -d'"' -f2 | awk '{print $1}') || true
            _vault_user=$(grep VAULT_USER "$HOME/.config/local/vault-config" \
                | cut -d'"' -f2) || true
        fi
        sed -i "s/__GITEA_HOST__/$_vault_host/g" "$target"
        sed -i "s/__HOMELAB_HOST__/$_vault_host/g" "$target"
        sed -i "s/__HOMELAB_USER__/$_vault_user/g" "$target"
        log "Updated $target"
    fi
done

chmod 700 "$HOME/.ssh"

log "Creating vault config (if missing)"
mkdir -p "$HOME/.config/local"
VAULT_CONFIG="$HOME/.config/local/vault-config"
if [[ ! -f "$VAULT_CONFIG" ]]; then
    read -rp "[bootstrap] Vault användarnamn: " _vault_user
    read -rp "[bootstrap] Vault host(s) (space-separerat): " _vault_hosts
    printf 'VAULT_USER="%s"\nVAULT_HOSTS="%s"\n' "$_vault_user" "$_vault_hosts" > "$VAULT_CONFIG"
    chmod 600 "$VAULT_CONFIG"
    log "vault-config skapad"
fi

log "Done"
log "Next: kör $SETUP_DIR/setup.sh för SSH-nycklar och git-identitet"
log "Verifiera sedan med: $SETUP_DIR/verify.sh"
