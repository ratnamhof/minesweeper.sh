#!/bin/bash

# Mine Sweeper   version 1.3   may 2020   written by Feherke, adapted by cbom
# the classic game in text mode


shopt -s extglob
IFS=''

piece=( $'\e[1;30m.' $'\e[1;34m1' $'\e[1;32m2' $'\e[1;35m3' $'\e[1;36m4' $'\e[1;31m5' $'\e[1;33m6' $'\e[1;37m7' $'\e[0;40;37m8' $'\e[0;40;37m#' $'\e[0;40;31mF' $'\e[0;40;33m?' $'\e[1;31m*' $'\e[0;40;31mx' )
size=( 'S ' 10 10 15   'M ' 15 15 33   'L ' 20 20 60   'XL' 30 20 90   'E' 30 16 99 )

function drawboard()
{

  tput 'cup' 2 0
  echo -n $'\e[40m'
  for ((j=0;j<my;j++)); do for ((i=0;i<mx;i++)); do echo -n " ${piece[board[j*mx+i]]}"; done; echo ' '; done
  echo -n $'\e[0m'

}

function newgame()
{

  unset board bomb neighbors START

  echo -n $'\e[0m'
  clear
  echo 'Mine Sweeper   version 1.3   June 2020'

  if [[ $1 =~ [MmNne] ]]; then
    #  n="$( expr index 'nNmM' "$1" )" # line kept as human readable version :(
    n='MmNne'; n="${n%$1*}"; n=${#n}
    mx=${size[n*4+1]}; my=${size[n*4+2]}; mb=${size[n*4+3]}; bs=${size[n*4]}
  elif [[ $1 =~ c ]]; then
    int='^[1-9][0-9]*$'
    tput cnorm
    while :; do
      read -p "> number of columns: " mx
      [[ "$mx" =~ $int ]] && break
    done
    while :; do
      read -p "> number of rows: " my
      [[ "$my" =~ $int ]] && break
    done
    while :; do
        read -p "> number of mines (<=$(($mx*$my))): " mb
      [[ "$mb" =~ $int ]] && (($mb<=$mx*$my)) && break
    done
    tput civis
    bs=C
  fi
  # mf: number of flags placed, mfc: number of correct flags placed
  mf=0; mfc=0

  clear
  echo 'Mine Sweeper   version 1.3   June 2020'
  info="board:$bs  size:$mx*$my  mines:$mb  flags:"
  echo "$info$mf"
  width=$((${#info}+${#mb}+2))

  for ((i=0;i<mx*my;i++)); do bomb[i]=0; board[i]=9; neighbors[i]=0; done
  for ((i=0;i<mb;i++)); do
    while :; do
      r=$(( RANDOM%(mx*my) ));
      (( bomb[r] )) || break;
    done;
    bomb[r]=1;
    for ((j=-1;j<=+1;j++)); do for ((k=-1;k<=+1;k++)); do
      sy=$((r/mx)); sx=$((r-sy*mx))
      (( ( j!=0 || k!=0 ) && sx+j>=0 && sx+j<mx && sy+k>=0 && sy+k<my )) && ((neighbors[r+k*mx+j]++))
    done; done
  done

  drawboard
  echo $'<\e[1mh\e[0m/\e[1mj\e[0m/\e[1mk\e[0m/\e[1ml\e[0m> Move <\e[1mg\e[0m> Step <\e[1mf\e[0m> Flag <\e[1mM\e[0m/\e[1mm\e[0m/\e[1mN\e[0m/\e[1mn\e[0m/\e[1me\e[0m/\e[1mc\e[0m/\e[1mb\e[0m> New <\e[1mq\e[0m> Quit'

  cx=$(((mx-1)/2)); cy=$(((my-1)/2))
  status=1

}

function gameover()
{

  for ((i=0;i<mx;i++)); do for ((j=0;j<my;j++)); do
    (( bomb[j*mx+i]==1 && board[j*mx+i]==9 )) && board[j*mx+i]=12
    (( bomb[j*mx+i]==0 && board[j*mx+i]==10 )) && board[j*mx+i]=13
  done; done

  drawboard
  tput 'cup' 1 $width
  echo -n $'\e[43;30m:(\e[0m'

  status=0

}

function makestep()
{

  local i j
  local l ll
  local sx sy
  local nb nf nfc
  local toopen
  local padding emoji

  l=$((cy*mx+cx))

  (( board[l]==0 )) && return
  (( bomb[l]==1 )) && { gameover; return; }
  (( board[l]==10 )) && (( mf-- ))

  [[ "$START" ]] || START=$(date +%s)

  tput 'cup' 1 $width
  echo -n $'\e[43;30m:o\e[0m'

  emoji=':)'
  if [[ "${board[l]}" == @(9|10|11) ]]; then
    board[l]=${neighbors[l]}
    (( neighbors[l]==0 )) && {
      doopen=($l)
      openregion
    }
  else
    sy=$((l/mx)); sx=$((l-sy*mx))
    nb=0; nf=0; nfc=0; toopen=(); doopen=()
    for ((i=-1;i<=+1;i++)); do for ((j=-1;j<=+1;j++)); do
      if (( ( i!=0 || j!=0 ) && sx+i>=0 && sx+i<mx && sy+j>=0 && sy+j<my )); then
        ll=$((l+i+j*mx))
        (( bomb[ll]==1 )) && (( nb++ ))
        if (( board[ll]==10 )); then
          (( nf++ ))
          (( bomb[ll]==1 )) && (( nfc++ ))
        elif (( board[ll]==9 || board[ll]==11 )); then
          toopen+=(${ll})
        fi
      fi
    done; done
    if (( nf==nb && nf==nfc )); then
      for l in "${toopen[@]}"; do
        board[l]=${neighbors[l]}
        (( neighbors[l]==0 )) && doopen+=($l)
      done
      openregion
    else
      emoji=':X'
    fi
  fi

  padding='  '; for ((i=1;i<=$((${#mb}-${#mf}));i++)); do padding+=' '; done
  drawboard
  tput 'cup' 1 ${#info}
  echo -en "\e[0m$mf$padding\e[43;30m$emoji\e[0m"
  checkstatus

}

function openregion()
{

  local i j
  local l ll
  local sx sy
  local toopen

  while [[ $doopen ]]; do
    toopen=()
    for l in "${doopen[@]}"; do
      sy=$((l/mx)); sx=$((l-sy*mx))
      for ((i=-1;i<=+1;i++)); do for ((j=-1;j<=+1;j++)); do
        if (( ( i!=0 || j!=0 ) && sx+i>=0 && sx+i<mx && sy+j>=0 && sy+j<my )); then
          ll=$((l+i+j*mx))
          if [[ "${board[ll]}" == @(9|10|11) ]]; then
            (( board[ll]==10 )) && (( mf-- ))
            board[ll]=${neighbors[ll]}
            (( neighbors[ll]==0 )) && toopen+=(${ll})
          fi
        fi
      done; done
    done
    doopen=("${toopen[@]}")
  done

}

function putflag()
{

  local padding

  [[ "$START" ]] || START=$(date +%s)

  [[ ${board[cy*mx+cx]} != @(9|10|11) ]] && return

  board[cy*mx+cx]=$(( (board[cy*mx+cx]-9+1)%3+9 ))

  (( board[cy*mx+cx]==10 )) && (( mf++ ))
  (( board[cy*mx+cx]==10 )) && (( bomb[cy*mx+cx]==1 )) && (( mfc++ ))
  (( board[cy*mx+cx]==11 )) && (( mf-- ))
  (( board[cy*mx+cx]==11 )) && (( bomb[cy*mx+cx]==1 )) && (( mfc-- ))

  checkstatus

  padding='  '; for ((i=1;i<=$((${#mb}-${#mf}));i++)); do padding+=' '; done
  tput 'cup' 1 ${#info}
  echo -en "\e[0m$mf$padding"; ((status==0)) && echo -en "\e[43;30m:D\e[0m"

}

function checkstatus()
{

  n=0
  for block in "${board[@]}"; do
      [[ $block =~ (9|10|11) ]] && ((n++))
  done

  (( mfc==mb && mfc==mf || n==mb )) && {
    tput 'cup' 1 $width
    echo -n $'\e[43;30m:D\e[0m'"  Time:$(date -d@$(($(date +%s) - $START)) -u +%H:%M:%S)"
    status=0
  }

}

# |\/| /\ | |\|

tput civis

newgame 'e'

while :; do

  tput 'cup' $(( cy+2 )) $(( cx*2 ))
  echo -en "\e[1;40;37m[${piece[board[cy*mx+cx]]}\e[1;37m]\b\b"

  read -s -n 1 a
  [[ "$a" == '' ]] && { read -s -n 1 a; [[ "$a" == '[' ]] && read -s -n 1 a; }
  
  echo -en "\b ${piece[board[cy*mx+cx]]} \b\b"

  (( status!=1 )) && [[ "$a" != [MmNnecbrq] ]] && continue

  case "$a" in
    'h'|'a'|'D'|'4') (( cx>0?cx--:0 )) ;;
    'j'|'s'|'B'|'2') (( cy<my-1?cy++:0 )) ;;
    'k'|'w'|'A'|'8') (( cy>0?cy--:0 )) ;;
    'l'|'d'|'C'|'6') (( cx<mx-1?cx++:0 )) ;;
    'g'|' '|'') makestep ;;
    'f'|'0') putflag ;;
    'M'|'m'|'N'|'n'|'e'|'c'|'b') newgame "$a" ;;
    'r') drawboard ;;
    'q') break ;;
  esac

done

echo -n $'\e[0m'
tput cnorm
clear
