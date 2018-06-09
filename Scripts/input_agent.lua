local input_agent = {
	
	--[[ This script should be attached to an empty, static entity. The idea is to decouple
	     the origin of the input events from the event receivers. You can later generate
	     events from a csv file or from network events and the camera object would never know.
	  ]]
	Properties = {
		outMoveEventName = { default = "MoveEvent", description = "Vector2. Outgoing event name for player input movement in gamepad coordinate space."},
		outRotateEventName = {default = "RotateCamera", description = "Vector2. Outgoing event for camera rotation movement. x should be used for Yaw, y should be used for pitch"},
		camera = {default = EntityId(), description="A reference to the Entity that owns a Camera component."},
	},
	
	-- NotificationId of Outgoing Events
	Events = {
	}	
}

function input_agent:OnActivate()
	
	if (not EntityId.IsValid(self.Properties.camera)) then
		Debug.Log("No camera entity to move")
		return
	end
	
	-- In this vector we record the state of the controller stick direction
    self.moveVec = Vector2(0,0);
	
	self.moveForwardBackBusId = InputEventNotificationId("moveForwardBack")
	self.moveForwardBackBus = InputEventNotificationBus.Connect(self, self.moveForwardBackBusId)
	
	self.moveRightLeftBusId = InputEventNotificationId("moveRightLeft")
	self.moveRightLeftBus = InputEventNotificationBus.Connect(self, self.moveRightLeftBusId)
	
	-- Define the event id for our proprietary event that will be used to notify
	-- input updates.
	self.Events.moveEventNotificationId = GameplayNotificationId(self.Properties.camera,
										self.Properties.outMoveEventName, "Vector2")
										
	-- In this vector we record the state of the controller/mouse stick direction
    self.rotateVec = Vector2(0,0);
																				
	self.rotateRightLeftBusId = InputEventNotificationId("rotCamRightLeft")
	self.rotateRightLeftBus = InputEventNotificationBus.Connect(self, self.rotateRightLeftBusId)

	self.rotateUpDownBusId = InputEventNotificationId("rotCamUpDown")
	self.rotateUpDownBus = InputEventNotificationBus.Connect(self, self.rotateUpDownBusId)
	
	self.Events.rotateEventNotificationId = GameplayNotificationId(self.Properties.camera,
										self.Properties.outRotateEventName, "Vector2")
end

-- Function when input is pressed
function input_agent:OnPressed(floatValue)
    if (InputEventNotificationBus.GetCurrentBusId() == self.moveForwardBackBusId) then
		self.moveVec.y = floatValue
    	GameplayNotificationBus.Event.OnEventBegin(self.Events.moveEventNotificationId,
												   self.moveVec);
    elseif (InputEventNotificationBus.GetCurrentBusId() == self.moveRightLeftBusId) then
		self.moveVec.x = floatValue
    	GameplayNotificationBus.Event.OnEventBegin(self.Events.moveEventNotificationId,
												   self.moveVec);
    elseif (InputEventNotificationBus.GetCurrentBusId() == self.rotateRightLeftBusId) then
		self.rotateVec.x = floatValue
		GameplayNotificationBus.Event.OnEventBegin(self.Events.rotateEventNotificationId,
												   self.rotateVec); 
	elseif (InputEventNotificationBus.GetCurrentBusId() == self.rotateUpDownBusId) then
		self.rotateVec.y = floatValue
		GameplayNotificationBus.Event.OnEventBegin(self.Events.rotateEventNotificationId,
												   self.rotateVec); 
	end  
end

-- Function when input is held

function input_agent:OnHeld(floatValue)
    if (InputEventNotificationBus.GetCurrentBusId() == self.moveForwardBackBusId) then
		self.moveVec.y = floatValue
    	GameplayNotificationBus.Event.OnEventUpdating(self.Events.moveEventNotificationId,
												   self.moveVec);
    elseif (InputEventNotificationBus.GetCurrentBusId() == self.moveRightLeftBusId) then
		self.moveVec.x = floatValue
    	GameplayNotificationBus.Event.OnEventUpdating(self.Events.moveEventNotificationId,
												   self.moveVec);
    elseif (InputEventNotificationBus.GetCurrentBusId() == self.rotateRightLeftBusId) then
		self.rotateVec.x = floatValue
		GameplayNotificationBus.Event.OnEventUpdating(self.Events.rotateEventNotificationId,
												   self.rotateVec); 
	elseif (InputEventNotificationBus.GetCurrentBusId() == self.rotateUpDownBusId) then
		self.rotateVec.y = floatValue
		GameplayNotificationBus.Event.OnEventUpdating(self.Events.rotateEventNotificationId,
												   self.rotateVec); 
	end 
end

-- Function when input is released 
function input_agent:OnReleased(floatValue)
    if (InputEventNotificationBus.GetCurrentBusId() == self.moveForwardBackBusId) then
		self.moveVec.y = 0.0
    	GameplayNotificationBus.Event.OnEventEnd(self.Events.moveEventNotificationId,
												   self.moveVec);
    elseif (InputEventNotificationBus.GetCurrentBusId() == self.moveRightLeftBusId) then
		self.moveVec.x = 0.0
    	GameplayNotificationBus.Event.OnEventEnd(self.Events.moveEventNotificationId,
												   self.moveVec);
    elseif (InputEventNotificationBus.GetCurrentBusId() == self.rotateRightLeftBusId) then
		self.rotateVec.x = 0.0
		GameplayNotificationBus.Event.OnEventEnd(self.Events.rotateEventNotificationId,
												   self.rotateVec); 
	elseif (InputEventNotificationBus.GetCurrentBusId() == self.rotateUpDownBusId) then
		self.rotateVec.y = 0.0
		GameplayNotificationBus.Event.OnEventEnd(self.Events.rotateEventNotificationId,
												   self.rotateVec); 
	end 
end


function input_agent:OnDeactivate()
	self.moveForwardBackBus:Disconnect()
	self.moveRightLeftBus:Disconnect()
	self.rotateRightLeftBus:Disconnect()
	self.rotateUpDownBus:Disconnect()
end


return input_agent