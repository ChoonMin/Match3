local text_visualisation = {}
local constants = require 'constants'
local field = {{'    0 1 2 3 4 5 6 7 8 9'}, 
            {"  ----------------------"},
            {"0 |"},
            {"1 |"},
            {"2 |"},
            {"3 |"},
            {"4 |"},
            {"5 |"},
            {"6 |"},
            {"7 |"},
            {"8 |"},
            {"9 |"}}
          
function text_visualisation:dump(matrix)
  for x = constants.LEFT_BORDER, constants.RIGHT_BORDER do 
    for y = constants.UP_BORDER, constants.DOWN_BORDER do
      field[y+3][x+2] = string.char(string.byte("A") + matrix[y][x])
    end
  end
  for x1,y1 in pairs(field) do
    for x2,y2 in pairs(y1) do
      io.write(y2 .. ' ')
    end
    io.write('\n')
  end
  io.write('\n')
end

function text_visualisation:show_hint()
   io.write("To make a turn write m x(0-9) y(0-9) direction(r,l,u,d)\n")
end
function text_visualisation:error_handle(error_code)
  if error_code == constants.errors.invalid_format then
    io.write('Invalid format\n')
  elseif error_code == constants.errors.out_of_range then  
    io.write('Out of range\n')
  elseif error_code == constants.errors.no_matches then
    io.write('There is no matches\n')
  else 
    io.write('Unknown error\n')
  end
end
return text_visualisation