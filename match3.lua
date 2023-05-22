local constants = require 'constants'
local text_visualisation = require 'text_visualisation'
local Game = {}
local matrix = {}

local function fall() -- checks if any cells has to fall and swap empty cells with the cells above them, if any movements were made returns true, else returns false
  local res = false
  for y = constants.DOWN_BORDER, constants.UP_BORDER + 1, -1 do
    for x = constants.LEFT_BORDER, constants.RIGHT_BORDER do
      if (matrix[y][x] == constants.EMPTY_CELL)and(matrix[y-1][x] ~= constants.EMPTY_CELL) then
        matrix[y][x], matrix[y-1][x] = matrix[y-1][x], matrix[y][x]
        res = true
      end
    end
  end
  
  for x = constants.LEFT_BORDER, constants.RIGHT_BORDER do 
    if matrix[constants.UP_BORDER][x] == constants.EMPTY_CELL then
      res = true
    end
  end
  return res
end

local function fill_top() -- fills empty cells on top of the field with random colors
  for x = constants.LEFT_BORDER,constants.RIGHT_BORDER do 
    if matrix[constants.UP_BORDER][x] == constants.EMPTY_CELL then
      matrix[constants.UP_BORDER][x] = math.random(1,constants.COLORS)
    end
  end
end

local function find_triplets() -- find lines >= 3 of the same colors on the field, put these lines in "triplets" and returns "triplets" 
  local triplets = {}
  for column = constants.LEFT_BORDER,constants.RIGHT_BORDER do 
    local lenght = 1
    local match = {}
    for row = constants.UP_BORDER + 1,constants.DOWN_BORDER  do 
      if matrix[row][column] == matrix[row-1][column] then
        lenght = lenght + 1
        table.insert(match,{row,column})
      else
        if lenght >= constants.NECESSERY_MATCH then
          table.insert(triplets,match)
        end
        lenght = 1 
        match ={}
      end
    end
    if lenght >= constants.NECESSERY_MATCH then
      table.insert(triplets,match)
    end
  end
  for row = constants.UP_BORDER,constants.DOWN_BORDER  do 
    local lenght = 1
    local match = {}
    for column = constants.LEFT_BORDER + 1,constants.RIGHT_BORDER  do 
      if matrix[row][column] == matrix[row][column - 1] then
        lenght = lenght + 1
        table.insert(match,{row,column})
      else
        if lenght >= constants.NECESSERY_MATCH then
          table.insert(triplets,match)
        end
        lenght = 1 
        match ={}
      end
    end
    if lenght >= constants.NECESSERY_MATCH then
      table.insert(triplets,match)
    end
  end
  return triplets
end

local function mark_triplets(triplets) -- marks cells from triplets
  for _,line in pairs(triplets) do
    for _,cell in pairs(line) do
      matrix[cell[1]][cell[2]] = constants.MARKED_CELL
    end
  end
end

local function clear_marked_cells(triplets) -- turns marked cells into an empty cells
  local res = false
  for x = constants.LEFT_BORDER, constants.RIGHT_BORDER do
    for y = constants.UP_BORDER, constants.DOWN_BORDER do
      if matrix[y][x] == constants.MARKED_CELL then
        matrix[y][x] = constants.EMPTY_CELL
        res= true
      end
    end
  end
  return res
end

local function swap(from,to)
  matrix[from[1]][from[2]],matrix[to[1]][to[2]] = matrix[to[1]][to[2]],matrix[from[1]][from[2]]
end

