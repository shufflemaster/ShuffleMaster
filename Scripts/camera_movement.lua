local camera_movement = {
	
	Properties = {
		outMoveEventName = { default = "MovePlayer", description = "Vector2d. Outgoing event name that carries a Vector2d transformed by the camera LookAt WorldTM for player input movement."},
		inMoveEventName = { default = "MoveEvent", description = "Vector2d. Incoming input vector event. Will be transformed and forward to targetEntity as <outMoveEventName>"},
		inRotateEventName = { default = "RotateCamera", description = "Vector2d. Incoming input vector event. x is Yaw. y is Pitch."},
		
		targetEntity = { default = EntityId(), description="The target player object to track."},  
		distanceFromTarget = { default = 5, description="LookAt Distance from the target entity.", suffix = "m" }, 
		upOffset = { default = 2, description="Offset in the Up (Z) direction to elevate the Camera at the tracking position", suffix = "m"},
		camRotSpeed = { default = 90, description="How fast the camera rotates around the target", suffix = "deg/sec" } ,
		camPitchLimit = { default = 70, description="Magnitude of the pitch limit for camera spherical movement.", suffix = "deg"},
	},
	
	-- NotificationId of Outgoing Events
	Events = {
	},
	
}

function camera_movement:OnActivate()
	if (not EntityId.IsValid(self.Properties.targetEntity)) then
		Debug.Log("No target entity to track")
		return
	end
	
	-- Direction we want to be going as determined by the controller stick direction
    self.evtRotVector = Vector2(0,0);
	self.camYaw = 0.0;
	self.camPitch = 0.0;
	self.camPitchLimitRads = Math.DegToRad(self.Properties.camPitchLimit)
	
	-- Connect to tick bus to receive time updates
    self.tickBusHandler = TickBus.Connect(self);

	self.rotateEventBusId = GameplayNotificationId(self.entityId, self.Properties.inRotateEventName, "Vector2")
	self.rotateEventBus = GameplayNotificationBus.Connect(self, self.rotateEventBusId)
	
	self.moveEventBusId = GameplayNotificationId(self.entityId, self.Properties.inMoveEventName, "Vector2")
	self.moveEventBus = GameplayNotificationBus.Connect(self, self.moveEventBusId)
	
	self.Events.outMoveEventNotificationId = GameplayNotificationId(self.Properties.targetEntity,
										self.Properties.outMoveEventName, "Vector2")
end

function camera_movement:TransformMoveInput(vector2Value)
	local camTrm = TransformBus.Event.GetWorldTM(self.entityId)
	local camFwdVec3 = camTrm:GetColumn(1)
	local camUpVec3 = Vector3.CreateAxisZ()
	
	camFwdVec3:Set(camFwdVec3.x, camFwdVec3.y, 0)
	camFwdVec3:Normalize()
	
	camTrm:SetColumn(1, camFwdVec3)
	camTrm:SetColumn(2, camUpVec3)
	
	local retVec3 = Vector3(vector2Value.x, vector2Value.y, 0)
	retVec3 = camTrm:Multiply3x3(retVec3)
	vector2Value.x = retVec3.x
	vector2Value.y = retVec3.y
 	return vector2Value
end


function camera_movement:OnEventBegin(vector2Value)
	if (GameplayNotificationBus.GetCurrentBusId() == self.rotateEventBusId) then
		self.evtRotVector = vector2Value
	elseif (GameplayNotificationBus.GetCurrentBusId() == self.moveEventBusId) then
		local vec2 = self:TransformMoveInput(vector2Value)
		GameplayNotificationBus.Event.OnEventBegin(self.Events.outMoveEventNotificationId,
												   vec2);
	end
end

function camera_movement:OnEventUpdating(vector2Value)
	if (GameplayNotificationBus.GetCurrentBusId() == self.rotateEventBusId) then
		self.evtRotVector = vector2Value
	elseif (GameplayNotificationBus.GetCurrentBusId() == self.moveEventBusId) then
		local vec2 = self:TransformMoveInput(vector2Value)
		GameplayNotificationBus.Event.OnEventUpdating(self.Events.outMoveEventNotificationId,
												   vec2);
	end
end

function camera_movement:OnEventEnd(vector2Value)
	if (GameplayNotificationBus.GetCurrentBusId() == self.rotateEventBusId) then
		self.evtRotVector = vector2Value
	elseif (GameplayNotificationBus.GetCurrentBusId() == self.moveEventBusId) then
		local vec2 = self:TransformMoveInput(vector2Value)
		GameplayNotificationBus.Event.OnEventEnd(self.Events.outMoveEventNotificationId,
												 vec2);
	end
end

-- OLD Game heartbeat
function camera_movement:OldOnTick(deltaTime, timePoint)
	-- We always follow the target from a distance
	local targetPos = TransformBus.Event.GetWorldTranslation(self.Properties.targetEntity)
	
	local camTM = TransformBus.Event.GetWorldTM(self.entityId)
	local camForward = camTM:GetColumn(1)
	local camUp = camTM:GetColumn(2)
	
	local newCamPos = targetPos - camForward * self.Properties.distanceFromTarget
	newCamPos = newCamPos + camUp * self.Properties.upOffset 
	
	TransformBus.Event.SetWorldTranslation(self.entityId, newCamPos)
end

-- Game heartbeat
function camera_movement:OnTick(deltaTime, timePoint)
	self.camYaw = self.camYaw + Math.DegToRad(self.evtRotVector.x * self.Properties.camRotSpeed * deltaTime)
	self.camPitch = self.camPitch + Math.DegToRad(self.evtRotVector.y * self.Properties.camRotSpeed * deltaTime)
	if (self.camPitch < -self.camPitchLimitRads) then
		self.camPitch = -self.camPitchLimitRads
	elseif (self.camPitch > self.camPitchLimitRads) then
		self.camPitch = self.camPitchLimitRads
	end
    local cameraQuat = Quaternion.CreateRotationZ(self.camYaw) * Quaternion.CreateRotationX(self.camPitch);
    --the direction the camera is pointing as a matrix
    local look = Transform.CreateFromQuaternionAndTranslation(cameraQuat,Vector3(0,0,0));
    local relCameraTm = Transform.CreateIdentity();
    --we want the camera to be moved a bit backwards from where the player is in the direction that it is pointing
    relCameraTm:SetTranslation(Vector3(0,-self.Properties.distanceFromTarget,0));
    relCameraTm = look  * relCameraTm;
    local playerTm = TransformBus.Event.GetWorldTM(self.Properties.targetEntity);
    local playerTranslationTm = Transform.CreateTranslation(playerTm:GetTranslation());
    --camera location is relative to the player
    local cameraTm = 
        Transform.CreateTranslation(Vector3(0,0,self.Properties.upOffset)) *
        playerTranslationTm *
        relCameraTm;
    TransformBus.Event.SetWorldTM(self.entityId, cameraTm);
end

function camera_movement:OnDeactivate()
	if (self.rotateEventBus) then
		self.rotateEventBus:Disconnect()
	end
	if (self.moveEventBus) then
		self.moveEventBus:Disconnect()
	end
	if (self.tickBusHandler) then
        self.tickBusHandler:Disconnect()
    end
end


return camera_movement