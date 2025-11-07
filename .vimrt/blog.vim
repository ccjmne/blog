nmap <Leader>p    o<pre>{{ ^ \| json_encode(pretty=true) }}</pre><ESC>F^cl
vmap <Leader>p "vyo<pre>{{ ^ \| json_encode(pretty=true) }}</pre><ESC>F^v"vp
vmap <Leader>a satabbrhi title=""i
nmap <Leader>j !ippar 80
nmap <Leader>k !ippar 80d
nmap <Leader>l !ippar 80p2dh
vmap <Leader>j :'<,'>!par 80
vmap <Leader>k :'<,'>!par 80d
vmap <Leader>l :'<,'>!par 80p2dh
echo 'Ready to go.'
