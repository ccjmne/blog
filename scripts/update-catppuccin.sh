#! /bin/sh -eu

readonly project="$(readlink -f "$0" | xargs dirname | xargs dirname)"

cargo run --manifest-path "$project/scripts/compile-catppuccin-syntax/Cargo.toml" -- \
    <(curl -Ls https://github.com/catppuccin/sublime-text/raw/refs/heads/main/build/Catppuccin%20Latte.sublime-color-scheme) \
    > "$project/static/light.css"

cargo run --manifest-path "$project/scripts/compile-catppuccin-syntax/Cargo.toml" -- \
    <(curl -Ls https://github.com/catppuccin/sublime-text/raw/refs/heads/main/build/Catppuccin%20Macchiato.sublime-color-scheme) \
    > "$project/static/dark.css"

t=$(mktemp --directory)
( cd $t && pnpm install @catppuccin/palette )
mv $t/node_modules/@catppuccin/palette/scss/_catppuccin.scss "$project/sass"
