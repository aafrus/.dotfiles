#!/usr/bin/env bash
set -euo pipefail

FAIL=0

ok() {
    printf '[ok] %s\n' "$*"
}

warn() {
    printf '[warn] %s\n' "$*"
}

err() {
    printf '[err] %s\n' "$*"
    FAIL=1
}

check_file() {
    local path="$1"
    if [[ -f "$path" ]]; then
        ok "Found $path"
    else
        err "Missing $path"
    fi
}

check_placeholder() {
    local path="$1"
    if [[ ! -f "$path" ]]; then
        return 0
    fi
    if grep -Eq '<[A-Z_]+>' "$path"; then
        warn "Placeholder detected in $path"
    else
        ok "No placeholder in $path"
    fi
}

echo "== Core files =="
check_file "$HOME/.gitconfig"
check_file "$HOME/.zshrc"
check_file "$HOME/.ssh/config"
check_file "$HOME/.config/git/local/default.conf"
check_file "$HOME/.config/git/local/personal.conf"
check_file "$HOME/.config/git/local/work.conf"
check_file "$HOME/.config/git/local/school.conf"

echo "== Identity placeholders =="
check_placeholder "$HOME/.config/git/local/default.conf"
check_placeholder "$HOME/.config/git/local/personal.conf"
check_placeholder "$HOME/.config/git/local/work.conf"
check_placeholder "$HOME/.config/git/local/school.conf"

echo "== IncludeIf rules =="
if ! git config --global --show-origin --get-regexp '^includeIf\..*\.path$'; then
    warn "No includeIf rules found"
fi

echo "== SSH github test =="
SSH_OUT="$(ssh -o BatchMode=yes -T git@github.com 2>&1 || true)"
if printf '%s\n' "$SSH_OUT" | grep -q 'successfully authenticated'; then
    ok "GitHub SSH auth works"
else
    warn "GitHub SSH auth not ready"
fi

echo "== SSH homelab test =="
HOMELAB_HOST=$(grep HostName "$HOME/.ssh/config.d/"*homelab* 2>/dev/null | awk '{print $2}' | head -1)
if [[ -z "$HOMELAB_HOST" ]]; then
    warn "Ingen homelab SSH-config hittad"
elif ssh -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new \
        -i "$HOME/.ssh/keys/homelab" "ns@$HOMELAB_HOST" true 2>/dev/null; then
    ok "Homelab SSH funkar (lösenordsfritt)"
else
    warn "Homelab SSH nåbar men lösenord krävs - kör setup.sh"
fi

echo "== Hub paths =="
for path in \
    "$HOME/hub/projects" \
    "$HOME/hub/personal" \
    "$HOME/hub/work" \
    "$HOME/hub/school"; do
    if [[ -d "$path" ]]; then
        ok "Found $path"
    else
        warn "Missing $path"
    fi
done

echo "== Result =="
if [[ "$FAIL" -eq 0 ]]; then
    ok "Verification finished"
    exit 0
fi

err "Verification failed"
exit 1
