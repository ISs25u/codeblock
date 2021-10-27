codeblock.filesystem = {}

-------------------------------------------------------------------------------
-- local
-------------------------------------------------------------------------------

local S = codeblock.S

local get_dir_list = minetest.get_dir_list
local safe_file_write = minetest.safe_file_write
local mkdir = minetest.mkdir
local path_join = codeblock.utils.path_join

local base_path = 'codeblock_users_lua_files'

-------------------------------------------------------------------------------
-- private
-------------------------------------------------------------------------------

local user_data = {}

local function get_file_path(name, filename)
    return path_join(minetest.get_worldpath(), base_path, name, filename) -- TODO change
end

local function get_user_files(name)
    local path = path_join(codeblock.datapath, name)
    local files = get_dir_list(path, false)
    table.sort(files)
    return files
end

local function get_user_data(name, forceRefresh)
    local ud
    if user_data[name] == nil or forceRefresh then
        local itf = get_user_files(name) or {}
        local ftp = {}
        local fti = {}
        for i, f in ipairs(itf) do
            ftp[f] = get_file_path(name, f)
            fti[f] = i
        end
        ud = {itf = itf, ftp = ftp, fti = fti}
        user_data[name] = ud
    else
        ud = user_data[name]
    end
    return ud
end

local function get_ftp(name, f, forceRefresh)
    local ud = get_user_data(name, forceRefresh)
    return ud.ftp[f]
end

local function get_itp(name, i, forceRefresh)
    local ud = get_user_data(name, forceRefresh)
    return ud.ftp[ud.itf[i]]
end

local function get_fti(name, f, forceRefresh)
    local ud = get_user_data(name, forceRefresh)
    return ud.fti[f]
end

local function get_itf(name, i, forceRefresh)
    local ud = get_user_data(name, forceRefresh)
    return ud.itf[i]
end

local function read_file(name, filename)
    local path = get_file_path(name, filename)
    local file, err = io.open(path, 'rb')
    if err then return nil, err end
    local content = file:read('*a')
    file:close()
    if content then
        return content
    else
        return nil, S('cannot read file') .. ' ' .. filename
    end
end

local function write_file(name, filename, content)
    local path = get_file_path(name, filename)
    local success = safe_file_write(path, content)
    if not success then return S('cannot write file') .. ' ' .. filename end
end

local function make_user_dir(name)
    local path = path_join(codeblock.datapath, name)
    local success = mkdir(codeblock.datapath .. name)
    if not success then return S('Cannot create @1', path) end
end

-- old ------------------

local function get_files(dirpath)
    if not dirpath then return false, "Missing argument <path>" end
    if type(dirpath) ~= 'string' then return "<path> must be a string" end
    local dirs = get_dir_list(dirpath, false)
    table.sort(dirs)
    return dirs
end

local function get_file_from_index(dirpath, index)
    if not index then return false, "Missing argument <index>" end
    if type(index) ~= 'number' then return false, "<index> must be a number" end
    local dirs, err = get_files(dirpath)
    if err then return false, err end
    local file = dirs[index]
    if not file then return false, "No file found" end
    return file
end

local function read(filepath)
    local file, err = io.open(filepath, "rb")
    if not file then return false, err end
    local content = file:read("*a")
    file:close()
    return content
end

local function write(filepath, content) return
    safe_file_write(filepath, content) end

-------------------------------------------------------------------------------
-- export
-------------------------------------------------------------------------------

codeblock.filesystem.get_files = get_files
codeblock.filesystem.get_file_from_index = get_file_from_index
codeblock.filesystem.read = read
codeblock.filesystem.write = write

codeblock.filesystem.get_user_data = get_user_data
codeblock.filesystem.read_file = read_file
codeblock.filesystem.write_file = write_file
codeblock.filesystem.get_ftp = get_ftp
codeblock.filesystem.get_itp = get_itp
codeblock.filesystem.get_fti = get_fti
codeblock.filesystem.get_itf = get_itf
codeblock.filesystem.make_user_dir = make_user_dir
