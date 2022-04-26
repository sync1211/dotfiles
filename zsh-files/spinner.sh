#!/usr/bin/env bash

spinstr='\|/-'
delay='0.5'
idle=false
LBox="["
RBox="]"

if [ "$1" == "--idle" ]; then 
    idle=true
    shift
fi

if [ "$1" == "--help" ]; then
    echo "Usage: spinner (--idle) (<theme>) (<box>) (--text <text>) <command>"
    echo ""
    echo "Themes: "
    echo "   --pixel"
    echo "   --pixelI"
    echo "   --circleL"
    echo "   --circleR"
    echo "   --bounce"
    echo "   --clock"
    echo ""
    echo "Box: "
    echo "   --nobox"
    echo "   --roundbox"
    echo "   --curlybox"
    echo "   --straightbox"
    echo ""
    echo "Idle: "
    echo "   --idle"
    echo ""
    exit 0
fi

if [ "$1" == "--digi" ] || [ "$1" == "--pixel" ]; then
    spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    delay='0.1'
    LBox=""
    RBox=""
    shift
elif [ "$1" == "--digiI" ] || [ "$1" == "--pixelI" ]; then
    spinstr='⣾⣻⢿⡿⣟⣯⣷'
    delay='0.1'
    LBox=""
    RBox=""
    shift
elif [ "$1" == "--circleR" ]; then
    spinstr="◐◓◑◒"
    delay='0.08'
    LBox=""
    RBox=""
    shift
elif [ "$1" == "--circleL" ]; then
    spinstr="◐◓◑◒"
    delay='0.08'
    LBox=""
    RBox=""
    shift
elif [ "$1" == "--bounce" ]; then
    spinstr="⠁⠂⠄⠂"
    delay='0.12'
    shift
elif [ "$1" == "--clock" ]; then
    spinstr="🕛🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚"
    delay='0.08'
    LBox=""
    RBox=""
    shift
fi


if [ "$1" == "--nobox" ]; then
    LBox=""
    RBox=""
    shift
elif [ "$1" == "--roundbox" ]; then
    LBox="("
    RBox=")"
    shift
elif [ "$1" == "--curlybox" ]; then
    LBox="{"
    RBox="}"
    shift
elif [ "$1" == "--straightbox" ]; then
    LBox="|"
    RBox="|"
    shift
fi

if [ "$1" == "--text" ]; then
    shift
    spinnertext="$1"
    spinnertextrm=""
    for ((n=0;n<${#spinnertext};n++)); do 
      spinnertextrm+="\b"
    done

    shift
else
    spinnertext=""
    spinnertextrm=""
fi

show_spinner()
{
  if $idle; then
      local pid="PID"
  else
        local -r pid="${1}"
    fi
  local temp
  while ps a | awk '{print $1}' | grep -q "${pid}"  ; do
    temp="${spinstr#?}"
    echo -n "$LBox${spinstr::1}$RBox $spinnertext"
        
    spinstr=${temp}${spinstr%"${temp}"}
    sleep "${delay}"
    printf "\b\b\b\b${spinnertextrm}"
  done
    printf "\b\b\b\b${spinnertextrm}"
}

("$@") &
#cmd="$@"
#eval ${cmd}
show_spinner "$!"
