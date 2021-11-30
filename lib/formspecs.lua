codeblock.formspecs = {}

--------------------------------------------------------------------------------
-- local
--------------------------------------------------------------------------------

local S = codeblock.S

local tcik = codeblock.utils.table_convert_ik

local formspec_escape = minetest.formspec_escape
local chat_send_all = minetest.chat_send_all
local chat_send_player = minetest.chat_send_player
local destroy_form = minetest.destroy_form
local update_form = minetest.update_form
local explode_textlist_event = minetest.explode_textlist_event
local get_player_by_name = minetest.get_player_by_name
local scroll_max = codeblock.utils.scroll_max
local blocks = codeblock.utils.blocks
local cubes = codeblock.utils.cubes_names
local plants = codeblock.utils.plants_names
local wools = codeblock.utils.wools_names
local cubes_ik = tcik(cubes)
local plants_ik = tcik(plants)
local wools_ik = tcik(wools)

local get_user_data = codeblock.filesystem.get_user_data
local read_file = codeblock.filesystem.read_file
local write_file = codeblock.filesystem.write_file
local remove_file = codeblock.filesystem.remove_file
local get_itf = codeblock.filesystem.get_itf
local get_fti = codeblock.filesystem.get_fti

local set_file = codeblock.DroneEntity.set_file

--------------------------------------------------------------------------------
-- private
--------------------------------------------------------------------------------

-- file_editor

