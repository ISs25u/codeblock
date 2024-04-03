-- room.lua

--include wall

function room(length, width, height, mat, matFloor)
  for i = 1, 2 do
    wall(width, height, mat)
    turn_right() 
    wall(length, height, mat)
    turn_right()
  end
  back()
  wall(length, width, matFloor, right, forward)
  up(height+1)
  wall(length, width, matFloor, left, forward)
end


room(7,9,5, blocks.brick, blocks.stone)
--cube(10, 100, 10, blocks.air)