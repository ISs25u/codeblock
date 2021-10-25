codeblock.formspecs = {}

--------------------------------------------------------------------------------
-- local
--------------------------------------------------------------------------------

local S = codeblock.S

local formspec_escape = minetest.formspec_escape
local chat_send_all = minetest.chat_send_all
local destroy_form = minetest.destroy_form
local update_form = minetest.update_form
local explode_textlist_event = minetest.explode_textlist_event

local drone_set_file_from_index = codeblock.DroneEntity.set_file_from_index

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

        fs = fs .. 'tabheader[0,0;tabs;'
        local oidx = 1
        local i = 1
        for id, v in pairs(meta.tabs) do
            if i ~= 1 then fs = fs .. ',' end
            fs = fs .. formspec_escape(meta.files[id])
            if id == meta.openedId then oidx = i end
            i = i + 1
        end
        fs = fs .. ';' .. oidx .. ';false;false]'

        fs = fs .. 'textlist[0,0;2.75,6.9;files;'
        sidx = 0
        for i, filename in ipairs(meta.files) do
            if i ~= 1 then fs = fs .. ',' end
            fs = fs .. formspec_escape(filename)
            if i == meta.openedId then sidx = i end
        end
        fs = fs .. ';' .. sidx .. ']'

        fs = fs .. 'button[3,0;1.25,0.75;save;SAVE]'
        fs = fs .. 'button[4.25,0;1.25,0.75;load;LOAD]'
        fs = fs .. 'button[11,0;1,0.75;close;X]'

        if meta.openedId ~= 0 then
            local text = 'TODO'
            fs = fs .. "textarea[3.25,0.8;9,7.2;content;;" ..
                     minetest.formspec_escape(text) .. "]"
        end

        return fs
    end,

    on_close = function(meta, player, fields)

        local name = player:get_player_name()

        local function cancel()
            destroy_form(name, minetest.FORMSPEC_SIGEXIT)
        end

        local function save()
            
        end

        local function open()
            
        end

        if fields.close then
            meta.tabs[meta.openedId] = nil
            for id, v in pairs(meta.tabs) do meta.openedId = id end
            update_form(name, codeblock.formspecs.file_editor.get_form(meta))
        elseif fields.tabs then
            local eindex = tonumber(fields.tabs)
            meta.openedId = eindex
        elseif fields.files then
            local exp = explode_textlist_event(fields.files)
            local etype = exp.type
            local eindex = exp.index
            if etype == 'DCL' then
                if type(meta.tabs[eindex]) == 'nil' then
                    meta.tabs[eindex] = true
                    meta.openedId = eindex
                    update_form(name,
                                codeblock.formspecs.file_editor.get_form(meta))
                else
                    meta.openedId = eindex
                    update_form(name,
                                codeblock.formspecs.file_editor.get_form(meta))
                end
            end

        end

    end

}

--------------------------------------------------------------------------------
-- export
--------------------------------------------------------------------------------

codeblock.formspecs.file_chooser = file_chooser
codeblock.formspecs.file_editor = file_editor

