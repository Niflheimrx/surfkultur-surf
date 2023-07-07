--[[
  Author: Niflheimrx
  Description: Style selector, shows description and what settings it carries
--]]

StyleSelect = {}
StyleSelect.Size = { [0] = { 600, 510 }, [1] = { 700, 610 } }

local styles = {
  [1] = {
    Name = "Normal",
    Desc = "This is the default mode and contains no changes to the movement system",
    Accel = 150,
    Blocked = nil,
    Progress = 1,
  },
  [2] = {
    Name = "Sideways",
    Desc = "This mode functions similarly to Normal however you are forced to surf away from the ramp in a 90 degree angle",
    Accel = 150,
    Blocked = "Left, Right Movements",
    Progress = 0.5,
  },
  [3] = {
    Name = "Half-Sideways",
    Desc = "This mode functions similarly to Normal however you are forced to surf away from the ramp in a 45 degree angle",
    Accel = 150,
    Blocked = "Single-strafe Movements",
    Progress = 0.5,
  },
  [4] = {
    Name = "Bonus",
    Desc = "This is an extra mode that works exactly as Normal that allows you to play extra parts of the map",
    Accel = 150,
    Blocked = nil,
    Progress = 1,
  },
  [6] = {
    Name = "Wicked",
    Desc = "This is a special mode that grants you a really high airacceleration that makes it really easy to gain speed",
    Accel = 50000,
    Blocked = nil,
    Progress = 2,
  },
  [44] = {
    Name = "100 Tick",
    Desc = "This mode mimics surfing as if you were playing on a 100 tick server",
    Accel = 1000,
    Blocked = nil,
    Progress = 2,
  },
  [45] = {
    Name = "33 Tick",
    Desc = "This mode mimics surfing as if you were playing on a 33 tick server",
    Accel = 75,
    Blocked = nil,
    Progress = 2,
  },
}

local panel = nil
function StyleSelect.Open()
  if panel and IsValid( panel ) then panel:Remove() end
  panel = nil

  local size = StyleSelect.Size[Interface.Scale]
  panel = SMPanels.HoverFrame( { title = "Style Menu", subTitle = "Here are a list of styles we offer, click for info", center = true, w = size[1], h = size[2] } )
  local writeable = panel.Page

  local count = 0
  local mdbezel = Interface:GetBezel( "Medium" )
  local buttonSize = SMPanels.GenericSize[Interface.Scale]
  local barSize = SMPanels.BarSize[Interface.Scale]

  for id,info in SortedPairs( styles ) do
    local center = info.Name
    local left = "Airacceleration: " .. info.Accel
    local right = "Limits: " .. ( info.Blocked or "None" )
    local pos = Interface:GetBezel( "Medium" ) + barSize * count

    local function ChangeStyle()
      if id == Timer.Style then
        local panTab = {
          [1] = "This is the " .. info.Name .. " style",
          [2] = "Point Multiplier: " .. info.Progress .. "x",
          [3] = "",
          [4] = "Style Info:",
          [5] = info.Desc,
          [6] = "",
          [7] = "You are currently playing on this style"
        }

        SMPanels.ContentFrame( { parent = panel, title = "Style Info", center = true, content = panTab } )
      else
        local panTab = {
          [1] = "This is the " .. info.Name .. " style",
          [2] = "Point Multiplier: " .. info.Progress .. "x",
          [3] = "",
          [4] = "Style Info:",
          [5] = info.Desc,
          [6] = "",
          [7] = "Would you like to switch to this style?"
        }

        SMPanels.AgreementFrame( { parent = panel, title = "Style Info", center = true, content = panTab, callback = function() RunConsoleCommand( "sm_style", id ) end } )
      end
    end

    SMPanels.LongBarInfo( { parent = writeable, mtext = center, ltext = left, rtext = right, pos = pos, func = ChangeStyle } )
    count = count + 1
  end
end
