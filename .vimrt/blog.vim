" Courtesy of https://github.com/vimpostor
" Shared at https://gist.github.com/atripes/15372281209daf5678cded1d410e6c16?permalink_comment_id=5166205#gistcomment-5166205
func UrlEncode(s)
  return a:s->map({_, v -> match(v, '[-_.~a-zA-Z0-9]') ? printf("%%%02X", char2nr(v)) : v})
endfunc

nmap <Leader>p    o<pre>{{ ^ \| json_encode(pretty=true) }}</pre><ESC>F^cl
vmap <Leader>p "vyo<pre>{{ ^ \| json_encode(pretty=true) }}</pre><ESC>F^v"vp
vmap <Leader>a satabbrhi title=""i
vmap <Leader>b sa]/]<Enter>a()<ESC>"+P
nmap <Leader>j !ippar 80
nmap <Leader>k !ippar 80d
nmap <Leader>l !ippar 80p2dh
vmap <Leader>j :'<,'>!par 80
vmap <Leader>k :'<,'>!par 80d
vmap <Leader>l :'<,'>!par 80p2dh
nmap <Leader>help :let @+ = 'https://vimhelp.org/' . expand('%:t') . '.html#' . UrlEncode(expand('<cWORD>'))
echo 'Ready to go.'
