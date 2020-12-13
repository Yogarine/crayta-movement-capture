------------------------------------------------------------------------------------------------------------------------
-- @module    Yogarine.PlayerMovement
-- @author    Alwin "Yogarine" Garside <alwin@garsi.de>
-- @copyright 2020 Alwin Garside
-- @license   https://opensource.org/licenses/BSD-2-Clause 2-Clause BSD License
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- Adding this script to your Player allows you to then listen to Player movement events.
--
-- The PlayerMovement package comes with a convenient Template you can attach to your Player.
--
-- @type MovementPlayerScript
------------------------------------------------------------------------------------------------------------------------

---
-- @field properties Properties: Holds the values that have been set on an instance of a script.
---
local MovementPlayerScript = {
	TICK_RATE = 30,                       -- number: Tick rate, is adjusted on clients.
	RECENT_VELOCITY_VECTORS_AMOUNT   = 3, -- number: Amount of movement velocity vectors to use for averaging.
	RECENT_VELOCITY_ROTATIONS_AMOUNT = 3, -- number: Amount of rotation velocity vectors to use for averaging.
}

---
-- Script properties are defined here.
---
MovementPlayerScript.Properties = {
	{ name = "onPlayerMovement",       type = "event",  tooltip = "Triggered on server when Player moves." },
	{ name = "onPlayerRotation",       type = "event",  tooltip = "Triggered on server when Player rotates." },
	{ name = "onPlayerLook",           type = "event",  tooltip = "Triggered on server when Player looks." },
	{ name = "clientOnPlayerMovement", type = "event",  tooltip = "Triggered on clients when Player moves." },
	{ name = "clientOnPlayerRotation", type = "event",  tooltip = "Triggered on clients when Player roates." },
	{ name = "clientOnPlayerLook",     type = "event",  tooltip = "Triggered on clients when Player looks." },
	{ name = "localOnPlayerMovement",  type = "event",  tooltip = "Triggered on local client when Player moves." },
	{ name = "localOnPlayerRotation",  type = "event",  tooltip = "Triggered on local client when Player rotates." },
	{ name = "localOnPlayerLook",      type = "event",  tooltip = "Triggered on local client when Player looks." },
}

---
-- Initializes all the fields.
---
function MovementPlayerScript:InitFields()

	---
	-- !Util: Yogarine's Util class.
	---
	self.Util = self:GetEntity().util

	---
	-- !Stack: Yogarine's Stack class.
	---
	self.Stack = self:GetEntity().stack

	---
	-- ?Vector: Player position from the previous frame.
	---
	self.lastPosition = nil

	---
	-- ?Rotation: Player rotation from the previous frame.
	---
	self.lastRotation = nil

	---
	-- ?Vector: Last look eye position.
	---
	self.lastLookAtEye = nil

	---
	-- ?Vector: Last look at position.
	---
	self.lastLookAtPos = nil

	---
	-- ?Vector: Used to hold the Player position for the duration of this frame.
	---
	self.position = nil

	---
	-- ?Rotation: Used to hold the position for the duraction of this frame.
	---
	self.rotation = nil

	---
	-- ?Vector: Used to hold the lookAtEye for the duraction of this frame.
	---
	self.lookAtEye = nil

	---
	-- ?Vector: Used to hold the lookAtPos for the duraction of this frame.
	---
	self.lookAtPos = nil

	---
	-- !{Vector,...}: Recent movement velocity Vectors used for averaging the velocity Vector.
	---
	self.recentVelocityVectors = self.Stack:New(self.RECENT_VELOCITY_VECTORS_AMOUNT)

	---
	-- !{Rotation,...}: Recent velocity Rotations used for averaging the velocity Rotation.
	---
	self.recentVelocityRotations = self.Stack:New(self.RECENT_VELOCITY_ROTATIONS_AMOUNT)

	self:UpdateLastPosition()
end

---
-- Called on the server when this entity is created.
---
function MovementPlayerScript:Init()
	Printf("Movement: Init {1}", self:GetEntity():GetName())
	self:InitFields()

	if not self:GetEntity():IsA(Character) then
		error("MovementPlayer: Should be attached to the Player.")
	end
end

---
-- Called on the clients when this entity is created.
---
function MovementPlayerScript:ClientInit()
	Printf("Movement: ClientInit {1}", self:GetEntity():GetName())
	self:InitFields()

	self.TICK_RATE = 60
end

---
-- Update the last stored position for this Player.
---
function MovementPlayerScript:UpdateLastPosition()
	local position = self:GetEntity():GetPosition()
	Printf("Movement: lastPosition: {1} => {2}", self.lastPosition, position)

	self.lastPosition = position
end

