# 🛠️ Dotfiles - Omarchy

Repositório de configurações pessoais para ambiente Linux (Arch Linux) com foco em produtividade e customização.

## 📋 Conteúdo

Este repositório contém as configurações para:

### 🔧 Aplicações

- **Code** - Configurações do VS Code
- **Fish Shell** - Shell interativo com configurações customizadas
- **Hyprland** - Gerenciador de janelas tiling (compositor Wayland)
- **Waybar** - Barra de tarefas/status para Wayland
- **Pritunl** - Configurações de VPN

### 📦 Instalação

O repositório inclui um script de pós-instalação automatizado:

```bash
sudo bash install.sh
```

Este script realiza:
- Atualização completa do sistema
- Instalação do Node.js via NVM
- Instalação de dependências
- Configuração do ambiente

> ⚠️ **Requisito**: Executar como root

## 🏗️ Estrutura do Projeto

```
dotfiles/
├── install.sh          # Script de pós-instalação
├── Code/              # Configurações do VS Code
│   └── .config/Code/
├── fish/              # Configurações do Fish Shell
│   └── .config/fish/
├── hypr/              # Configurações do Hyprland
│   └── .config/hypr/
├── waybar/            # Configurações do Waybar
│   └── .config/waybar/
├── pritunl/           # Configurações do Pritunl
│   └── .config/pritunl/
└── walker/            # Configurações do Walker
    └── .config/walker/
```

## 🚀 Uso

### Instalação Inicial

1. Clone o repositório:
```bash
git clone https://github.com/notliad/dotfiles.git
cd dotfiles
```

2. Execute o script de instalação:
```bash
sudo bash install.sh
```

### Sincronização de Configurações

Para copiar as configurações para seu sistema:

```bash
# Copiar todas as configurações
cp -r */. ~/.config/
```

## 🔨 Configurações Incluídas

### Hyprland
Gerenciador de janelas moderno para Wayland com suporte a:
- Workspaces dinâmicos
- Bindings customizados
- Temas personalizados

### Fish Shell
Shell moderno com:
- Autocompletar inteligente
- Syntax highlighting
- Aliases customizados

### Waybar
Barra de status com:
- Monitores de CPU, RAM e disco
- Controle de volume e brilho
- Mostrador de data/hora
- Integração com aplicações

### VS Code
Extensões e preferências para:
- Desenvolvimento web e Node.js
- Formatação automática
- Temas customizados

## 👤 Autor

**Dailton** - notliad

## 📝 Licença

Este projeto é fornecido como está. Sinta-se livre para adaptar e personalizar conforme necessário.

## 🤝 Contribuições

Sugestões e melhorias são bem-vindas! Abra uma issue ou pull request se tiver ideias para melhorar as configurações.

---

**Última atualização**: Novembro de 2025
