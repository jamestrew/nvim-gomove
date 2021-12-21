local lh = {}

function lh.move(vim_start, vim_end, distance)
  if vim.o.modifiable == 0 or distance == 0 then
    return false
  end

  local going_right = (distance > 0)

  local line_start = vim.fn.line(vim_start)
  local line_end = vim.fn.line(vim_end)

  local action
  if going_right then
    action = string.rep('>', distance)
  else
    action = string.rep('<', -distance)
  end

  local undo = require('gomove.undo')
  undo.Handle(
    (going_right and "right" or "left")
  )
  vim.cmd("silent! "..line_start..','..line_end..action)
  undo.Save(
    (going_right and "right" or "left")
  )

  return true
end


function lh.duplicate(vim_start, vim_end, count)
  if vim.o.modifiable == 0 or count == 0 then
    return false
  end

  local utils = require("gomove.utils")

  local line_start = vim.fn.line(vim_start)
  local line_end = vim.fn.line(vim_end)

  local lines_between = utils.range(line_start, line_end)

  local register = 'z'
  local old_reg_value = vim.fn.getreg(register)

  local opts = require'gomove.config'.opts
  --Go through each line and do action to each separately
  for _, line in ipairs(lines_between) do
    local raw_content = vim.fn.getline(line)
    -- Remove whitespace at start of line
    local current_content = (
      opts.ignore_indent_lh_duplicate == true
      and raw_content:gsub('^%s+', '')
      or raw_content
    )
    vim.fn.setreg(register, current_content)

    --Get the current line's content, set a register to it,
    --And paste to the end/indent of each accordingly.
    if count < 0 then
      vim.fn.cursor(line, vim.fn.indent(line)+1)
      vim.cmd('silent! normal! "'..register..math.abs(count).."P")
    else
      vim.fn.cursor(line, #raw_content)
      vim.cmd('silent! normal! "'..register..math.abs(count).."p")
    end
  end

  vim.fn.setreg(register, old_reg_value)

  return true
end

return lh
