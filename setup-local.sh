#!/bin/bash
# Kör detta på en ny dator efter stow för att sätta upp lokal config

echo "=== Lokal setup ==="

read -p "Väderplats (stad): " LOCATION
read -p "Homelab IP: " HOMELAB_IP
read -p "Homelab användare: " HOMELAB_USER
read -p "Homelab SSH-nyckelnamn: " HOMELAB_KEY
read -p "Git namn (personlig): " GIT_NAME
read -p "Git email (personlig): " GIT_EMAIL
read -p "Personlig SSH-nyckelnamn: " PERSONAL_KEY
read -p "Skol SSH-nyckelnamn: " SCHOOL_KEY

# ~/.config/local/
mkdir -p "$HOME/.config/local"
echo "$LOCATION" > "$HOME/.config/local/weather-location"

# SSH - kopiera från example och fyll i
cp "$HOME/.ssh/config.d/03-homelab.conf.example" "$HOME/.ssh/config.d/03-homelab.conf"
cp "$HOME/.ssh/config.d/00-personal.conf.example" "$HOME/.ssh/config.d/00-personal.conf"
cp "$HOME/.ssh/config.d/02-school.conf.example"   "$HOME/.ssh/config.d/02-school.conf"

sed -i "s|INTERNAL_IP|$HOMELAB_IP|; s|USERNAME|$HOMELAB_USER|; s|KEY_NAME|$HOMELAB_KEY|" \
    "$HOME/.ssh/config.d/03-homelab.conf"
sed -i "s|KEY_NAME|$PERSONAL_KEY|g" "$HOME/.ssh/config.d/00-personal.conf"
sed -i "s|KEY_NAME|$SCHOOL_KEY|"    "$HOME/.ssh/config.d/02-school.conf"

# Git - kopiera från example och fyll i
cp "$HOME/.config/git/personal.conf.example" "$HOME/.config/git/personal.conf"
sed -i "s|NAMN|$GIT_NAME|; s|EMAIL|$GIT_EMAIL|" "$HOME/.config/git/personal.conf"

echo ""
echo "Klar! Glöm inte att:"
echo "  - Lägga SSH-nycklar i ~/.ssh/keys/"
echo "  - Köra install-i3a för master-stack layout"
