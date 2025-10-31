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
# Instalação do yay (caso não esteja presente)
# ================================================================
if ! command -v yay &> /dev/null; then
  log "yay não encontrado, instalando..."
  pacman -S --needed --noconfirm git base-devel
  su - "$SUDO_USER" -c "git clone https://aur.archlinux.org/yay.git /tmp/yay"
  su - "$SUDO_USER" -c "cd /tmp/yay && makepkg -si --noconfirm"
  log "yay instalado com sucesso!"
else
  log "yay já está instalado."
fi

# Atualiza o sistema com yay
log "Atualizando pacotes do sistema..."
yay -Syu --noconfirm

# ================================================================
# Instalação do Node.js, npm e NVM via NVM
# ================================================================
log "Instalando dependências para o NVM..."
yay -S --noconfirm curl git

log "Instalando NVM (Node Version Manager)..."
su - "$SUDO_USER" -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash"

log "Configurando NVM e instalando Node.js LTS..."
su - "$SUDO_USER" -c '
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
  nvm alias default lts/*
  echo "Node.js e npm instalados:"
  node -v
  npm -v
'

# ================================================================
# Instalação do VS Code
# ================================================================
log "Instalando Visual Studio Code..."
yay -S --noconfirm visual-studio-code-bin
log "VS Code instalado com sucesso!"

# ================================================================
# Instalação do Stow e clonagem dos dotfiles
# ================================================================
log "Instalando GNU Stow..."
yay -S --noconfirm stow

log "Clonando repositório de dotfiles..."
su - "$SUDO_USER" -c '
  cd ~
  if [ ! -d "$HOME/dotfiles" ]; then
    git clone https://github.com/notliad/dotfiles.git
    echo "Repositório clonado em ~/dotfiles"
  else
    echo "Repositório ~/dotfiles já existe, pulando..."
  fi
'

log "Aplicando dotfiles com Stow..."
su - "$SUDO_USER" -c '
  cd ~/dotfiles
  for dir in Code waybar hypr fish; do
    if [ -d "$dir" ]; then
      echo "Aplicando stow em $dir..."
      stow "$dir"
    else
      echo "Diretório $dir não encontrado em ~/dotfiles, pulando..."
    fi
  done
'

# ================================================================
# Instalação do Tilix e Fish shell
# ================================================================
log "Instalando Tilix e Fish shell..."
yay -S --noconfirm tilix fish

log "Definindo Fish como shell padrão do usuário..."
chsh -s "$(which fish)" "$SUDO_USER"

# ================================================================
# Configuração de plugins do Fish
# ================================================================
log "Instalando Fisher e plugins do Fish..."
su - "$SUDO_USER" -c '
  export PATH="$HOME/.nvm/versions/node/$(nvm version)/bin:$PATH"
  fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
  fish -c "fisher install patrickf1/fzf.fish"
  echo "Fisher e plugins instalados com sucesso!"
'

# ================================================================
log "Pós-instalação concluída!"
