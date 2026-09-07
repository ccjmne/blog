setl cms={#\ %s\ #}
setl fo-=t

nmap <Leader>p    o<pre>{{ ^ \| json_encode(pretty=true) }}</pre>F^cl
vmap <Leader>p "vyo<pre>{{ ^ \| json_encode(pretty=true) }}</pre>F^v"vp