local function no_possible_triplets(triplets) -- checks if there is no possible triplets on the field, returns true if it's impossible to make a triplet , else returns false
  local triples = {}
  for column = constants.LEFT_BORDER,constants.RIGHT_BORDER do 
    for row = constants.UP_BORDER,constants.DOWN_BORDER - 1 do 
      swap({row,column},{row + 1,column})
      triples = find_triplets()
      swap({row,column},{row + 1,column})
      if next(triples) ~= nil then
        return false
      end
    end
  end
  for column = constants.LEFT_BORDER,constants.RIGHT_BORDER - 1 do 
    for row = constants.UP_BORDER,constants.DOWN_BORDER do 
      swap({row,column},{row,column + 1})
      triples = find_triplets()
      swap({row,column},{row,column + 1})
      if next(triples) ~= nil then
        return false
      end
    end
  end
  return true
end

local function parse_input(input) --handles user's input and returns from,to
  local y,x,dir = string.match(input,'m (%d+) (%d+) ([l,r,u,d])')
  if (x == nil) or (y == nil) then
    return false
  end
  local from = {tonumber(y),tonumber(x)}
  local to
  if dir == "l" then 
    to = {from[1] , from[2] - 1}
  elseif dir == "r" then 
    to = {from[1] , from[2] + 1}
  elseif dir == "u" then 
    to = {from[1] - 1, from[2]}
  elseif dir == "d" then
    to = {from[1] + 1, from[2]}
  else
    return false
  end
  return true, from, to
end

local function init()
  for y = constants.UP_BORDER, constants.DOWN_BORDER do
    matrix[y] = {}
    for x = constants.LEFT_BORDER, constants.RIGHT_BORDER do
      matrix[y][x] = math.random(0,constants.COLORS - 1)
    end
  end
  local triples = find_triplets()
  if no_possible_triplets() == true or (#triples ~= 0) then
    init()
  end
end

local function tick()
  if fall() then
    fill_top()
    return true
  end
  if clear_marked_cells() then 
    return true
  end
  local triples = find_triplets()
  if #triples ~= 0 then 
    mark_triplets(triples)
    return true
  end
  return false
end

local function try_move(from,to)
  swap(from,to)
  local res = find_triplets()
  if #res == 0 then
    swap(from,to)
    return false
  else
    return true
  end
end

local function mix()
  while (next(triplets) ~= nil) or (no_possible_triplets() == true) do 
    for i = 1, constants.FIELD_SIZE^2 do
      local x1 = math.random(constants.LEFT_BORDER,constants.RIGHT_BORDER)
      local x2 = math.random(constants.LEFT_BORDER,constants.RIGHT_BORDER)
      local y1 = math.random(constants.UP_BORDER,constants.DOWN_BORDER)
      local y2 = math.random(constants.UP_BORDER,constants.DOWN_BORDER)
      matrix[y1][x1], matrix[y2][x2] = matrix[y2][x2], matrix[y1][x1]
    end
  end
end

local function check_borders_from(from) -- checks the start point
  if (from[1] < constants.LEFT_BORDER) or (from[1] > constants.RIGHT_BORDER) or (from[2] < constants.UP_BORDER) or (from[2] > constants.DOWN_BORDER) then
    return false
  else
    return true
  end
end
local function check_borders_to(to) -- checks the end point
  if (to[1] < constants.LEFT_BORDER) or (to[1] > constants.RIGHT_BORDER) or (to[2] < constants.UP_BORDER) or (to[2] > constants.DOWN_BORDER) then
    return false
  else
    return true
  end
end
function Game:Game_start()
  init()
  text_visualisation:dump(matrix)
  while true do
    text_visualisation:show_hint()
    input = io.read()
    if input == constants.EXIT then
      break
    end
    is_correct, from, to = parse_input(input)
    if is_correct then
      if check_borders_from(from) and check_borders_to(to) then
        if try_move(from,to) then
          repeat
            text_visualisation:dump(matrix)
          until tick() == false
          if no_possible_triplets() then
            mix()
          end
        else
          text_visualisation:error_handle(constants.errors.no_matches)
        end
      else
        text_visualisation:error_handle(constants.errors.out_of_range)
      end
    else
      text_visualisation:error_handle(constants.errors.invalid_format)
    end
  end
end
Game:Game_start()
return Game