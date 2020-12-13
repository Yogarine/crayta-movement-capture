------------------------------------------------------------------------------------------------------------------------
-- @module    Yogarine.PlayerMovement
-- @author    Alwin "Yogarine" Garside <alwin@garsi.de>
-- @copyright 2020 Alwin Garside
-- @license   https://opensource.org/licenses/BSD-2-Clause 2-Clause BSD License
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- The Movement Capture Box template is used by Movement Capture to capture a Player in a hidden box to keep it out of
-- view while capturing its movement for other purposes.
--
-- @type MovementCaptureBoxScript
-- @see MovementCaptureScript
------------------------------------------------------------------------------------------------------------------------

---
-- @field properties Properties: Holds the values that have been set on an instance of a script.
---
local MovementCaptureBoxScript = {}

---
-- Script properties are defined here
---
MovementCaptureBoxScript.Properties = {
	{
		name    = "player",
		type    = "entity",
		is      = "Character",
		tooltip = "This Player will be captured in this invisible capture box.",
		default = nil,
	},
	{
		name    = "resetLocator",
		type    = "entity",
		is      = "Locator",
		tooltip = "Locator that the Player will be reset to when he wanders off too far.",
		editableInBasicMode = false,
	},
}

---
-- Called on the server when this entity is created.
---
function MovementCaptureBoxScript:Init()
	---
	-- !Vector: The Player's original position before being captured.
	---
	self.originalPlayerPosition = nil
end

---
-- Called each frame on the server.
--
-- @tparam  number  deltaTimeSeconds  Time elapsed since the last frame was rendered.
---
function MovementCaptureBoxScript:OnTick()
	if self.properties.player then
		local player               = self.properties.player
		local resetLocatorPosition = self.properties.resetLocator:GetPosition()
		local distance             = Vector.Distance(resetLocatorPosition, player:GetPosition())

		-- Reset the player to resetLocatorPosition if it wanders off too far.
		if distance > 500 then
			Printf("Resetting position of Player {1}", player:GetName())
			player:SetPosition(resetLocatorPosition)
			player:SendToLocal("UpdateLastPosition")
		end
	end
end

---
-- Capture the given player in the Movement Capture Box.
--
-- @tparam  Character  player
-- @treturn boolean True if the player was captured, false if the box is already taken.
---
function MovementCaptureBoxScript:CapturePlayer(player)
	if self.properties.player then
		if player == self.properties.player then
			return true
		end

		Printf(
			"Trying to capture Player {1} of user {2} in Capture Box that already belongs to Player {3} of User {4}",
			player:GetName(),
			player:GetUser():GetName(),
			self.properties.player:GetName(),
			self.properties.player:GetUser():GetName()
		)
		return false
	end

	self.originalPlayerPosition = player:GetPosition()
	self.properties.player = player
	player.visible = false
	player.movementCapturePlayerScript.properties.movementCaptureBox = self:GetEntity()

	return true
end

---
-- Release the Player from this box,
--
-- @treturn Character The player that used to be captured.
---
function MovementCaptureBoxScript:ReleasePlayer()
	self.properties.player = nil
	player.visible = true
	player:SetPosition(self.originalPlayerPosition)
	self.originalPlayerPosition = nil

	return player
end

return MovementCaptureBoxScript