local file_editor = {

    get_form = function(meta)

        local ud = get_user_data(meta.name)
        local fs = "size[20,10.5]"

        -- styles 
        fs = fs .. 'style[remove;bgcolor=red]'
        fs = fs .. 'style[content;font=mono;font_size=-2;textcolor=#115555]'
        fs = fs .. 'style[create;bgcolor=green]'
        fs = fs .. 'style[help_cubes;bgcolor=blue]'
        fs = fs .. 'style[help_plants;bgcolor=blue]'
        fs = fs .. 'style[help_wools;bgcolor=blue]'
        fs = fs .. 'style[help_cmds;bgcolor=blue]'

        -- tabs
        if #meta.tabs > 0 then
            fs = fs .. 'tabheader[0,0;tabs;'
            for i, filename in ipairs(meta.tabs) do
                if i ~= 1 then fs = fs .. ',' end
                fs = fs .. formspec_escape(filename)
            end
            fs = fs .. ';' .. (meta.active or 0) .. ';false;false]'
        end

        -- files
        fs = fs .. 'textlist[0, 0; 3, 8.75;files;'
        for i, filename in ipairs(ud.itf) do
            if i ~= 1 then fs = fs .. ',' end
            fs = fs .. formspec_escape(filename)
        end
        fs = fs .. ';' .. (ud.fti[meta.tabs[meta.active]] or 0) .. ']'

        -- new file
        fs = fs .. 'field_close_on_enter[newfile;false]'
        fs = fs .. 'field[0.27, 9.5;2.5, 1;newfile;' .. S('new file') .. ';' ..
                 formspec_escape(meta.newfile) .. ']'
        fs = fs .. 'button[2.25, 9.20;1, 1;create;+]'

        -- buttons
        if meta.active ~= 0 then
            fs = fs .. 'button[3.25 ,0 ;2 ,0.75;save;' .. S('save') .. ']'
            fs = fs .. 'button[5.25 ,0 ;3 ,0.75;load;' .. S('load and close') ..
                     ']'
            fs = fs .. 'button[8.25 ,0 ;3, 0.75;remove;' .. S('remove file') ..
                     ']'
            fs = fs .. 'button[11.25,0;2.83, 0.75;close;' .. S('close tab') ..
                     ']'

            fs = fs .. 'button[14,0;1.5, 0.75;help_cubes;' .. S('help cubes') ..
                     ']'
            fs = fs .. 'button[15.5,0;1.5, 0.75;help_plants;' ..
                     S('help plants') .. ']'
            fs = fs .. 'button[17,0;1.5, 0.75;help_wools;' .. S('help wools') ..
                     ']'
            fs = fs .. 'button[18.5,0;1.5, 0.75;help_cmds;' ..
                     S('help commands') .. ']'
        end

        -- checkboxes
        -- fs = fs .. 'checkbox[0,10;soe;Save on exit;' ..
        --          (meta.soe == 0 and 'false' or 'true') .. ']'
        fs = fs .. 'checkbox[0,10;loe;' .. S('load and exit') .. ';' ..
                 (meta.loe == 0 and 'false' or 'true') .. ']'
        fs = fs .. 'checkbox[5,10;sos;' .. S('Save on switch') .. ';' ..
                 (meta.sos == 0 and 'false' or 'true') .. ']'

        -- textarea
        local text = meta.contents[meta.active]
        if meta.active ~= 0 and text then
            local etext = formspec_escape(text)
            fs = fs .. 'textarea[3.5,0.75;10.85,11;content;;' .. etext .. ']'
        elseif meta.active == 0 then
            fs = fs .. 'label[4.5,3;' .. S('click to select a file') .. ']'
        else
            fs = fs .. 'label[4.5,3;' .. S('cannot read file') .. ']'
        end

        -- help
        if meta.help == 'cubes' then

            fs = fs .. 'scrollbaroptions[min=0;max=' .. scroll_max(cubes_ik) ..
                     ';smallstep=1;largestep=5]'
            fs = fs .. 'scrollbar[19.5, 1;0.3, 9.25;vertical;c_scroll;' ..
                     meta.scroll_c .. ']'
            fs = fs ..
                     'scroll_container[17.75, 1.25;7.25, 10.75;c_scroll;vertical;' ..
                     0.5 .. ']'
            local yi, yl
            for i, v in pairs(cubes_ik) do
                yi = tostring(i - 1 - 0.25)
                yl = tostring(i - 1)
                fs =
                    fs .. 'item_image[' .. '0,' .. yi .. ';1,1;' .. blocks[v] ..
                        ']'
                fs = fs .. 'label[1,' .. yl .. ';blocks.' .. v .. ']'
            end
            fs = fs .. 'scroll_container_end[]'

        elseif meta.help == 'plants' then

            fs = fs .. 'scrollbaroptions[min=0;max=' .. scroll_max(plants_ik) ..
                     ';smallstep=1;largestep=5]'
            fs = fs .. 'scrollbar[19.5, 1;0.3, 9.25;vertical;p_scroll;' ..
                     meta.scroll_p .. ']'
            fs = fs ..
                     'scroll_container[17.75, 1.25;7.25, 10.75;p_scroll;vertical;' ..
                     0.5 .. ']'
            local yi, yl
            for i, v in pairs(plants_ik) do
                yi = tostring(i - 1 - 0.25)
                yl = tostring(i - 1)
                fs =
                    fs .. 'item_image[' .. '0,' .. yi .. ';1,1;' .. blocks[v] ..
                        ']'
                fs = fs .. 'label[1,' .. yl .. ';plants.' .. v .. ']'
            end
            fs = fs .. 'scroll_container_end[]'

        elseif meta.help == 'wools' then

            fs = fs .. 'scrollbaroptions[min=0;max=' .. scroll_max(wools_ik) ..
                     ';smallstep=1;largestep=5]'
            fs = fs .. 'scrollbar[19.5, 1;0.3, 9.25;vertical;w_scroll;' ..
                     meta.scroll_w .. ']'
            fs = fs ..
                     'scroll_container[17.75, 1.25;7.25, 10.75;w_scroll;vertical;' ..
                     0.5 .. ']'
            local yi, yl
            for i, v in pairs(wools_ik) do
                yi = tostring(i - 1 - 0.25)
                yl = tostring(i - 1)
                fs = fs .. 'item_image[' .. '0,' .. yi .. ';1,1;' ..
                         blocks[wools[v]] .. ']'
                fs = fs .. 'label[1,' .. yl .. ';wools.' .. v .. ']'
            end
            fs = fs .. 'scroll_container_end[]'

        elseif meta.help == 'commands' then

            fs = fs .. 'hypertext[14.5,1;5.75,10.75;commands_html;' ..
                     codeblock.utils.html_commands .. ']'

        end

        return fs
    end,

    on_close = function(meta, player, fields)

        local name = player:get_player_name()

        local function update()
            update_form(name, codeblock.formspecs.file_editor.get_form(meta))
        end

        local function exit()
            destroy_form(name, minetest.FORMSPEC_SIGEXIT)
        end

        local function load_active()
            if meta.active ~= 0 then
                set_file(name, meta.tabs[meta.active])
            end
        end

        local function save_active()
            local err = write_file(name, meta.tabs[meta.active],
                                   meta.contents[meta.active])
            if err then chat_send_player(name, err) end
        end

        local function remove_active()
            if meta.active == 0 then return end
            if #meta.tabs == 0 then return end
            local err = remove_file(name, meta.tabs[meta.active])
            if err then
                chat_send_player(name, err)
            else
                table.remove(meta.tabs, meta.active)
                table.remove(meta.contents, meta.active)
                meta.active = 0
                if #meta.tabs > 0 then
                    for i, filename in ipairs(meta.tabs) do
                        meta.active = i
                    end
                end
            end
        end

        local function update_active_content(content)
            meta.contents[meta.active] = content
        end

        local function select_tab(i) meta.active = i end

        local function open(i)
            local filename = get_itf(name, i)
            local content, err = read_file(name, filename)
            if not err then
                table.insert(meta.tabs, filename)
                table.insert(meta.contents, content)
                meta.active = #meta.tabs
            else
                chat_send_player(name, err)
            end
        end

        local function create_file(filename)
            if (not filename) or filename == '' then return nil end
            local parts = codeblock.utils.split(filename, '.')
            if #parts > 0 then
                filename = parts[1]
                filename = string.gsub(filename, '[^%w_-]', '')
                filename = string.sub(filename, 1, 15)
                if #filename == 0 then return end
                filename = filename .. '.lua'
                if not get_user_data(name).ftp[filename] then
                    write_file(name, filename, '-- ' .. filename .. '\n\n' ..
                                   codeblock.examples.example .. '\n')
                    meta.newfile = ''
                    return filename
                end
            end
            return nil
        end

        local function close_active()
            if meta.active == 0 then return end
            if #meta.tabs == 0 then return end
            table.remove(meta.tabs, meta.active)
            table.remove(meta.contents, meta.active)
            meta.active = 0
            if #meta.tabs > 0 then
                for i, filename in ipairs(meta.tabs) do
                    meta.active = i
                end
            end
        end

        local function save_editor_state()
            local stabs = table.concat(meta.tabs, ',')
            local player = get_player_by_name(name)
            if player then
                local pmeta = player:get_meta()
                pmeta:set_string('codeblock:editor_state_tabs', stabs)
                pmeta:set_string('codeblock:editor_state_active',
                                 meta.tabs[meta.active])
                pmeta:set_int('codeblock:save_on_exit', meta.soe)
                pmeta:set_int('codeblock:load_on_exit', meta.loe)
                pmeta:set_int('codeblock:save_on_switch', meta.sos)
            end
        end

        -- FIELDS INPUTS
        if fields.close then
            close_active()
            update()
        elseif fields.tabs then
            if meta.sos then
                update_active_content(fields.content) -- old active
                save_active()
            end
            select_tab(tonumber(fields.tabs))
            update()
        elseif fields.load then
            update_active_content(fields.content)
            save_active()
            load_active()
            exit()
        elseif fields.save then
            update_active_content(fields.content)
            save_active()
            update()
        elseif fields.create then
            local filename = create_file(fields.newfile)
            if filename then
                open(get_fti(name, filename))
                update()
            end
        elseif fields.remove then
            remove_active()
            update()
        elseif fields.soe then
            meta.soe = (fields.soe == 'true') and 1 or 0
            update()
        elseif fields.loe then
            meta.loe = (fields.loe == 'true') and 1 or 0
            update()
        elseif fields.sos then
            meta.sos = (fields.sos == 'true') and 1 or 0
            update()
        elseif fields.files then
            local e = explode_textlist_event(fields.files)
            local t = e.type
            local i = e.index
            local sfilename = get_itf(name, i)
            if t == 'DCL' then
                for i, filename in ipairs(meta.tabs) do
                    if filename == sfilename then
                        update_active_content(fields.content)
                        select_tab(i)
                        update()
                        return
                    end
                end
                open(i)
                update()
            end
        elseif fields.help_cubes then
            meta.help = 'cubes'
            update()
        elseif fields.help_plants then
            meta.help = 'plants'
            update()
        elseif fields.help_wools then
            meta.help = 'wools'
            update()
        elseif fields.help_cmds then
            meta.help = 'commands'
            update()
        elseif fields.c_scroll then
            meta.scroll_c = minetest.explode_scrollbar_event(fields.c_scroll)
                                .value
        elseif fields.p_scroll then
            meta.scroll_p = minetest.explode_scrollbar_event(fields.p_scroll)
                                .value
        elseif fields.w_scroll then
            meta.scroll_w = minetest.explode_scrollbar_event(fields.w_scroll)
                                .value
        elseif fields.quit == 'true' then -- fields.content cannot be accessed here
            if meta.loe then load_active() end
            save_editor_state()
        elseif fields.newfile then -- last because sent everytime
            local filename = create_file(fields.newfile)
            if filename then
                open(get_fti(name, filename))
                update()
            end
        end

    end

}

