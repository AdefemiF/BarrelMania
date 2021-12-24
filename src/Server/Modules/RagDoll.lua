local RagDoll = {} --Ragdoll Script by CRazyMan32? with slight modifications for the game code

local function recurse(root,callback,i)
	i= i or 0
	for _,v in pairs(root:GetChildren()) do
		i = i + 1
		callback(i,v)
		
		if #v:GetChildren() > 0 then
			i = recurse(v,callback,i)
		end
	end
	
	return i
end

local function ragdollJoint(character,part0, part1, attachmentName, className, properties)
	attachmentName = attachmentName.."RigAttachment"
	local constraint = Instance.new(className.."Constraint")
	constraint.Attachment0 = part0:FindFirstChild(attachmentName)
	constraint.Attachment1 = part1:FindFirstChild(attachmentName)
	constraint.Name = "RagdollConstraint"..part1.Name
	
	for _,propertyData in next,properties or {} do
		constraint[propertyData[1]] = propertyData[2]
	end
	
	constraint.Parent = character
end

local function getAttachment0(character,attachmentName)
	for _,child in next,character:GetChildren() do
		local attachment = child:FindFirstChild(attachmentName)
		if attachment then
			return attachment
		end
	end
end

function RagDoll:Simulate(plr)
    spawn(function()
        local char = game.Players[plr].Character;
        local pos = char.UpperTorso.Position;
        local b = Instance.new("BodyPosition")
        b.position = pos+ Vector3.new(math.random(-100,100)*5, 5, math.random(-100,100)*5)
        b.maxForce = Vector3.new(math.huge, math.huge, math.huge)
        b.P = 1000;
        b.Parent = char.UpperTorso
        char:findFirstChild("Humanoid").Health = 0;
        wait(1)
        b.Parent = nil
    end);
    RagDoll:DeathP2(plr);
end;

function RagDoll:DeathP2(plr)
    local char = game.Players[plr].Character;
    local camera = workspace.CurrentCamera;
    if camera.CameraSubject == char.Humanoid then--If developer isn't controlling camera
        camera.CameraSubject = char.UpperTorso;
    end
    --Make it so ragdoll can't collide with invisible HRP, but don't let HRP fall through map and be destroyed in process
    char.HumanoidRootPart.Anchored = true
    char.HumanoidRootPart.CanCollide = false
    --Helps to fix constraint spasms
    recurse(char, function(_,v)
        if v:IsA("Attachment") then
            v.Axis = Vector3.new(0, 1, 0)
            v.SecondaryAxis = Vector3.new(0, 0, 1)
            v.Rotation = Vector3.new(0, 0, 0)
        end
    end)
    --Re-attach hats
    for _,child in next,char:GetChildren() do
        if child:IsA("Accoutrement") then
            --Loop through all parts instead of only checking for one to be forwards-compatible in the event
            --ROBLOX implements multi-part accessories
            for _,part in next,child:GetChildren() do
                if part:IsA("BasePart") then
                    local attachment1 = part:FindFirstChildOfClass("Attachment")
                    local attachment0 = getAttachment0(char,attachment1.Name)
                    if attachment0 and attachment1 then
                        --Shouldn't use constraints for this, but have to because of a ROBLOX idiosyncrasy where
                        --joints connecting a character are perpetually deleted while the character is dead
                        local constraint = Instance.new("HingeConstraint")
                        constraint.Attachment0 = attachment0
                        constraint.Attachment1 = attachment1
                        constraint.LimitsEnabled = true
                        constraint.UpperAngle = 0 --Simulate weld by making it difficult for constraint to move
                        constraint.LowerAngle = 0
                        constraint.Parent = char
                    end
                end
            end
        end
    end
    ragdollJoint(char,char.LowerTorso, char.UpperTorso, "Waist", "BallSocket", {{"LimitsEnabled",true};{"UpperAngle",5};})
    ragdollJoint(char,char.UpperTorso, char.Head, "Neck", "BallSocket", {{"LimitsEnabled",true};{"UpperAngle",15};})
    local handProperties = {{"LimitsEnabled", true};{"UpperAngle",0};{"LowerAngle",0};}
    ragdollJoint(char,char.LeftLowerArm, char.LeftHand, "LeftWrist", "Hinge", handProperties)
    ragdollJoint(char,char.RightLowerArm, char.RightHand, "RightWrist", "Hinge", handProperties)
    local shinProperties = {{"LimitsEnabled", true};{"UpperAngle", 0};{"LowerAngle", -75};}
    ragdollJoint(char,char.LeftUpperLeg, char.LeftLowerLeg, "LeftKnee", "Hinge", shinProperties)
    ragdollJoint(char,char.RightUpperLeg, char.RightLowerLeg, "RightKnee", "Hinge", shinProperties)
    local footProperties = {{"LimitsEnabled", true};{"UpperAngle", 15};{"LowerAngle", -45};}
    ragdollJoint(char,char.LeftLowerLeg, char.LeftFoot, "LeftAnkle", "Hinge", footProperties)
    ragdollJoint(char,char.RightLowerLeg, char.RightFoot, "RightAnkle", "Hinge", footProperties)
    ragdollJoint(char,char.UpperTorso, char.LeftUpperArm, "LeftShoulder", "BallSocket")
    ragdollJoint(char,char.LeftUpperArm, char.LeftLowerArm, "LeftElbow", "BallSocket")
    ragdollJoint(char,char.UpperTorso, char.RightUpperArm, "RightShoulder", "BallSocket")
    ragdollJoint(char,char.RightUpperArm, char.RightLowerArm, "RightElbow", "BallSocket")
    ragdollJoint(char,char.LowerTorso, char.LeftUpperLeg, "LeftHip", "BallSocket")
    ragdollJoint(char,char.LowerTorso, char.RightUpperLeg, "RightHip", "BallSocket")
end;

return RagDoll;