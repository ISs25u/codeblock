-- anti_dir.lua

function antiDir(dir)
  if dir == up then dir = down
  elseif dir == down then dir = up
  elseif dir == left then dir = right
  elseif dir == right then dir = left
  elseif dir == forward then dir = back
  elseif dir == back then dir = forward
  end
  return dir
end