-- file_chooser

local file_chooser = {

    get_form = function(meta)
        local files_txt = {}
        for i, filename in ipairs(get_user_data(meta.name).itf) do
            table.insert(files_txt, formspec_escape(filename))
        end
        files_txt = table.concat(files_txt, ',')
        return 'formspec_version[4]' .. 'size[6,6]' .. 'label[0.5,0.5;' ..
                   S('choose a file') .. ']' .. 'textlist[0.5,1;5,3;file;' ..
                   files_txt .. ']' .. 'button[0.5,4.5;2,1;choose;' ..
                   S('choose') .. ']' .. 'button[3.5,4.5;2,1;cancel;' ..
                   S('cancel') .. ']'
    end,

    on_close = function(meta, player, fields)
        local name = player:get_player_name()

        local function cancel()
            destroy_form(name, minetest.FORMSPEC_SIGEXIT)
        end

        local function choose(i)
            set_file(name, get_itf(name, i))
            destroy_form(name, minetest.FORMSPEC_SIGEXIT)
        end

        if fields.choose then
            choose(meta.selectedIndex)
        elseif fields.cancel then
            cancel()
        elseif fields.file then
            local e = explode_textlist_event(fields.file)
            local t = e.type
            local i = e.index
            if t == 'CHG' then
                meta.selectedIndex = i
                update_form(name,
                            codeblock.formspecs.file_chooser.get_form(meta))
            elseif t == 'DCL' then
                choose(i)
            elseif t == 'INV' then
                return
            end

        end

    end

}

--------------------------------------------------------------------------------
-- export
--------------------------------------------------------------------------------

codeblock.formspecs.file_chooser = file_chooser
codeblock.formspecs.file_editor = file_editor

