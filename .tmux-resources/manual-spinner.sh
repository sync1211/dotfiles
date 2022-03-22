#!/bin/bash

#manual spinner for tmux
source ~/.zsh-files/resources/manual-spinner.conf || spinchar="☱☲☴"

#Alternatives:
#"☱☲☴"
#"⌏⌎⌌⌍"
#"☰☱☳☷☶☴"

echo 'spinchar="'${spinchar[@]:1}${spinchar::1}'"'  > ~/.zsh-files/resources/manual-spinner.conf 
echo -n ${spinchar::1}
