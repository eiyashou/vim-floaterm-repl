let s:scriptdir = expand('<sfile>:p:h')

function! floaterm_repl#run() range
    let l:filetype= &filetype
    let l:filerunner=s:scriptdir.'/terminal_preview.sh'
    let l:args=''
    let l:filepath=''
    if !empty(g:floaterm_repl_runner)
      let l:filerunner=g:floaterm_repl_runner
    endif

    if l:filetype == 'markdown' || l:filetype == 'vimwiki'
        let startLine=search('```.','bn')
        let endLine =search('```$','n')
        if startLine!=0 && endLine !=0 && endLine>startLine
            let lines = getline(startLine+1, endLine-1)
            if len(lines) == 0
                return ''
            endif
            let query=join(lines,"\n")
            let mdHeader=trim(substitute(getline(startLine),'```','','g'))
            let l:splitHeadder=split(mdHeader,' ')
            if len(l:splitHeadder) >0
                let l:filetype=l:splitHeadder[0]
            end

            if l:filetype != "sql"
                let l:args=join(l:splitHeadder[1:-1])
                let l:filepath='/tmp/vim_floaterm.'.l:filetype
                let w= system("echo " .shellescape(query)." > " .l:filepath )
            endif

        endif
    else
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
        let lines = getline(line_start, line_end)
        if len(lines) == 0
            echo "You need select code."
            return ''
        endif
        let l:filepath='/tmp/vim_floaterm.'.l:filetype
        silent execute "\'<,\'>w! " . l:filepath
    endif

    if len(l:filetype)>0
        if l:filetype == "sql" || (len(l:splitHeadder) > 1 && l:splitHeadder[1] == "repl")
            let l:command=":".(startLine+1).",".(endLine-1)."FloatermSend"
        elseif !empty(l:filepath)
            let l:command=':FloatermNew --name=repl --autoclose=0 --width=70 --height=30 --position=bottomright'
            let l:command= l:command. printf(" %s %s %s %s",l:filerunner,l:filetype,l:filepath,l:args)
        else
            let l:command = ""
        endif
        silent execute l:command
        stopinsert
    endif
endfunction
