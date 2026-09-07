" Courtesy of https://github.com/vimpostor
" Shared at https://gist.github.com/atripes/15372281209daf5678cded1d410e6c16?permalink_comment_id=5166205#gistcomment-5166205
func UrlEncode(s, ...)
  let safe = a:0 ? a:1 : '[-_.~a-zA-Z0-9]'
  return a:s->map({_, v -> match(v, safe) ? printf("%%%02X", char2nr(v)) : v})
endfunc

nmap <Leader>help :let @+ = 'https://vimhelp.org/' . expand('%:t') . '.html#' . UrlEncode(expand('<cWORD>'))
nmap <Leader>svg  :let @+ = "url('data:image/svg+xml," .. UrlEncode(getline('.'), '[^#%<>]') .. "')"
echo 'Ready to go.'
