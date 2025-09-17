#! /bin/sh -eu

readonly project="$(readlink -f "$0" | xargs dirname | xargs dirname)"

# Get only the anchor: ⚓
readonly noto=$(curl -Ls 'https://fonts.googleapis.com/css2?family=Noto+Sans+Symbols&text=%e2%9a%93')

# Get the full fonts:
readonly ouft=$(curl -Ls 'https://fonts.googleapis.com/css2?family=Outfit:wght@400;500')
readonly work=$(curl -Ls 'https://fonts.googleapis.com/css2?family=Work+Sans:ital,wght@0,400;0,600;1,400')
readonly fira=$(curl -Ls 'https://fonts.googleapis.com/css2?family=Fira+Code')

preload=()
style=()
for font in noto ouft work fira; do
    i=1
    while read -r ff; do
        file=$font-$((i++))
        curl -Ls $(grep -Po '(?<=url\()[^)]+' <<< "$ff") -o $file.ttf
        woff2_compress $file.ttf
        preload+=("<link rel=\"preload\" href=\"{{ get_url(path=\"/$file.woff2\") }}\" as=\"font\" type=\"font/woff2\" crossorigin>")
        style+=("  $(echo $ff | sed "s,url[^)]*),url('{{ get_url(path=\"/$file.woff2\") }}')," | sed "s,format[^)]*),format('woff2'),")")
    done < <(echo "${!font}" | sed -n 'H; /^}$/ { x;s/\n\s*/ /g;p;s/.*//;h }')
done

mkdir -p "$project/static" "$project/templates/partials"
rm *.ttf
mv *.woff2 "$project/static"
{
    printf "%s\n" "${preload[@]}"
    printf '<style type="text/css">'
    printf "%s\n" "${style[@]}"
    printf '</style>'
} > "$project/templates/partials/fonts.html"
