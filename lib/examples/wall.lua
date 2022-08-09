-- wall.lua

--include line
--include anti_dir

function wall(length, height, mat, dir, upDir)
  if type(dir) ~= "function" then dir = forward end
  if type(upDir) ~= "function" then upDir = up end
  for i = 1, length do
    save('wb')
    line(upDir, height, mat)
    go('wb')
    dir(1)
  end
  local reverseDir = antiDir(dir)
  reverseDir(1)
end


-- wall(3, 4, blocks.stone)