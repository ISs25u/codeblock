codeblock.examples = {}

-------------------------------------------------------------------------------
-- local
-------------------------------------------------------------------------------

local get_dir_list = minetest.get_dir_list
local path_join = codeblock.utils.path_join
local examples_path = path_join(codeblock.modpath, 'lib', 'examples')

-------------------------------------------------------------------------------
-- private
-------------------------------------------------------------------------------

local function read_examples_at_init()

    local examples = {}
    local files = get_dir_list(examples_path, false)
    table.sort(files)

    for i, filename in ipairs(files) do

        local file = io.open(path_join(examples_path, filename), 'rb')
        local content = file:read('*a')
        examples[string.gsub(filename, "%.lua", "")] = content

    end

    return examples

end

-------------------------------------------------------------------------------
-- export
-------------------------------------------------------------------------------

codeblock.examples.examples = read_examples_at_init()
