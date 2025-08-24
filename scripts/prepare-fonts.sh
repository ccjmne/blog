#! /bin/sh -eu

readonly project="$(readlink -f "$0" | xargs dirname | xargs dirname)"

# Get only the following glyphs: 0123456789+-,.abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
readonly outfit=$(curl -L 'https://fonts.googleapis.com/css2?family=Outfit:wght@400&text=0123456789%2B-%2C.abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' | grep -Po '(?<=url\()[^)]+')

# Get only the anchor: ⚓
readonly noto=$(curl -L 'https://fonts.googleapis.com/css2?family=Noto+Sans+Symbols&text=%e2%9a%93' | grep -Po '(?<=url\()[^)]+')

# Get the full font
readonly hedvig=$(curl -L 'https://fonts.googleapis.com/css2?family=Hedvig+Letters+Serif' | grep -Po '(?<=url\()[^)]+')
readonly fira=$(curl -L 'https://fonts.googleapis.com/css2?family=Fira+Code' | grep -Po '(?<=url\()[^)]+')

for font in outfit hedvig noto fira; do
    curl -L "${!font}" -o $font.ttf
    woff2_compress $font.ttf
done

rm *.ttf
mv *.woff2 "$project/static"
