{
    echo -n '<pre class="z-code"><code>'
    terminal-to-html | sed -e 's/ term-fg1//g; s/term-fg31/z-string/g; s/term-fg32/z-variable/g; s/term-fg33/z-constant/g'
    echo -n '</pre></code>'
} | wl-copy
