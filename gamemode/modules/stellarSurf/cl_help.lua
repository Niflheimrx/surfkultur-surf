--[[
  Author: Niflheimrx
  Description: Help page for new players, and the rules page for existing players.
  We also test for css textures here... because I am lazy!
--]]

Help = {}
Help.Size = { [0] = { 500, 500 }, [1] = { 800, 580 } }

local helpDescription = {
  [0] = "Welcome to our SurfTimer server!",
  [2] = "In this gamemode you will be riding ramps to reach the end of the map.",
  [3] = "It is your objective to reach the end as fast as possible and compete for the",
  [4] = "best time possible.",
  [6] = "If you are new to surf, it is recommended to watch the tutorial!",
  [7] = "To watch the tutorial, click the button below that says 'Watch Tutorial'",
  [8] = "To view settings, commands, and more information, press F1 or do !surftimer",
  [9] = "Be sure to read the rules using !rules",
  [11] = "Enjoy and have fun!"
}

local rulesDescription = {
  [1] = {
    [0] = "==[ These are the rules for the SurfTimer ]==",
    [2] = "• Prehopping is not allowed under any circumstances",
    [3] = "• Crouch boosting is allowed as long as it is not considered 'RNG'",
    [4] = "• Using exploits within the SurfTimer gamemode is not allowed and can result",
    [5] = "in getting your SurfTimer profile reset",
    [6] = "• Bypassing autohop is not allowed",
    [7] = "• Using map exploits can vary per map, it's best to ask an admin first"
  },
  [2] = {
    [0] = "==[ These are the rules for the Server ]==",
    [2] = "• Disrespecting Admins will result in a mute or a temporary ban",
    [3] = "• Admin decisions are final, arguments will lead to a mute",
    [4] = "• Spam is ok as long as it's not obnoxious, anything above will result in a mute",
    [5] = "• Begging for an elevated status can result in a mute, consider using !donate",
    [6] = "• Alternate accounts are allowed as long as the main account is not banned"
  }
}

local panel = nil
function Help:Open()
  if !Interface.Started then timer.Simple( 0.15, function() Help:Open() end ) return end

  if panel and IsValid( panel ) then panel:Remove() end
  panel = nil

  RunConsoleCommand( "sl_help", "0" )

  local size = Help.Size[Interface.Scale]
  local bezel = Interface:GetBezel( "Medium" )
  local fontHeight = Interface.FontHeight[Interface.Scale]

  local posx, posy
  local boxSize = SMPanels.BoxButton[Interface.Scale]

  panel = SMPanels.HoverFrame( { title = "Skill Surf", subTitle = "Created by: Gravious, Edited by: Niflheimrx", center = true, w = size[1], h = size[2] } )

  local writeable = panel.Page
  for line, text in pairs( helpDescription ) do
    SMPanels.Label( { parent = writeable, x = bezel, y = bezel + (fontHeight * line), text = text } )
  end

  posx = ( writeable:GetWide() / 2 ) - ( boxSize[1] / 2 )
  posy = ( writeable:GetTall() - boxSize[2] - bezel )

  local function openTutorial()
    gui.OpenURL( "https://www.youtube.com/watch?v=E3tys016mwg" )
  end

  SMPanels.Button( { parent = writeable, text = "Watch Tutorial", func = openTutorial, x = posx, y = posy } )
end

function Help:OpenRules()
  if panel and IsValid( panel ) then panel:Remove() end
  panel = nil

  local size = Help.Size[Interface.Scale]
  local bezel = Interface:GetBezel( "Medium" )
  local fontHeight = Interface.FontHeight[Interface.Scale]

  panel = SMPanels.MultiHoverFrame( { title = "Rules Board", subTitle = "Be sure to follow these rules!", center = true, w = size[1], h = size[2], pages = { "Timer", "Server" } } )

  for group, data in pairs( rulesDescription ) do
    local writeable = panel.Pages[group]

    for line, text in pairs( data ) do
      SMPanels.Label( { parent = writeable, x = bezel, y = bezel + (fontHeight * line), text = text } )
    end
  end
end

local CSSTestText = {
  [1] = "It appears that you do not have the Counter-Strike: Source textures!",
  [2] = "As a result, many maps will be unplayable due to this error.",
  [3] = "We highly recommend picking up these textures from the Steam Store",
  [4] = "or from another trustworthy source!"
}

local function CSSTester()
  if !Interface.Started then timer.Simple( 0.15, function() CSSTester() end ) return end

  local mat = Material( "cs_italy/cobble02.vtf" )
  if mat:IsError() then
    SMPanels.ContentFrame( { title = "Texture Error", center = true, content = CSSTestText } )
    Surf:Notify( "Error", "Failed to locate a valid Counter-Strike: Source material!" )
  end
end
hook.Add( "Initialize", "surf_CSSTest", CSSTester )
