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
local get_player_by_name = minetest.get_player_by_name

local drone_set_file_from_index = codeblock.DroneEntity.set_file_from_index
local drone_read_file_from_index = codeblock.DroneEntity.read_file_from_index
local drone_write_file_from_index = codeblock.DroneEntity.write_file_from_index

--------------------------------------------------------------------------------
-- private
--------------------------------------------------------------------------------

-- file_editor

local file_editor = {

    get_form = function(meta)

        local fs = "size[16,10]"

        -- tabs
        if #meta.tabs ~= 0 then
            fs = fs .. 'tabheader[0,0;tabs;'
            for i, id in pairs(meta.tabs) do
                if i ~= 1 then fs = fs .. ',' end
                fs = fs .. formspec_escape(meta.files[id])
            end
            fs = fs .. ';' .. meta.activeN .. ';false;false]'
        end

        -- files
        fs = fs .. 'textlist[0, 0; 3, 10;files;'
        for i, filename in pairs(meta.files) do
            if i ~= 1 then fs = fs .. ',' end
            fs = fs .. formspec_escape(filename)
        end
        fs = fs .. ';' .. meta.activeId .. ']'

        -- buttons
        if meta.activeId ~= 0 then
            fs = fs .. 'button[3.25 ,0 ;2 ,0.75;save;' .. S('save') .. ']'
            fs = fs .. 'button[5.25 ,0 ;3 ,0.75;load;' .. S('load and close') ..
                     ']'
            fs = fs .. 'button[15,0;1,0.75;close;X]'
        end

        -- textarea
        if meta.activeId ~= 0 then
            local text = formspec_escape(meta.tabsContents[meta.activeN])
            fs = fs .. 'textarea[3.5,0.75;12.75,11;content;;' .. text .. ']'
        else
            fs = fs .. 'label[4.5,3;' .. S('click to select a file') .. ']'
        end

        return fs
    end,

    on_close = function(meta, player, fields)

        local name = player:get_player_name()

        local function update()
            update_form(name, codeblock.formspecs.file_editor.get_form(meta))
        end

        local function close()
            destroy_form(name, minetest.FORMSPEC_SIGEXIT)
        end

        local function load_active()
            drone_set_file_from_index(name, meta.activeId)
        end

        local function save_active()
            local err = drone_write_file_from_index(name, meta.activeId,
                                                    meta.tabsContents[meta.activeN])
            if err then chat_send_player(name, err) end
        end

        local function update_active_content(content)
            table.remove(meta.tabsContents, meta.activeN)
            table.insert(meta.tabsContents, meta.activeN, content)
        end

        local function select_tab(itab)
            meta.activeN = itab
            meta.activeId = meta.tabs[itab]
        end

        local function open(eindex)
            local content, err = drone_read_file_from_index(name, eindex)
            if not err then
                table.insert(meta.tabsContents, content) -- load content of opened file
                table.insert(meta.tabs, eindex) -- set active tab
                meta.activeId = eindex -- set opened id
                meta.activeN = #meta.tabs -- set opened id
            else
                chat_send_player(name, err)
            end
        end

        local function close_active(eindex)
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
        end

        local function save_editor_state()
            local es = table.concat(meta.tabs, ',')
            local player = get_player_by_name(name)
            if player then
                player:get_meta():set_string('codeblock:editor_state_tabs', es)
                player:get_meta():set_int('codeblock:editor_state_active',
                                          meta.activeId)
            end
        end

        -- FIELDS INPUTS
        if fields.close then -- close active
            close_active()
            update()
        elseif fields.tabs then
            update_active_content(fields.content)
            select_tab(tonumber(fields.tabs))
            update()
        elseif fields.load then
            update_active_content(fields.content)
            save_active()
            load_active()
            close()
        elseif fields.files then
            local exp = explode_textlist_event(fields.files)
            local etype = exp.type
            local eindex = exp.index
            if etype == 'DCL' then
                for i, id in pairs(meta.tabs) do
                    if eindex == id then
                        update_active_content(fields.content)
                        select_tab(i)
                        update()
                        return
                    end -- already open
                end
                open(eindex)
                update()
            end
        elseif fields.save then
            update_active_content(fields.content)
            save_active()
            update()
        elseif fields.quit then -- fields.content is not present here...
            save_editor_state()
        end

    end

}

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

--------------------------------------------------------------------------------
-- export
--------------------------------------------------------------------------------

codeblock.formspecs.file_chooser = file_chooser
codeblock.formspecs.file_editor = file_editor

