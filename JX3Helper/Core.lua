Core = {}

--Global func
IgnoreChannelling = {}
buff = function(buffName, t) return Core.IsActiveBuff(buffName, me) end
nobuff = function(buffName, t) return not Core.IsActiveBuff(buffName, me) end
cd = function(skillName) return not Core.CheckCDs(skillName) end
nocd = function(skillName) return Core.CheckCDs(skillName) end
tbuff = function(buffName, t) return Core.IsActiveBuff(buffName, target) end
tnobuff = function(buffName, t) return not Core.IsActiveBuff(buffName, target) end
needtarget = function() Core.FindTarget() end	
needaoeheal = false
bignorecast = true

function Core.UpdateVars()
	me = GetClientPlayer()
	if me then
		bignorecast = false
		--Core.print(bignorecast)
		target = GetTargetHandle(me.GetTarget())
		dance = me.nAccumulateValue
		life = math.floor(me.nCurrentLife * 100 / me.nMaxLife)
		mana = math.floor(me.nCurrentMana * 100 / me.nMaxMana)
		rage = math.floor(me.nCurrentRage * 100 / me.nMaxRage)
		sun = me.nSunPowerValue == 1
		moon = me.nMoonPowerValue == 1
		combat = me.bFightState
		nocombat = not me.bFightState
		channelling = me.GetOTActionState() == 2
		onhorse = me.bOnHorse
		kungfu = Core.GetCurrentKungfu()
		force = Core.GetCurrentForce()
		dispelabledebuff = Core.HaveDispelableDebuff(me)
		menemies = Core.GetEnemy(400, 360)
		renemies = Core.FindEnemiesNearTarget()
		stay = me.nMoveState == 1 or me.nMoveState == 7

		if target then
			tlife = math.floor(target.nCurrentLife * 100 / target.nMaxLife)		
			tmana = math.floor(target.nCurrentMana * 100 / target.nMaxMana)
			etarget = IsEnemy(me.dwID, target.dwID)
			tdistance = Core.Distance(me, target)
			tplayer = IsPlayer(target.dwID)
			tboss = target.nLevel >= 82
			dispelabledebuff = Core.HaveDispelableDebuff(target)
		else
			target = 0
			tdistance = 0
			tplayer = false
			etarget = false
			tlife = 0
			tmana = 0
			tboss = false
		end
	end
end

function Core.print(...)
        local a = {...}
        for i, v in ipairs(a) do
                a[i] = tostring(v)
        end
        OutputMessage("MSG_SYS", "[JX3Helper] " .. table.concat(a, "\t").. "\n" )
end

function Core.max(t, fn)
    if #t == 0 then return nil, nil end
    local key, value = 1, t[1]
    for i = 2, #t do
        if fn(value, t[i]) then
            key, value = i, t[i]
        end
    end
    return key, value
end

function Core.GetEnemy(nRadius, nAngle)
	local CharacterIDArray, count = GetClientPlayer().SearchForEnemy(nRadius, nAngle)
	return count
end

function Core.FindEnemiesNearTarget()
	local p = GetClientPlayer()
	local t = GetTargetHandle(p.GetTarget())
	local count = 0
	if not t then return count end
	local eIDs, ecount = p.SearchForEnemy(1280, 90)
	if ecount == 0 then return count end
	for _, v in pairs(eIDs) do
		if v ~= t.dwID then
			if IsPlayer(v) then
				local tt = GetPlayer(v)
			else
				local tt = GetNpc(v)
			end
			if not tt then return count end
			if Core.Distance(t, tt) <= 8 then
				count = count + 1
			end
		end
	end
	return count
end

function Core.HealAutoSelect()
	local partyLife = {}
	local charIDs, count = GetClientPlayer().SearchForAllies(1280, 360)
	local p = GetClientPlayer()
	if count == 0 then return end
	partyLife[p.dwID] = math.floor(p.nCurrentLife * 100 / p.nMaxLife)
	for _, v in pairs(charIDs) do
		if IsPlayer(v) then
			if JX3Helper.szHealSeclectOption.bPartyOnly then
				if p.IsPlayerInMyParty(v) then
					local t = GetPlayer(v)
					partyLife[v] = math.floor(t.nCurrentLife * 100 / t.nMaxLife)
				end
			end
			if JX3Helper.szHealSeclectOption.bWorld then
				local t = GetPlayer(v)
				partyLife[v] = math.floor(t.nCurrentLife * 100 / t.nMaxLife)
			end
		end
	end
	local pt = {}
	local count = 0
	for _, v in pairs(partyLife) do
		if v <= 95 then 
			table.insert(pt, v)
		end
		if v <= 70 then
			count = count + 1
		end
	end
	if next(pt) == nil then return end
	if count >= 4 then 
		needaoeheal = true
		return
	end
	needaoeheal = false
	table.sort(pt)
	for x,v in pairs(partyLife) do
		if v == pt[1] then
			SetTarget(TARGET.PLAYER, x)
		end
	end
