#!/usr/bin/env bash
# ==============================================
# Script de pós-instalação - Omarchy (Arch Linux)
# Autor: Dailton
# ==============================================

log() {
  echo -e "\033[1;32m[+] $1\033[0m"
}

erro() {
  echo -e "\033[1;31m[!] $1\033[0m" >&2
}

# Verifica se está como root
if [[ $EUID -ne 0 ]]; then
  erro "Este script precisa ser executado como root!"
  exit 1
fi

log "Iniciando pós-instalação do Omarchy..."

# ================================================================
# Atualização do sistema
# ================================================================
log "Atualizando pacotes do sistema..."
yay -Syu --noconfirm

# ================================================================
# Node.js, npm e NVM
# ================================================================
log "Instalando dependências para o NVM..."
yay -S --noconfirm curl git base-devel

log "Instalando NVM (Node Version Manager)..."
su - "$SUDO_USER" -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash"

log "Instalando Node.js LTS via NVM..."
su - "$SUDO_USER" -c '
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
  nvm alias default lts/*
'

log "Node.js e npm instalados com sucesso!"
su - "$SUDO_USER" -c "node -v && npm -v"

# ================================================================
# VSCode
# ================================================================
log "Instalando Visual Studio Code..."
yay -S --noconfirm visual-studio-code-bin

# ================================================================
# Stow + Dotfiles
# ================================================================
log "Instalando GNU Stow..."
yay -S --noconfirm stow

log "Clonando repositório de dotfiles..."
su - "$SUDO_USER" -c "git clone https://github.com/notliad/dotfiles.git ~/dotfiles"

log "Aplicando dotfiles com Stow..."
su - "$SUDO_USER" -c "cd ~/dotfiles && stow Code waybar hypr fish"

# ================================================================
# wttrbar (widget de clima para Waybar)
# ================================================================
log "Instalando wttrbar..."
yay -S --noconfirm wttrbar

# ================================================================
log "Pós-instalação concluída com sucesso!"
