local player_movement = {
	
	Properties = {
		inMoveEventName =  {default="MovePlayer", description="Vector2. Incoming event name with the target movement control data."},
		movementSpeed = {default=4.0, description="", suffix = "m/s" },
		reorientationSpeed = { default=4.0, description="How fast the object forward vector aligns with the input event vector", suffix = "rads/s"},
	}
	
}

function player_movement:OnActivate()
	
	-- Direction we want to be going as determined by the controller stick direction
    self.evtMoveVector = Vector2(0,0);

	self.random = Random(23) -- Random(TimeOfDay.GetTime())	
	
	-- Connect to tick bus to receive time updates
    self.tickBusHandler = TickBus.Connect(self);

	self.moveEventBusId = GameplayNotificationId(self.entityId, self.Properties.inMoveEventName, "Vector2")
	self.moveEventBus = GameplayNotificationBus.Connect(self, self.moveEventBusId)

end

function player_movement:OnEventBegin(vector2Value)
	self.evtMoveVector = vector2Value
end

function player_movement:OnEventUpdating(vector2Value)
	self.evtMoveVector = vector2Value
end

function player_movement:OnEventEnd(vector2Value)
	self.evtMoveVector = vector2Value
end

-- Game heartbeat
function player_movement:OnTick(deltaTime, timePoint)
	local x = self.evtMoveVector.x
	local y = self.evtMoveVector.y
	
	if ((x == 0) and (y == 0)) then
		return;
	end
		
	local targetForward = Vector3.ConstructFromValues(x, y, 0)
	targetForward:Normalize()
	
	local trm = TransformBus.Event.GetWorldTM(self.entityId)
	local forward = trm:GetColumn(1)
	
	--[[ When current forward vector and target forward vector are 180deg
	     from each other the slerp doesn't do anything. let's add a little
	     bit of random noise to the current forward vector in both x and y ]] 
	local dot = forward:Dot(targetForward)
	if (dot == -1) then
		local noiseX = self.random:GetRandomFloat()
		local signX = 1;
		if (noiseX < 0.5) then
			signX = -1;
		end
		local noiseY = self.random:GetRandomFloat()
		local signY = 1;
		if (noiseY < 0.5) then
			signY = -1;
		end
		
		local newX = forward.x + signX * noiseX/10.0 
		local newY = forward.y + signY * noiseY/10.0
		Debug.Log("x=" .. tostring(forward.x) .. ", y=" .. tostring(forward.y) .. ", newX=" .. tostring(newX) .. ", newY=" .. tostring(newY))
		forward.x = newX
		forward.y = newY
		forward:Normalize()	
	end	
	
	forward = forward:Slerp(targetForward, deltaTime * self.Properties.reorientationSpeed)
	
	local posVec = trm:GetColumn(3)
	posVec = posVec + targetForward * self.Properties.movementSpeed * deltaTime
	
	local up = Vector3.CreateAxisZ()
	local right = Vector3.CrossZAxis(forward)
				
	trm:SetColumns(right, forward, up, posVec)
	TransformBus.Event.SetWorldTM(self.entityId, trm)
end

function player_movement:OnDeactivate()
	if (self.moveEventBus) then
		self.moveEventBus:Disconnect()
	end
	if (self.tickBusHandler) then
        self.tickBusHandler:Disconnect()
    end
end


return player_movement