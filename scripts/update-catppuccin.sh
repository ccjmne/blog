#! /bin/sh -eu

readonly project="$(readlink -f "$0" | xargs dirname | xargs dirname)"

t=$(mktemp --directory)
( cd $t && pnpm install @catppuccin/palette )
mv $t/node_modules/@catppuccin/palette/scss/_catppuccin.scss "$project/sass"
