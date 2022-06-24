codeblock.examples = {}

-------------------------------------------------------------------------------
-- local
-------------------------------------------------------------------------------

local get_dir_list = minetest.get_dir_list
local path_join = codeblock.utils.path_join
local examples_path = path_join(codeblock.modpath, 'examples')

-------------------------------------------------------------------------------
-- private
-------------------------------------------------------------------------------

local examples = {}

local function load_examples()

    local files = get_dir_list(examples_path, false)
    table.sort(files)

    for i, filename in ipairs(files) do

        local file = io.open(path_join(examples_path, filename), 'rb')
        local content = file:read('*a')
        examples[string.gsub(filename, "%.lua", "")] = content

    end

end

-------------------------------------------------------------------------------
-- export
-------------------------------------------------------------------------------

codeblock.examples.load_examples = load_examples
codeblock.examples.examples = examples
