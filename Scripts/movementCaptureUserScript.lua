------------------------------------------------------------------------------------------------------------------------
-- @module    Yogarine.PlayerMovement
-- @author    Alwin "Yogarine" Garside <alwin@garsi.de>
-- @copyright 2020 Alwin Garside
-- @license   https://opensource.org/licenses/BSD-2-Clause 2-Clause BSD License
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- Adding this script to your User allows you to capture its Player in an invisible capture box.
--
-- To use the Movement Capture, add this script, or attach the User Movement Capture Template, to your User template.
-- Then place the Movement Capture Template somewhere in your world tree, and then update the movementCapture property
-- to reference your Movement Capture Entity.
--
-- You can then capture a Player by calling Capture() on its MovementCaptureUserScript.
--
-- @type MovementCaptureUserScript
-- @see MovementCaptureScript
------------------------------------------------------------------------------------------------------------------------

---
-- @field properties Properties: Holds the values that have been set on an instance of a script.
---
local MovementCaptureUserScript = {}

---
-- Script properties are defined here.
---
MovementCaptureUserScript.Properties = {
	{ name = "movementCapture",    type = "entity", tooltip = "Reference to the Movement Capture for this Player.", },
	{ name = "movementCaptureBox", type = "entity", editable = false, },
}

---
-- Captures the Player in a Movement Capture Box.
---
function MovementCaptureUserScript:CapturePlayer()
	self.properties.movementCapture.movementCaptureScript:CapturePlayer(self:GetEntity():GetPlayer())
end

---
-- Releases the Player from its Movement Capture Box.
---
function MovementCaptureUserScript:ReleasePlayer()
	self:GetEntity():GetPlayer().properties.movementCaptureBox.movementCaptureBoxScript:Release()
end

return MovementCaptureUserScript
