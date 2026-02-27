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

# --- 1. Base tools ---
log "Checking base tools"
install_pkg git git git git || true
install_pkg stow stow stow stow || true
install_pkg zsh zsh zsh zsh || true
install_pkg rg ripgrep ripgrep ripgrep || true

if ! have stow; then
    log "stow is required; install it and rerun"
    exit 1
fi

# --- 2. Vault CLI ---
if ! have vault; then
    if [[ "$NO_INSTALL" -eq 1 ]]; then
        log "Missing 'vault' (skip install due to --no-install)"
    else
        log "Installing vault CLI..."
        if have pacman; then
            sudo pacman -S --noconfirm vault
        elif have apt-get; then
            curl -fsSL https://apt.releases.hashicorp.com/gpg \
                | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
                | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
            sudo apt-get update -qq && sudo apt-get install -y vault
        elif have dnf; then
            sudo dnf install -y dnf-plugins-core
            sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
            sudo dnf install -y vault
        else
            log "Okand pakethanterare - installera vault manuellt: https://developer.hashicorp.com/vault/install"
            exit 1
        fi
    fi
fi
have vault && log "Vault CLI ok"

# --- 3. Stow packages ---
log "Applying stow packages"
cd "$DOTFILES_DIR"
stow git ssh zsh scripts

# --- 4. Hub structure ---
log "Creating hub structure"
"$SETUP_DIR/setup-hub.sh"

# --- 5. Vault config ---
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

# --- 6. Local git/ssh configs from templates ---
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
        if [[ -f "$VAULT_CONFIG" ]]; then
            _vault_host=$(grep VAULT_HOSTS "$VAULT_CONFIG" \
                | cut -d'"' -f2 | awk '{print $1}') || true
            _vault_user=$(grep VAULT_USER "$VAULT_CONFIG" \
                | cut -d'"' -f2) || true
        fi
        sed -i "s/__GITEA_HOST__/$_vault_host/g" "$target"
        sed -i "s/__HOMELAB_HOST__/$_vault_host/g" "$target"
        sed -i "s/__HOMELAB_USER__/$_vault_user/g" "$target"
        log "Updated $target"
    fi
done

chmod 700 "$HOME/.ssh"

# --- 7. Vault password ---
if [[ ! -f "$HOME/.config/local/vault-pass" ]]; then
    read -rsp "[bootstrap] Vault lösenord: " VAULT_PASS
    echo ""
    mkdir -p "$HOME/.config/local"
    echo -n "$VAULT_PASS" > "$HOME/.config/local/vault-pass"
    chmod 600 "$HOME/.config/local/vault-pass"
    log "Vault lösenord sparat"
fi

# --- 8. Vault login + auto-discovery ---
source "$VAULT_CONFIG"

_find_vault_addr() {
    local ports=(8200 443)
    for host in $VAULT_HOSTS; do
        for port in "${ports[@]}"; do
            local scheme="http"
            [[ "$port" == "443" ]] && scheme="https"
            local addr="${scheme}://${host}:${port}"
            if curl -sf --connect-timeout 1 "${addr}/v1/sys/health" &>/dev/null; then
                echo "$addr"
                return 0
            fi
        done
    done
    return 1
}

if [[ -z "${VAULT_ADDR:-}" ]]; then
    log "Söker Vault-server..."
    if VAULT_ADDR=$(_find_vault_addr); then
        log "Hittade Vault på $VAULT_ADDR"
    else
        read -rp "[bootstrap] Kunde inte hitta Vault - ange adress: " VAULT_ADDR
    fi
fi
export VAULT_ADDR

log "Loggar in i Vault..."
VAULT_TOKEN=$(vault login -method=userpass -field=token \
    username="$VAULT_USER" \
    password="$(tr -d '\n' < "$HOME/.config/local/vault-pass")" 2>/dev/null)
if [[ -z "$VAULT_TOKEN" ]]; then
    log "Vault login misslyckades - kontrollera lösenord och att Netbird är uppe"
    exit 1
fi
export VAULT_TOKEN
log "Inloggad i Vault"

# --- 9. Git identity from Vault ---
PERSONAL_CONF="$HOME/.config/git/local/personal.conf"
if [[ -f "$PERSONAL_CONF" ]] && grep -qE '<[A-Z_]+>' "$PERSONAL_CONF"; then
    GIT_NAME=$(vault kv get -field=name kv/config/git 2>/dev/null || echo '')
    GIT_EMAIL=$(vault kv get -field=email kv/config/git 2>/dev/null || echo '')
    if [[ -n "$GIT_NAME" && -n "$GIT_EMAIL" ]]; then
        printf '[user]\n    name = %s\n    email = %s\n' "$GIT_NAME" "$GIT_EMAIL" \
            > "$PERSONAL_CONF"
        chmod 600 "$PERSONAL_CONF"
        log "Git identitet hämtad från Vault"
    fi
fi

# --- 10. SSH pub keys ---
log "Hämtar SSH pub-nycklar från Vault..."
mkdir -p "$HOME/.ssh/keys"

for key in personal homelab work school; do
    if vault kv get kv/ssh/$key &>/dev/null; then
        vault kv get -field=public_key kv/ssh/$key > "$HOME/.ssh/keys/$key.pub" 2>/dev/null || true
        log "  $key.pub hämtad"
    else
        log "  $key saknas i Vault (hoppar över)"
    fi
done

# --- 11. Load private keys in agent (via tmpdir) ---
export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
    ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null 2>&1
fi

_tmpdir=$(mktemp -d)
trap 'rm -rf "$_tmpdir"' EXIT

for key in personal work school; do
    if vault kv get kv/ssh/$key &>/dev/null; then
        { vault kv get -field=private_key kv/ssh/$key; echo; } > "$_tmpdir/$key"
        chmod 600 "$_tmpdir/$key"
        ssh-add "$_tmpdir/$key" 2>/dev/null || true
    fi
done

# --- 12. Homelab cert signing ---
if vault kv get kv/ssh/homelab &>/dev/null; then
    { vault kv get -field=private_key kv/ssh/homelab; echo; } > "$_tmpdir/homelab"
    { vault kv get -field=public_key kv/ssh/homelab; echo; } > "$_tmpdir/homelab.pub"
    chmod 600 "$_tmpdir/homelab"
    vault write -field=signed_key ssh/sign/homelab-client \
        public_key=@"$_tmpdir/homelab.pub" valid_principals=ns \
        > "$_tmpdir/homelab-cert.pub" 2>/dev/null || true
    ssh-add "$_tmpdir/homelab" 2>/dev/null || true
    cp "$_tmpdir/homelab-cert.pub" "$HOME/.ssh/keys/homelab-cert.pub" 2>/dev/null || true
fi

log "SSH-nycklar laddade i agent (inga privata nycklar på disk)"

# --- 13. Enable systemd timer ---
log "Aktiverar vault-ssh-renew timer"
systemctl --user daemon-reload
systemctl --user enable --now vault-ssh-renew.timer 2>/dev/null || true

# --- 14. Verify ---
log "Kör verify.sh..."
"$SETUP_DIR/verify.sh" || true

log "Klar!"
