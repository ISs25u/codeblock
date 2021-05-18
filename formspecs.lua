codeblock.formspecs = {}
local S = default.get_translator

function codeblock.formspecs.choose_file(files)

    local files_txt = {}
    for i = 1, #files do files_txt[i] = minetest.formspec_escape(files[i]) end
    files_txt = table.concat(files_txt, ',')

    local form = {
        'formspec_version[4]', 'size[6,5]', 'label[0.5,0.5;Choose a file:]',
        'textlist[0.5,1;5,3;file;' .. files_txt .. ']'
    }

    return table.concat(form, '')

end
