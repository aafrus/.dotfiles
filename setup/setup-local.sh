#!/bin/bash
# Kör detta på en ny dator efter bootstrap.sh

set -euo pipefail

log() { printf '[setup-local] %s\n' "$*"; }

echo "=== Lokal setup ==="

# --- Väder ---
read -p "Väderplats (stad): " LOCATION
mkdir -p "$HOME/.config/local"
echo "$LOCATION" > "$HOME/.config/local/weather-location"

# --- Git identitet ---
read -p "Git namn (personlig): " GIT_NAME
read -p "Git email (personlig): " GIT_EMAIL
mkdir -p "$HOME/.config/git/local"
cat > "$HOME/.config/git/local/personal.conf" <<EOF
[user]
    name = $GIT_NAME
    email = $GIT_EMAIL
EOF
chmod 600 "$HOME/.config/git/local/personal.conf"
log "Git personlig identitet sparad"

# --- pass-cli + SSH ---
log "Kontrollerar pass-cli..."
if ! command -v pass-cli &>/dev/null; then
    log "pass-cli hittades inte i PATH — installera det och kör om detta skript"
    log "Hämta från: https://github.com/protonpass/pass-cli"
    exit 1
fi

if ! pass-cli test &>/dev/null; then
    log "Loggar in på Proton Pass..."
    pass-cli login
fi

log "Laddar SSH-nycklar från Proton Pass..."
pass-cli ssh-agent load --vault-name keys

log "Exporterar publika nycklar till ~/.ssh/keys/"
mkdir -p "$HOME/.ssh/keys"
for title in personal school homelab work; do
    pass-cli item view --vault-name keys --item-title "$title" 2>/dev/null \
        | grep "Public key" \
        | sed 's/- Public key: //' \
        > "$HOME/.ssh/keys/${title}.pub" \
        && log "  ${title}.pub exporterad" \
        || log "  $title hittades inte i Proton Pass (hoppar över)"
done
chmod 600 "$HOME/.ssh/keys/"*.pub 2>/dev/null || true

echo ""
log "Klar! SSH-nycklar laddade och pub-filer exporterade."
log "Verifiera med: ssh-add -l"
log "Testa GitHub:  ssh -T git@github.com"