---
-- Called each frame on the server.
--
-- @tparam  number  deltaTimeSeconds  Time elapsed since the last frame was rendered.
---
function MovementPlayerScript:OnTick(deltaTimeSeconds)
	local entity = self:GetEntity()

	-- Store the fields from the previous frame in the last* fields.
	self.lastPosition  = self.position
	self.lastRotation  = self.rotation
	self.lastLookAtEye = self.lookAtEye
	self.lastLookAtPos = self.lookAtPos

	-- Updated the fields with data from the current frame.
	self.position      = entity:GetPosition()
	self.rotation      = entity:GetRotation()
	self.lookAtEye, self.lookAtPos = entity:GetLookAt()

	-- Send out events.
	self:SendMovementToEvent(deltaTimeSeconds, self.properties.onPlayerMovement)
	self:SendRotationToEvent(deltaTimeSeconds, self.properties.onPlayerRotation)
	self:SendLookAtToEvent(deltaTimeSeconds, self.properties.localOnPlayerLook)
end

---
-- Called each frame on the client.
--
-- @tparam  number  deltaTimeSeconds  Time elapsed since the last frame was rendered.
---
function MovementPlayerScript:ClientOnTick(deltaTimeSeconds)
	local entity = self:GetEntity()

	-- Store the fields from the previous frame in the last* fields.
	self.lastPosition  = self.position
	self.lastRotation  = self.rotation
	self.lastLookAtEye = self.lookAtEye
	self.lastLookAtPos = self.lookAtPos

	-- Updated the fields with data from the current frame.
	self.position = entity:GetPosition()
	self.rotation = entity:GetRotation()
	self.lookAtEye, self.lookAtPos = entity:GetLookAt()

	-- Send out events.
	self:SendMovementToEvent(deltaTimeSeconds, self.properties.clientOnPlayerMovement)
	self:SendRotationToEvent(deltaTimeSeconds, self.properties.clientOnPlayerRotation)
	self:SendLookAtToEvent(deltaTimeSeconds, self.properties.clientOnPlayerLook)
end

---
-- Called each frame on the client that controls this entity (eg player, user, etc.)
--
-- @tparam  number  deltaTimeSeconds  Time elapsed since the last frame was rendered.
---
function MovementPlayerScript:LocalOnTick(deltaTimeSeconds)
	-- Send out events.
	self:SendMovementToEvent(deltaTimeSeconds, self.properties.localOnPlayerMovement)
	self:SendRotationToEvent(deltaTimeSeconds, self.properties.localOnPlayerRotation)
	self:SendLookAtToEvent(deltaTimeSeconds, self.properties.localOnPlayerLook)
end

---
-- Send movement data to to the given Event.
--
-- @tparam  number  deltaTimeSeconds  Time elapsed since the last frame was rendered.
-- @tparam  Event   movementEvent     Event to send the movement data to.
---
function MovementPlayerScript:SendMovementToEvent(deltaTimeSeconds, movementEvent)
	if
	movementEvent:HasBindings() and
			self:CheckVelocity(self.lastPosition, self.position, deltaTimeSeconds)
	then
		local velocityVector = (self.lastPosition - self.position) / (deltaTimeSeconds * self.TICK_RATE)
		self.recentVelocityVectors:Push(velocityVector)
		local avgVelocityVector = self.recentVelocityVectors:Average()

		movementEvent:Send(self:GetEntity(), velocityVector, avgVelocityVector)
	end
end

---
-- Send rotation data to to the given Event.
--
-- @tparam  number  deltaTimeSeconds  Time elapsed since the last frame was rendered.
-- @tparam  Event   rotationEvent     Event to send the rotation data to.
---
function MovementPlayerScript:SendRotationToEvent(deltaTimeSeconds, rotationEvent)
	if rotationEvent:HasBindings() then
		local velocityRotation = (self.lastRotation - self.rotation) / (deltaTimeSeconds * self.TICK_RATE)
		self.recentVelocityRotations:Push(velocityRotation)
		local avgVelocityRotation = self.recentVelocityRotations:Average()

		rotationEvent:Send(self:GetEntity(), velocityRotation, avgVelocityRotation)
	end
end

---
-- Send look data to the given Event.
--
-- @tparam  number  deltaTimeSeconds
-- @tparam  Event   rotationEvent
---
function MovementPlayerScript:SendLookAtToEvent(deltaTimeSeconds, lookEvent)
	if lookEvent:HasBindings() then
		lookEvent:Send(self:GetEntity(), self.lookAtEye, self.lookAtPos)
	end
end

---
-- Check if velocity doesn't exceed the threshold to filter out buggy player movement.
--
-- @tparam  Vector  lastPosition
-- @tparam  Vector  position
-- @tparam  number  deltaTimeSeconds
-- @treturn boolean False if the velocity exceeds the threshold, true otherwise.
---
function MovementPlayerScript:CheckVelocity(lastPosition, position, deltaTimeSeconds)
	local VELOCITY_THRESHOLD_MULTIPLIER = 50

	local distance          = Vector.Distance(lastPosition, position)
	local velocity          = distance / (deltaTimeSeconds * self.TICK_RATE)
	local player            = self:GetEntity()
	local velocityThreshold = player.speedMultiplier * VELOCITY_THRESHOLD_MULTIPLIER

	if velocity > velocityThreshold then
		Printf("Movement: velocity exceeds threshold ({1})", velocity)
		Printf("Movement: distance: {1}", distance)

		return false
	else
		return true
	end
end

return MovementPlayerScript
