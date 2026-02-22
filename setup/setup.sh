#!/bin/bash
# Kör detta på en ny dator efter bootstrap.sh
set -euo pipefail

log() { printf '[setup-local] %s\n' "$*"; }

VAULT_CONFIG="$HOME/.config/local/vault-config"
VAULT_EXAMPLE="$(dirname "$0")/vault.conf.example"

if [[ ! -f "$VAULT_CONFIG" ]]; then
    cp "$VAULT_EXAMPLE" "$VAULT_CONFIG"
    chmod 600 "$VAULT_CONFIG"
    log "Fyll i ~/.config/local/vault-config och kör om setup.sh"
    ${EDITOR:-nano} "$VAULT_CONFIG"
fi
source "$VAULT_CONFIG"

# --- Vault adress (auto-discovery) ---
# Hosts läses från VAULT_HOSTS i vault-config (lokal fil, ej i git).
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
        log "  Hittade Vault på $VAULT_ADDR"
    else
        read -rp "Kunde inte hitta Vault - ange adress: " VAULT_ADDR
    fi
fi
export VAULT_ADDR

echo "=== Lokal setup ==="

# --- Vault CLI ---
if ! command -v vault &>/dev/null; then
    log "Installerar vault CLI..."
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm vault
    elif command -v apt-get &>/dev/null; then
        curl -fsSL https://apt.releases.hashicorp.com/gpg \
            | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
            | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
        sudo apt-get update -qq && sudo apt-get install -y vault
    else
        log "Okänd pakethanterare - installera vault manuellt: https://developer.hashicorp.com/vault/install"
        exit 1
    fi
fi
log "Vault CLI ok"

# --- Vault lösenord ---
if [[ ! -f "$HOME/.config/local/vault-pass" ]]; then
    read -rsp "Vault lösenord: " VAULT_PASS
    echo ""
    mkdir -p "$HOME/.config/local"
    echo -n "$VAULT_PASS" > "$HOME/.config/local/vault-pass"
    chmod 600 "$HOME/.config/local/vault-pass"
    log "Vault lösenord sparat"
fi

# --- Vault login ---
log "Loggar in i Vault..."
export VAULT_ADDR
VAULT_TOKEN=$(vault login -method=userpass -field=token \
    username="$VAULT_USER" \
    password="$(cat "$HOME/.config/local/vault-pass" | tr -d '\n')" 2>/dev/null)
if [[ -z "$VAULT_TOKEN" ]]; then
    log "Vault login misslyckades - kontrollera lösenord och att Netbird är uppe"
    exit 1
fi
export VAULT_TOKEN
log "Inloggad i Vault"

# --- Git identitet ---
if [[ ! -f "$HOME/.config/git/local/personal.conf" ]]; then
    GIT_NAME=$(vault kv get -field=name kv/config/git 2>/dev/null || echo '')
    GIT_EMAIL=$(vault kv get -field=email kv/config/git 2>/dev/null || echo '')
    if [[ -n "$GIT_NAME" && -n "$GIT_EMAIL" ]]; then
        mkdir -p "$HOME/.config/git/local"
        printf '[user]\n    name = %s\n    email = %s\n' "$GIT_NAME" "$GIT_EMAIL" \
            > "$HOME/.config/git/local/personal.conf"
        chmod 600 "$HOME/.config/git/local/personal.conf"
        log "Git identitet hämtad från Vault"
    fi
fi

# --- SSH-nycklar ---
log "Hämtar SSH-nycklar från Vault..."
mkdir -p "$HOME/.ssh/keys"
chmod 700 "$HOME/.ssh"

for key in homelab personal; do
    if vault kv get kv/ssh/$key &>/dev/null; then
        vault kv get -field=private_key kv/ssh/$key > "$HOME/.ssh/keys/$key"
        vault kv get -field=public_key  kv/ssh/$key > "$HOME/.ssh/keys/$key.pub" 2>/dev/null || true
        chmod 600 "$HOME/.ssh/keys/$key"
        log "  $key hämtad"
    else
        log "  $key saknas i Vault (hoppar över)"
    fi
done

# --- SSH agent ---
export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
    ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null 2>&1
fi
ssh-add "$HOME/.ssh/keys/personal" 2>/dev/null || true

# --- Notes repo ---
if [[ ! -d "$HOME/notes/.git" ]]; then
    log "Klonar notes-repo..."
    git clone git@git.amandus.xyz:aafrus/notes.git "$HOME/notes" 2>/dev/null \
        && log "  notes klonat till ~/notes" \
        || log "  notes kunde inte klonas - kör manuellt: git clone git@git.amandus.xyz:aafrus/notes.git ~/notes"
else
    log "  ~/notes finns redan"
fi

echo ""
log "Klar!"
log "Testa GitHub:  ssh -T git@github.com"
log "Testa Gitea:   ssh -T git@git.amandus.xyz"
log "Testa homelab: ssh <din-server>"