end

function Core.Distance(p, t)
	if not t or not p then 
		return false
	end
	local nX1 = p.nX
	local nX2 = t.nX
	local nY1 = p.nY
	local nY2 = t.nY
	local strdis = tostring((((nX1 - nX2) ^ 2 + (nY1 - nY2) ^ 2) ^ 0.5)/64)
	return tonumber(string.format("%.1f",strdis))	
end

function Core.CheckCDs(skillName)
	local p = GetClientPlayer()
	local skillID = g_SkillNameToID[skillName]
	bOnCD,currentCDTime,totalCDTime = p.GetSkillCDProgress(skillID,p.GetSkillLevel(skillID)) 
	return currentCDTime/16 == 0
end

function Core.IsActiveBuff(buffName, t)
	if not t then return false end
	local buffList = t.GetBuffList()
	if buffList then
		for z,x in ipairs(buffList) do
			local name = Table_GetBuffName(x.dwID, x.nLevel)
			if buffName == name then
				return true
			end
		end
	end
	return false
end

function Core.HaveDispelableDebuff(t)
	if not t then return end
	local buffList = t.GetBuffList()
	if buffList then
		for z,x in ipairs(buffList) do
			if IsBuffDispel(x.dwID, x.nLevel) then
				return true
			end
		end
	end
	return false
end

function Core.Cast(skillName, condition)
	if condition and not bignorecast then
		local skillID = g_SkillNameToID[skillName]
		if(Core.CheckCDs(skillName)) then
			if not channelling then
				OnAddOnUseSkill(skillID)
				bignorecast = true
			end
		end
	end
end

function Core.Heal(skillName, condition)
	local skillID = g_SkillNameToID[skillName]
	if tlife == 0 then return end
	if condition and not bignorecast then
		if(Core.CheckCDs(skillName)) then
			if next(IgnoreChannelling) ~= nil then
				for _, v in pairs(IgnoreChannelling) do
					if v == skillName then
						OnAddOnUseSkill(skillID)
						bignorecast = true
						return
					end
				end
			end			
			if not channelling then
				OnAddOnUseSkill(skillID)
				bignorecast = true
			end
		end
	end
end

function Core.FaceToTarget()
	local player = GetClientPlayer()
	local target = GetTargetHandle(player.GetTarget())
	if not target then
		return
	end
	
	local RelX=target.nX-player.nX
	local RelY=target.nY-player.nY
	local CosPhy=RelX/((RelX^2+RelY^2)^0.5)
	local Phy
	if RelY<0 then
		Phy=6.28-math.acos(CosPhy)--
	else
		Phy=math.acos(CosPhy)
	end
	TurnTo(Phy*256/6.28)
end

function Core.FindTarget()
	if JX3Helper.bGrindBot then
		local p = GetClientPlayer()
		local t = GetTargetHandle(p.GetTarget())
		local lifePercent = p.nCurrentLife * 100 / p.nMaxLife
		local dwTargetType, dwTargetID = p.GetTarget()

		if dwTargetID == 0 then
			if lifePercent < 100 and not p.bFightState then
				if Core.IsActiveBuff(103, p) then return end
				OnAddOnUseSkill(17)
				return
			end
			local _, count = Core.GetAllMeleeEnemy()
			if count == 0 then
				SearchEnemy()
				t = GetTargetHandle(p.GetTarget())
				Core.FaceToTarget()
				if dwTargetID == 0 then
					Core.ReturnCheckPoint()
				end
			end
		end
		--if t.nLevel < 70 then dwTargetID = 0 return end
		--if Core.Distance(p, t) > 40 then dwTargetID = 0 return end
		dwTargetType, dwTargetID = p.GetTarget()
		if IsEnemy(p.dwID, dwTargetID) then
			AutoMoveToTarget(dwTargetType, dwTargetID)
			Core.FaceToTarget()
		end

	end
end

function Core.IsChannelling()
	return GetClientPlayer().GetOTActionState() == 2
end

function Core.ReturnCheckPoint()
	local p = GetClientPlayer()
	if p.nMoveState ~= 3 then
		AutoMoveToPoint(JX3Helper.gReturnCheckPoint.gnX, JX3Helper.gReturnCheckPoint.gnY, JX3Helper.gReturnCheckPoint.gnZ)
	end
end

function Core.GetCurrentKungfu()
	local p = GetClientPlayer()
	local k = p.GetKungfuMount()
	return Table_GetSkillName(k.dwSkillID)
end

function Core.GetCurrentForce()
	local p = GetClientPlayer()
	return GetForceTitle(p.dwForceID)
end