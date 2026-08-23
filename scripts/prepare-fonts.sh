#! /bin/sh -eu

readonly project="$(readlink -f "$0" | xargs dirname | xargs dirname)"

# Get the full fonts:
readonly ouft=$(curl -Ls 'https://fonts.googleapis.com/css2?family=Outfit:wght@500&display=swap')
readonly work=$(curl -Ls 'https://fonts.googleapis.com/css2?family=Work+Sans:ital,wght@0,400;0,600;1,400&display=swap')
readonly fira=$(curl -Ls 'https://fonts.googleapis.com/css2?family=Fira+Code:wght@400;600&display=swap')
readonly noto=$(curl -Ls 'https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500&display=optional')

preload=()
style=()
for font in ouft work fira noto; do
    i=1
    while read -r ff; do
        file=$font-$((i++))
        curl -Ls $(grep -Po '(?<=url\()[^)]+' <<< "$ff") -o $file.ttf
        woff2_compress $file.ttf
        if [[ $file == ouft-1 || $file == work-[23] ]]; then # above-the-fold fonts
            preload+=("<link rel=\"preload\" href=\"{{ get_url(path=\"/$file.woff2\", cachebust=true) }}\" as=\"font\" type=\"font/woff2\" crossorigin>")
        fi
        style+=("  $(echo $ff | sed "s|url[^)]*)|url('{{ get_url(path=\"/$file.woff2\", cachebust=true) }}')|" | sed "s,format[^)]*),format('woff2'),")")
    done < <(echo "${!font}" | sed -n 'H; /^}$/ { x;s/\n\s*/ /g;p;s/.*//;h }')
done

mkdir -p "$project/static" "$project/templates/partials"
rm -- *.ttf "$project/static"/*.woff2
mv -- *.woff2 "$project/static"
{
    printf "%s\n" "${preload[@]}"
    printf '<style type="text/css">\n'
    printf "%s\n" "${style[@]}"
    printf '</style>'
} > "$project/templates/partials/fonts.html"
