#!/bin/bash
for i in {0..511}; do
    printf "\e[38;5;%dm%03d: %b \e[m" "$((i%16))" "$i" "$(printf '\\u%04x' $i)"  # Index + Unicode attempt (may fallback)
    if (( (i+1) % 16 == 0 )); then echo; fi  # New line every 16
done | iconv -c -f UTF-8 -t UTF-8
