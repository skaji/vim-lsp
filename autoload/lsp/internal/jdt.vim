function! lsp#internal#jdt#is_uri(uri) abort
    return type(a:uri) == v:t_string && a:uri =~# '^jdt://'
endfunction

function! lsp#internal#jdt#is_loaded(uri) abort
    let l:bufnr = bufnr(a:uri)
    return l:bufnr != -1 && bufloaded(l:bufnr)
endfunction

function! lsp#internal#jdt#to_vim_location(location) abort
    let l:uri = a:location['uri']
    let [l:line, l:col] = lsp#utils#position#lsp_to_vim(
        \ l:uri,
        \ a:location['range']['start'])
    return {
        \ 'filename': l:uri,
        \ 'lnum': l:line,
        \ 'col': l:col,
        \ 'text': get(getbufline(l:uri, l:line), 0, ''),
        \ }
endfunction

function! lsp#internal#jdt#load_content(uri, content) abort
    let l:bufnr = bufnr(a:uri)
    if l:bufnr == -1
        let l:bufnr = bufadd(a:uri)
    endif

    call setbufvar(l:bufnr, '&buftype', 'nofile')
    call setbufvar(l:bufnr, '&bufhidden', 'hide')
    call setbufvar(l:bufnr, '&swapfile', 0)
    call setbufvar(l:bufnr, '&modifiable', 1)
    call bufload(l:bufnr)

    let l:lines = split(a:content, "\n", 1)
    if empty(l:lines)
        let l:lines = ['']
    endif
    call deletebufline(l:bufnr, 1, '$')
    call setbufline(l:bufnr, 1, l:lines)

    call setbufvar(l:bufnr, '&filetype', 'java')
    call setbufvar(l:bufnr, '&modified', 0)
    call setbufvar(l:bufnr, '&modifiable', 0)
    call setbufvar(l:bufnr, '&readonly', 1)
    return l:bufnr
endfunction
