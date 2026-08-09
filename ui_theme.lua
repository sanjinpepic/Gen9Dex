-- Shared theme + drawing primitives for every GalarGmaxDex custom screen
-- (battle scene, party/bag/pokedex/etc presenters). Extracted verbatim
-- from custom_battle_scene.lua's Phase B helpers -- same colors, same
-- panel/text/cursor/HP-bar behavior -- so every screen this mod takes
-- over reads as one coherent UI instead of a pile of one-off looks.
-- Pure love.graphics helpers, no battle-specific state (battle.shown
-- glyph-code rendering stays local to custom_battle_scene.lua, since
-- that's a battle-only concept).
local Theme = {}

Theme.COLOR_PANEL = { 0.07, 0.08, 0.13, 0.94 }
Theme.COLOR_PANEL_LIGHT = { 0.95, 0.96, 0.98, 0.97 }
Theme.COLOR_BORDER = { 0.30, 0.85, 0.75, 1 }
Theme.COLOR_TEXT = { 1, 1, 1, 1 }
Theme.COLOR_TEXT_ON_LIGHT = { 0.06, 0.07, 0.10, 1 }
Theme.COLOR_MUTED = { 0.70, 0.75, 0.85, 1 }
Theme.RADIUS = 8

function Theme.setColor(c)
  love.graphics.setColor(c[1], c[2], c[3], c[4] or 1)
end

function Theme.panel(x, y, w, h, light)
  Theme.setColor(light and Theme.COLOR_PANEL_LIGHT or Theme.COLOR_PANEL)
  love.graphics.rectangle("fill", x, y, w, h, Theme.RADIUS, Theme.RADIUS)
  Theme.setColor(Theme.COLOR_BORDER)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", x + 1, y + 1, w - 2, h - 2, Theme.RADIUS, Theme.RADIUS)
end

local fontCache = {}
function Theme.fontOf(size)
  local f = fontCache[size]
  if not f then
    local ok, made = pcall(love.graphics.newFont, size)
    f = ok and made or love.graphics.getFont()
    fontCache[size] = f
  end
  return f
end

function Theme.printText(text, x, y, size, color)
  local prevFont = love.graphics.getFont()
  love.graphics.setFont(Theme.fontOf(size or 20))
  Theme.setColor(color or Theme.COLOR_TEXT)
  love.graphics.print(text or "", x, y)
  love.graphics.setFont(prevFont)
end

function Theme.fitName(text, pixels, size)
  text = text or ""
  local f = Theme.fontOf(size or 20)
  if f:getWidth(text) <= pixels then return text end
  local s = text
  while #s > 1 and f:getWidth(s .. ".") > pixels do
    s = s:sub(1, #s - 1)
  end
  return s .. "."
end

function Theme.drawCursor(x, y, color)
  Theme.setColor(color or Theme.COLOR_BORDER)
  love.graphics.polygon("fill", x, y, x, y + 18, x + 15, y + 9)
end

function Theme.drawHPBar(x, y, w, h, hp, maxHp)
  Theme.setColor({ 0.12, 0.13, 0.18, 1 })
  love.graphics.rectangle("fill", x, y, w, h, 4, 4)
  local frac = (maxHp and maxHp > 0) and math.max(0, math.min(1, hp / maxHp)) or 0
  local fillColor = frac > 0.5 and { 0.30, 0.82, 0.40, 1 }
    or (frac > 0.2 and { 0.95, 0.80, 0.20, 1 } or { 0.92, 0.25, 0.25, 1 })
  Theme.setColor(fillColor)
  love.graphics.rectangle("fill", x + 3, y + 3, math.max(0, (w - 6) * frac), h - 6, 3, 3)
  Theme.setColor(Theme.COLOR_BORDER)
  love.graphics.setLineWidth(1.5)
  love.graphics.rectangle("line", x + 0.5, y + 0.5, w - 1, h - 1, 4, 4)
end

return Theme
