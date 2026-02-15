#!/usr/bin/env bash
set -euo pipefail

OUT="$(xrandr --query | awk '/ connected/{print $1; exit}')"

[ -n "${OUT:-}" ] || exit 0

native_mode="$(xrandr | awk -v o="$OUT" '$1==o {f=1} f && /\*/ {print $1; exit}')"
[ -z "$native_mode" ] && native_mode="1920x1080"

modes_pool=(
  "$native_mode"
  "3840x2160" "2560x1440" "1920x1080" "1280x1024" "1024x768"
)

mode="${modes_pool[$RANDOM % ${#modes_pool[@]}]}"

scale_pool=(
  "1x1" "2x2" "3x3" "16x16" "32x18" "64x36"
  "80x25" "100x56" "160x90" "320x180" "640x360" "800x600"
  "$mode"
)

sf="${scale_pool[$RANDOM % ${#scale_pool[@]}]}"

rot_pool=("normal" "left" "right" "inverted")
rot="${rot_pool[$RANDOM % ${#rot_pool[@]}]}"

if ! xrandr | grep -q " $mode"; then
  mode="$native_mode"
fi

xrandr --output "$OUT" --mode "$mode" --rotate "$rot" || true

fw="${sf%x*}"; fh="${sf#*x}"


xrandr --output "$OUT" --scale-from "${fw}x${fh}" || true

if [ $((RANDOM%5)) -eq 0 ]; then
  read mw mh <<<"$(sed 's/x/ /' <<<"$mode")"
  vx=$((RANDOM % (mw/2 + 1)))
  vy=$((RANDOM % (mh/2 + 1)))
  vw=$(( (RANDOM % (mw/2+1)) + 64 ))
  vh=$(( (RANDOM % (mh/2+1)) + 64 ))
  xrandr --output "$OUT" --panning "${mw}x${mh}+${vx}+${vy}/${vw}x${vh}+0+0" || true
fi

if [ $((RANDOM%10)) -eq 0 ]; then
  (unclutter -idle 0 &>/dev/null &) || true
fi
