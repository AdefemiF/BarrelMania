-- Barrel Explosions
-- TrollD3/UndetectedShadow
-- October 3, 2020

--//Services Used
local tweenserv = game:GetService("TweenService")
local Replication = require(script.Parent.Parent.Services.ReplicationHandler) --Functions of Game
local RagDoll = require(script.Parent.Parent.Modules.RagDoll)
local Framework = require(script.Parent.Parent.Services.Framework)


--//Colors for Explosions
local red = Color3.fromRGB(166, 90, 86)
local og = Color3.fromRGB(181, 119, 78)

--//Abbreviations for Vectors/CFrame
local cf = CFrame.new
local v3 = Vector3.new

--//Fake Barrels
local fracturedbarrel = game.ServerStorage.gameObjects.debris;

local BarrelExplosions = {}

local tweengoal = function(...)
    local goal = {}
    for _,v in pairs ({...}) do
        goal[v[1]]=v[2]
    end
    return goal
end

local tween = function(instances,info,goal)
    local tweens = {}
    if type(instances) ~= "table" then instances = {instances} end
    for _,v in pairs (instances) do
		if v.ClassName =="ParticleEmitter" or v.ClassName == "Trail" or v.ClassName == "Attachment" then continue end;
		local actual = tweenserv:Create(v,info,goal)
		table.insert(tweens,actual)
		actual:Play()
    end
    return tweens
end

