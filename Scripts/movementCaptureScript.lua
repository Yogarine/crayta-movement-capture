------------------------------------------------------------------------------------------------------------------------
-- @module    Yogarine.PlayerMovement
-- @author    Alwin "Yogarine" Garside <alwin@garsi.de>
-- @copyright 2020 Alwin Garside
-- @license   https://opensource.org/licenses/BSD-2-Clause 2-Clause BSD License
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- Movement Capture is a Template that allows you to capture players in an invisible box.
--
-- You can use this in combination with the Player Movement template or the movementPlayerScript to capture the Player's
-- input while hiding it away and then using a custom Camera.
--
-- To use the Movement Capture and start capturing your poor Player Characters, place the Movement Capture template
-- somewhere in your World tree, where you know it won't collide with anything, and call the CapturePlayer() function to
-- capture the provided player.
--
-- You can also attach the Player Movement Capture template to your Player template, update its
-- movementCapturePlayerScript reference to your Movement Capture entity, and then then capture a Player by calling
-- Capture() on its movementCapturePlayerScript.
--
-- @type MovementCaptureScript
------------------------------------------------------------------------------------------------------------------------

---
-- @field properties Properties: Holds the values that have been set on an instance of a script.
---
local MovementCaptureScript = {}

---
-- Script properties are defined here
---
MovementCaptureScript.Properties = {
	{ name = "boxTemplate", type = "template", tooltip = "Capture Box template to use" },
}

---
-- Initializes all the fields.
---
function MovementCaptureScript:InitFields()

	---
	-- !{Entity,...}: table that stores references to all the Movement Capture Boxes.
	---
	self.boxes = {}

	---
	-- !Vector: Contains the Movement Capture Box height.
	---
	self.boxHeight = Vector.New(0, 0, 800)

	---
	-- !Vector: Contains an offset from Movement Capture's position to it's bottom first Box position.
	---
	self.boxHeightOffset = Vector.New(0, 0, - (self:GetEntity().size.z / 2))

end

---
-- Called on the server when this entity is created
---
function MovementCaptureScript:Init()
	Printf("MovementCapture: Init")

	self:InitFields()

	local entity = self:GetEntity()
	-- Spawn the initial box so we can measure it.
	local initialBox = GetWorld():Spawn(self.properties.boxTemplate, self:BoxPosition(1), entity:GetRotation())
	table.insert(self.boxes, initialBox)

	self.boxHeight       = Vector.New(0, 0, initialBox.size.z)
	self.boxHeightOffset = self.boxHeightOffset - self.boxHeight / 2

	initialBox:AttachTo(entity)
	initialBox:SetPosition(self:BoxPosition(#self.boxes))
end

---
-- Get the box position for the given boxCount.
--
-- @treturn Vector
---
function MovementCaptureScript:BoxPosition(boxCount)
	return self:GetEntity():GetPosition() + self.boxHeightOffset + boxCount * self.boxHeight
end

---
-- Capture the given player in an invisible Capture Box.
--
-- @tparam  Character  player
-- @treturn Entity Box that the Player is captured in.
---
function MovementCaptureScript:CapturePlayer(player)
	Printf("MovementCapture: CapturePlayer {1}", player:GetName())

	-- First check if this player hasn't already been captured in a box.
	for _,box in ipairs(self.boxes) do
		if player == box.movementCaptureBoxScript.properties.player then
			Printf("MovementCapture: Player {1} was already captured", player:GetName())
			return box
		end
	end

	-- Try to find an empty box the player can use.
	for _,box in ipairs(self.boxes) do
		if nil == box.movementCaptureBoxScript.properties.player then
			box.movementCaptureBoxScript:CapturePlayer(player)
			Printf("MovementCaptureScript: Recycling box for Player {1}", player:GetName())
			return box
		end
	end

	-- If there are no more boxes left, spawn a new one.
	local box = GetWorld():Spawn(self.properties.boxTemplate, self:BoxPosition(#self.boxes + 1), self:GetRotation())
	table.insert(self.boxes, box)
	box:AttachTo(self:GetEntity())
	box.movementCaptureBoxScript:CapturePlayer(player)

	return box
end

return MovementCaptureScript
