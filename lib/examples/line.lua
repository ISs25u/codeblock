-- line.lua

local randomBlock = table.randomizer({blocks.ice, blocks.brick})

function line(dir, length, m)
  if m == nil then m = randomBlock() end
  for i = 1, length do
    dir(1)
    place(m)
  end
end