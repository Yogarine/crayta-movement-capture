------------------------------------------------------------------------------------------------------------------------
-- @module    Yogarine.PlayerMovement
-- @author    Alwin "Yogarine" Garside <alwin@garsi.de>
-- @copyright 2020 Alwin Garside
-- @license   https://opensource.org/licenses/BSD-2-Clause 2-Clause BSD License
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- Adding this script to your Player allows you to capture them in an invisible capture box.
--
-- To use the Movement Capture, add this script, or attach the Player Movement Capture Template, to your Player
-- template. Then place the Movement Capture Template somewhere in your world tree, and then update the movementCapture
-- property to reference your Movement Capture Entity.
--
-- You can then capture a Player by calling Capture() on its movementCapturePlayerScript.
--
-- @type MovementCapturePlayerScript
-- @see MovementCaptureScript
------------------------------------------------------------------------------------------------------------------------

---
-- @field properties Properties: Holds the values that have been set on an instance of a script.
---
local MovementCapturePlayerScript = {}

---
-- Script properties are defined here.
---
MovementCapturePlayerScript.Properties = {
	{ name = "movementCapture",    type = "entity", tooltip = "Reference to the Movement Capture for this Player.", },
	{ name = "movementCaptureBox", type = "entity", editable = false, },
}

---
-- Captures the Player in a Movement Capture Box.
---
function MovementCapturePlayerScript:Capture()
	self.properties.movementCapture.movementCaptureScript:CapturePlayer(self:GetEntity())
end

---
-- Releases the Player from its Movement Capture Box.
---
function MovementCapturePlayerScript:Release()
	self.properties.movementCaptureBox.movementCaptureBoxScript:Release()
end

return MovementCapturePlayerScript
