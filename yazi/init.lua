---@diagnostic disable: undefined-global

-- Draw a full bar around window
function Manager:render(area)
	self.area = area

	local chunks = ui.Layout()
		:direction(ui.Layout.HORIZONTAL)
		:constraints({
			ui.Constraint.Ratio(MANAGER.ratio.parent, MANAGER.ratio.all),
			ui.Constraint.Ratio(MANAGER.ratio.current, MANAGER.ratio.all),
			ui.Constraint.Ratio(MANAGER.ratio.preview, MANAGER.ratio.all),
		})
		:split(area)

  local bar = function(c, x, y)
  	x, y = math.max(0, x), math.max(0, y)
  	return ui.Bar(ui.Rect { x = x, y = y, w = ya.clamp(0, area.w - x, 1), h = math.min(1, area.h) }, ui.Bar.TOP)
  		:symbol(c)
  end

	return ya.flat {

-- Show symlink path in status bar
function Status:name()
	local h = cx.active.current.hovered
	if not h then
		return ui.Span("")
	end

 	local linked = ""
 	if h.link_to ~= nil then
 		linked = " -> " .. tostring(h.link_to)
 	end
 	return ui.Span(" " .. h.name .. linked)
end

-- Remove file size from status bar
function Status:render(area)
	self.area = area

	local left = ui.Line { self:mode(), self:name() }
	local right = ui.Line { self:permissions(), self:position() }
	return {
		ui.Paragraph(area, { left }),
		ui.Paragraph(area, { right }):align(ui.Paragraph.RIGHT),
		table.unpack(Progress:render(area, right:width())),
	}
end