local mix = function(tab)
	local t = {}
	repeat
		local n = math.random(1,#tab)
		table.insert(t,tab[n])
		table.remove(tab,n)
	until #tab == 0
	return t
end

local disp = function(p,t)
	spawn(function()
		wait(t)
		p.Enabled = false
	end)
end

function Weld(part1, part2)
    local weld = Instance.new("Weld")
    weld.Part0 = part1
    weld.Part1 = part2
    weld.C0 = part1.CFrame:inverse()
    weld.C1 = part2.CFrame:inverse()
    weld.Parent = part1
end

local boom = function(model,plr)
	spawn(function()

		local debris = fracturedbarrel:Clone()
        if model == nil or model:FindFirstChild("body") == nil then return end
        local clone = model.body:Clone()
        clone.Color = red
        clone.Parent = workspace.Holder
        clone.Material = Enum.Material.Neon
        Weld(clone,plr.Character.PrimaryPart)
        clone.CanCollide = false
        clone.Transparency = 1
        debris.Parent = workspace.Holder
        debris:SetPrimaryPartCFrame(cf(clone.CFrame.p))
        for _,v in pairs(debris:GetChildren()) do
            if v.ClassName ~= "Model" then continue end
            for _,q in pairs(v:GetChildren()) do
                q.Anchored = false
                Weld(q,plr.Character.PrimaryPart)
            end
        end
        debris.c.Anchored = false
        Weld(debris.c,plr.Character.PrimaryPart)
        tween(debris.bottom:GetChildren(),TweenInfo.new(.5),tweengoal({"Transparency",0}))
        tween(debris.top:GetChildren(),TweenInfo.new(.5),tweengoal({"Transparency",0}))
        tween(clone,TweenInfo.new(4),tweengoal({"Transparency",-3}))
        tween(model:GetChildren(),TweenInfo.new(.5),tweengoal({"Transparency",1}))
		for i = 2.5,1,-.5 do
            if model == nil or model:FindFirstChild("body") == nil then break end
            local clone = model.body:Clone()
            for _,v in pairs (clone:GetChildren()) do
                if v.ClassName == "Texture" then v:Destroy() end
            end
            clone.Parent = model.Parent
            Weld(clone,plr.Character.PrimaryPart)
			clone.Color = og
			clone.Material = Enum.Material.Neon
			clone.Transparency = 0
			tween(clone,TweenInfo.new(i/5),tweengoal({"Transparency",1},{"Size",clone.Size*1.5},{"Color",red}))
			game:GetService("Debris"):AddItem(clone,i/5)
			wait(i/10)
        end
        
		model:Destroy()
        clone:Destroy()
		debris.c.shock:Emit(1)
		debris.c.ray:Emit(1)
        debris.c.flare:Emit(2)

        Replication:Replicate("Shake", debris.c.Position)
        RagDoll:Simulate(plr.Name)
        Framework:ReturnInfo("Script"):KillWithinRadius(plr, debris.c.Position);
		local move = debris.BodyVelocity
		local g = debris.g
		local top = debris.top
		local bottom = debris.bottom
		local glo = debris.c.glow2:Clone()
		glo.Name = "."
		glo.Parent = debris.c
		glo.Enabled = true
		disp(glo,2)
		for _,v in pairs(top:GetChildren()) do
			v.UsePartColor = true
			v.Color = red
			tween(v,TweenInfo.new(4),tweengoal({"Color",Color3.new(.3,.3,.3)}))
			local glow2 = debris.c.glow2:Clone()
			glow2.Parent = v
			glow2.Enabled = true
			disp(glow2,2)
			local glow = debris.c.glow:Clone()
			glow.Parent = v
			glow.Enabled = true
			disp(glow,1.5)
			local smoke = debris.c.smoke:Clone()
			smoke.Parent = v
			smoke.Enabled = true
			disp(smoke,1.5)
			local bits = debris.c.bits:Clone()
			bits.Parent = v
			bits.Enabled = true
			disp(bits,1.5)
			v.Anchored = false
            v:ClearAllChildren() -- destroys welds
			v:SetNetworkOwner(nil)
			local m = move:Clone()
			local gc = g:Clone()
			gc.Parent = v
			game:GetService("Debris"):AddItem(gc,2)
			m.Velocity = (cf(debris.c.CFrame.p,v.CFrame.p).lookVector*30)+v3(0,85,0)
			m.Parent = v
			game:GetService("Debris"):AddItem(m,.1)
			spawn(function()
				wait(5)
				tween(v,TweenInfo.new(2),tweengoal({"Transparency",1},{"Size",v.Size*.6}))
				wait(2)
				v:Destroy()
			end)
        end
		for _,v in pairs(bottom:GetChildren()) do
			v.UsePartColor = true
			v.Color = red
			tween(v,TweenInfo.new(2),tweengoal({"Color",Color3.new(.3,.3,.3)}))
			local glow2 = debris.c.glow2:Clone()
			glow2.Parent = v
			glow2.Enabled = true
			disp(glow2,1)
			local bits = debris.c.bits:Clone()
			bits.Parent = v
			bits.Enabled = true
			disp(bits,.5)
			v.Anchored = false
            local success,response = pcall(function() 
                v:SetNetworkOwner(nil)
            end)
			local m = move:Clone()
			local gc = g:Clone()
			gc.Parent = v
			game:GetService("Debris"):AddItem(gc,2)
			m.Velocity = cf(debris.c.CFrame.p,v.CFrame.p).lookVector * 50
			m.Parent = v
			game:GetService("Debris"):AddItem(m,.1)
			spawn(function()
				wait(5)
				tween(v,TweenInfo.new(2),tweengoal({"Transparency",1},{"Size",v.Size*.6}))
				wait(2)
				v:Destroy()
			end)
		end
		spawn(function()
			wait(7.1)
			debris:Destroy()
		end)
	end)
end

function BarrelExplosions:Boom(model,plr)
    boom(model,plr)
end

function BarrelExplosions:BarrelBoom(model, killPlayer)
	spawn(function()
		if not model:FindFirstChild("original") then model:Destroy() return end;
		local original = model.original
		local debris = model.debris
		local clone = original.body:Clone()
		clone.CanCollide = false
		clone.Color = red
		clone.Parent = model
		Weld(clone,original.body)
		clone:SetNetworkOwner(nil)
		clone.Material = Enum.Material.Neon
		clone.Transparency = 1
		debris.Parent = model
		debris:SetPrimaryPartCFrame(cf(clone.CFrame.p))
		tween(debris.bottom:GetChildren(),TweenInfo.new(.5),tweengoal({"Transparency",0}))
		tween(debris.top:GetChildren(),TweenInfo.new(.5),tweengoal({"Transparency",0}))
		tween(clone,TweenInfo.new(4),tweengoal({"Transparency",-3}))
		tween(original:GetChildren(),TweenInfo.new(.5),tweengoal({"Transparency",1}))
		for i = 3,1,-.5 do
			if not original:FindFirstChild("body") then original:Destroy() return end;
			local clone = original.body:Clone()
			clone.CanCollide = false
			Weld(clone,original.body)
			clone.Parent = model
			clone:SetNetworkOwner(nil)
			clone.Color = og
			clone.Material = Enum.Material.Neon
			clone.Transparency = 0
			tween(clone,TweenInfo.new(i/5),tweengoal({"Transparency",1},{"Size",clone.Size*1.5},{"Color",red}))
			game:GetService("Debris"):AddItem(clone,i/5)
			wait(i/10)
		end
		if not original:FindFirstChild("body") then model:Destroy() return end;
		original:Destroy()
		clone:Destroy()
		debris.c.shock:Emit(1)
		debris.c.ray:Emit(1)
		debris.c.flare:Emit(2)

		Replication:Replicate("Shake", debris.c.Position)
        if killPlayer== nil  then
		    Framework:ReturnInfo("Script"):KillWithinRadius(debris.c.Position);
        end
		local move = debris.BodyVelocity
		local g = debris.g
		local top = debris.top
		local bottom = debris.bottom

		top:Destroy()
		bottom:Destroy()
		for _,v in pairs(top:GetChildren()) do
			v.CanCollide = true
		end
		for _,v in pairs(bottom:GetChildren()) do
			v.CanCollide = true
		end
		debris.c.CanCollide = true

		wait(.5)
		debris:Destroy()
		model:Destroy()
	end)
end;


















return BarrelExplosions