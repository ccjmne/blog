#! /bin/sh

readonly project="$(readlink -f "$0" | xargs dirname | xargs dirname)"

cargo run --manifest-path update-catppuccin/Cargo.toml -- \
    <(curl -Ls https://github.com/catppuccin/sublime-text/raw/refs/heads/main/build/Catppuccin%20Latte.sublime-color-scheme) \
    > "$project/static/latte.css"

cargo run --manifest-path update-catppuccin/Cargo.toml -- \
    <(curl -Ls https://github.com/catppuccin/sublime-text/raw/refs/heads/main/build/Catppuccin%20Mocha.sublime-color-scheme) \
    > "$project/static/mocha.css"

t=$(mktemp --directory)
( cd $t && pnpm install @catppuccin/palette )
mv $t/node_modules/@catppuccin/palette/scss/_catppuccin.scss "$project/sass"
