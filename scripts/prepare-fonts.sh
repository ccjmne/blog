#! /bin/sh -eu

readonly project="$(readlink -f "$0" | xargs dirname | xargs dirname)"

# Get only the anchor: ⚓
readonly noto=$(curl -L 'https://fonts.googleapis.com/css2?family=Noto+Sans+Symbols&text=%e2%9a%93' | grep -Po '(?<=url\()[^)]+')

# Get the full font
readonly outfit=$(curl -L 'https://fonts.googleapis.com/css2?family=Outfit:wght@500' | grep -Po '(?<=url\()[^)]+')
readonly work=$(curl -L 'https://fonts.googleapis.com/css2?family=Work+Sans:wght@400' | grep -Po '(?<=url\()[^)]+')
readonly fira=$(curl -L 'https://fonts.googleapis.com/css2?family=Fira+Code' | grep -Po '(?<=url\()[^)]+')

for font in outfit work noto fira; do
    curl -L "${!font}" -o $font.ttf
    woff2_compress $font.ttf
done

rm *.ttf
mv *.woff2 "$project/static"
