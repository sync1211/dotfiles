# Dotfiles

A collection of scripts, configs and aliases I've accumulated over the years.

## Requirements

### Vim
* [Vundle](https://github.com/VundleVim/Vundle.vim)

### Termux
* [Youtube-DL](https://github.com/ytdl-org/youtube-dl) or [yt-dlp](https://github.com/yt-dlp/yt-dlp)

### Zsh
* [oh-my-zsh](https://ohmyz.sh)

## Installation

Unless stated, all configs can be installed by copying them into your `$HOME` directory.

### Termux

```
mkdir ~/bin
cp Termux/termux-url-opener ~/bin
```

### Neovim
```
cp nvimrc .config/nvim/init.vim
```

### ZSH
```
cp zshrc ~/.zshrc
cp -r zsh-files ~/zsh-files
```

### ZSH-Themes
```
cp themes/zsh/* .oh-my-zsh/themes/
```

### PowerShell
```
mkdir $env:USERPROFILE\Documents\WindowsPowerShell
cp PowerShell/Microsoft.PowerShell_profile $PROFILE
cp PowerShell/NumLock.ico $env:USERPROFILE\Documents\WindowsPowerShell
cp PowerShell/CapsLock.ico $env:USERPROFILE\Documents\WindowsPowerShell
```

## Customization

Some configuration files (e.g. `.tmux.conf`) contain alternative configurations which can be enabled by commenting or uncommenting certain lines.