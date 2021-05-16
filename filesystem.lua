
codeblock.filesystem = {}

local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function codeblock.filesystem.read(file)
  local file = io.open(file, "rb")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return content
end
