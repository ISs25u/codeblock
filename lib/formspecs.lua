codeblock.formspecs = {}

--------------------------------------------------------------------------------
-- local
--------------------------------------------------------------------------------

local S = codeblock.S

local formspec_escape = minetest.formspec_escape
local chat_send_all = minetest.chat_send_all
local chat_send_player = minetest.chat_send_player
local destroy_form = minetest.destroy_form
local update_form = minetest.update_form
local explode_textlist_event = minetest.explode_textlist_event

local drone_set_file_from_index = codeblock.DroneEntity.set_file_from_index
local get_file_from_index = codeblock.filesystem.get_file_from_index

--------------------------------------------------------------------------------
-- private
--------------------------------------------------------------------------------

-- file_chooser

local file_chooser = {

    get_form = function(meta)
        local files_txt = {}
        for i = 1, #meta.files do
            files_txt[i] = formspec_escape(meta.files[i])
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

        local function choose(eindex)
            drone_set_file_from_index(name, eindex)
            destroy_form(name, minetest.FORMSPEC_SIGEXIT)
        end

        local function update(meta)
            update_form(name, codeblock.formspecs.file_chooser.get_form(meta))
        end

        if fields.choose then
            choose(meta.selectedIndex)
        elseif fields.cancel then
            cancel()
        elseif fields.file then
            local exp = explode_textlist_event(fields.file)
            local etype = exp.type
            local eindex = exp.index
            if etype == 'CHG' then
                meta.selectedIndex = eindex
                update(meta)
            elseif etype == 'DCL' then
                choose(eindex)
            elseif etype == 'INV' then
                return
            end

        end

    end

}

-- file_editor

local file_editor = {

    get_form = function(meta)

        local fs = "size[12,6.75]"

        if #meta.tabs ~= 0 then
            fs = fs .. 'tabheader[0,0;tabs;'
            for i, id in pairs(meta.tabs) do
                if i ~= 1 then fs = fs .. ',' end
                fs = fs .. formspec_escape(meta.files[id])
            end
            fs = fs .. ';' .. meta.activeN .. ';false;false]'
        end

        fs = fs .. 'textlist[0,0;2.75,6.9;files;'
        for i, filename in pairs(meta.files) do
            if i ~= 1 then fs = fs .. ',' end
            fs = fs .. formspec_escape(filename)
        end
        fs = fs .. ';' .. meta.activeId .. ']'

        if meta.activeId ~= 0 then
            fs = fs .. 'button[3,0;1.25,0.75;save;SAVE]'
            fs = fs .. 'button[4.25,0;1.25,0.75;load;LOAD]'
            fs = fs .. 'button[11,0;1,0.75;close;X]'
        end

        if meta.activeId ~= 0 then
            local text = formspec_escape(meta.tabsContents[meta.activeN])
            fs = fs .. 'textarea[3.25,0.8;9,7.2;content;;' .. text .. ']'
        else
            fs = fs .. 'label[4.5,3;' .. S('click to select a file') .. ']'
        end

        return fs
    end,

    on_close = function(meta, player, fields)

        local name = player:get_player_name()

        local function cancel()
            chat_send_all('cancel')
            destroy_form(name, minetest.FORMSPEC_SIGEXIT)
        end

        local function save_active(content)
            chat_send_all('save_active')
            local dpath = codeblock.datapath .. name
            local file, err = get_file_from_index(dpath, meta.activeId)
            if err then
                chat_send_player(name, S('no files'))
                return
            end
            local fpath = dpath .. '/' .. file
            local suc = codeblock.filesystem.write(fpath, content)
            if not suc then
                chat_send_player(name, S('cannot write file'))
                return
            end
            meta.tabsContents[meta.activeN] = content
            update_form(name, codeblock.formspecs.file_editor.get_form(meta))
        end

        local function select(itab)
            chat_send_all('select')
            meta.activeN = itab
            meta.activeId = meta.tabs[itab]
            update_form(name, codeblock.formspecs.file_editor.get_form(meta))
        end

        local function open(eindex)
            chat_send_all('open')
            local dpath = codeblock.datapath .. name
            local file, err = get_file_from_index(dpath, eindex)
            if err then
                chat_send_player(name, S('no files'))
                return
            end
            local fpath = dpath .. '/' .. file
            local fcontent = codeblock.filesystem.read(fpath)
            if fcontent:byte(1) == 27 then
                return false, S("Error in @1", file) ..
                           S("binary bytecode prohibited")
            end

            table.insert(meta.tabsContents, fcontent) -- load content of opened file
            table.insert(meta.tabs, eindex) -- set active tab
            meta.activeId = eindex -- set opened id
            meta.activeN = #meta.tabs -- set opened id

            update_form(name, codeblock.formspecs.file_editor.get_form(meta))
        end

        local function close_active(eindex)
            chat_send_all('close_active')
            if meta.activeN == 0 or meta.activeId == 0 then return end
            if #meta.tabs == 0 then return end
            table.remove(meta.tabs, meta.activeN) -- remove the tab
            table.remove(meta.tabsContents, meta.activeN) -- remove content of closed file -- TODO save instead?
            if #meta.tabs > 0 then
                for i, id in pairs(meta.tabs) do -- find new activeId
                    meta.activeId = id
                    meta.activeN = i
                end
            else
                meta.activeId = 0
                meta.activeN = 0
            end
            update_form(name, codeblock.formspecs.file_editor.get_form(meta))
        end

        -- FIELDS INPUTS

        if fields.close then
            local eindex = meta.activeId
            close_active()
        elseif fields.tabs then
            local i = tonumber(fields.tabs)
            select(i)
        elseif fields.files then
            local exp = explode_textlist_event(fields.files)
            local etype = exp.type
            local eindex = exp.index
            if etype == 'DCL' then
                for i, id in pairs(meta.tabs) do
                    if eindex == id then
                        select(i)
                        return
                    end -- already open
                end
                open(eindex)
            end
        elseif fields.save then
            save_active(fields.content)
        end

    end

}

--------------------------------------------------------------------------------
-- export
--------------------------------------------------------------------------------

codeblock.formspecs.file_chooser = file_chooser
codeblock.formspecs.file_editor = file_editor

