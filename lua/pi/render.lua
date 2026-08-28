--- Convert a session transcript to buffer lines + highlight ranges.
local util = require("pi.util")

local M = {}

--- Returns lines (string[]), hls ({line=0-indexed, hl=group}[])
function M.lines(session, cfg)
  local lines, hls = {}, {}

  local function add(text, hl)
    for _, l in ipairs(vim.split(text or "", "\n", { plain = true })) do
      lines[#lines + 1] = l
      if hl then hls[#hls + 1] = { line = #lines - 1, hl = hl } end
    end
  end

  if not session then
    add("No active pi session.", "PiInfo")
    add("", nil)
    add(":Pi new  — start a chat", "PiInfo")
    return lines, hls
  end

  local prev_kind = nil
  for _, e in ipairs(session.transcript) do
    if e.kind == "user" then
      add("", nil)
      local tag = e.steered and "── You (steer) " or "── You "
      add(tag .. string.rep("─", math.max(0, 40 - #tag)), "PiUserHeader")
      add(e.text, "PiUser")
    elseif e.kind == "assistant" then
      if prev_kind == "user" or prev_kind == nil then
        add("", nil)
        add("── pi " .. string.rep("─", 34), "PiHeader")
      elseif prev_kind ~= "assistant" then
        add("", nil)
      end
      add(e.text)
    elseif e.kind == "thinking" then
      if cfg.render.show_thinking and e.text ~= "" then
        add("", nil)
        add("· thinking", "PiThinking")
        add(e.text, "PiThinking")
      end
    elseif e.kind == "tool" then
      -- compact: one line per tool (grouped when consecutive); output only on
      -- error (tail) or when render.show_tool_output is enabled
      if prev_kind ~= "tool" then add("", nil) end
      local icon = e.done and (e.error and "✗" or "✓") or "▶"
      local hl = e.error and "PiError" or (e.done and "PiTool" or "PiToolRunning")
      local summary = util.args_summary(e.name, e.args)
      add(icon .. " " .. (e.name or "tool") .. (summary ~= "" and ("  " .. summary) or ""), hl)
      local show_output = e.output and e.output ~= ""
        and (e.error or cfg.render.show_tool_output)
      if show_output then
        local out_lines = vim.split(e.output, "\n", { plain = true })
        local max = cfg.render.max_tool_lines
        local start = 1
        if #out_lines > max then
          start = #out_lines - max + 1
          add(("│ … (%d lines hidden)"):format(start - 1), "PiToolOutput")
        end
        for i = start, #out_lines do
          add("│ " .. out_lines[i], "PiToolOutput")
        end
      end
    elseif e.kind == "info" then
      add("· " .. e.text, "PiInfo")
    elseif e.kind == "error" then
      add("✗ " .. e.text, "PiError")
    end
    prev_kind = e.kind
  end

  if session.streaming then
    add("", nil)
    add("… working", "PiInfo")
  end

  if #lines == 0 then
    add("New session. Type a message below and press <CR> to send.", "PiInfo")
  end

  return lines, hls
end

return M
