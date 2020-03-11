JX3Helper = {
	bOn = true,
	bAutoRotation = false,
	nFrame = 0,
	bGrindBot = false,
	bHealAutoSelect = false,
	gReturnCheckPoint = {
		gnX = 0,
		gnY = 0,
		gnZ = 0,
	},
	szLastKungfu = "",
	szHealSeclectOption = {
		bPartyOnly = true;
		bWorld = false;
	},
}

function JX3Helper.OnFrameBreathe()
	Core.UpdateVars()
	--print("loop")
	--Core.Cast("Vũ Lâm Linh", true)
	if JX3Helper.nFrame > GetLogicFrameCount() then
		return
	end
	--print("loop")

	if JX3Helper.bAutoRotation then	
		if force == "Minh Giáo" then
			Rotation.MinhGiao()
		elseif force == "Thất Tú" then
			Rotation.ThatTu()
		elseif force == "Đường Môn" then
			Rotation.DuongMon()
		elseif force == "Ngũ Độc" then
			Rotation.NguDoc()
		elseif force == "Thiếu Lâm" then
			Rotation.ThieuLam()
		elseif force == "Thiên Sách" then
			Rotation.ThienSach()
		elseif force == "Vạn Hoa" then
			Rotation.VanHoa()
		elseif force == "Thuần Dương" then
			Rotation.ThuanDuong()
		elseif force == "Tàng Kiếm" then
			Rotation.TangKiem()
		end
		if Core.GetCurrentKungfu() ~= JX3Helper.szLastKungfu then
			Core.print("Kungfu changed to " .. Core.GetCurrentKungfu())
			JX3Helper.szLastKungfu = Core.GetCurrentKungfu()
		end
	end

	if JX3Helper.bGrindBot then
		needtarget()
	end

	JX3Helper.nFrame = GetLogicFrameCount()+1
end

JX3Helper.GetMenuList = function()
	local submenu={
		szOption = "JX3Helper",
		{
			szOption = "Auto Rotation",
			bCheck = true,
			bChecked = JX3Helper.bAutoRotation,
			fnAction = function(UserData, bCheck)
				JX3Helper.bAutoRotation = not JX3Helper.bAutoRotation
			end
		},
		{
			szOption = "Heal Bot",
			{
				szOption = "Start",
				bCheck = true,
				bChecked = JX3Helper.bHealAutoSelect,
				fnAction = function(UserData, bCheck)
					JX3Helper.bHealAutoSelect = not JX3Helper.bHealAutoSelect
				end
			},
			{
				szOption = "Options",
				{
					szOption = "Party Only",
					bCheck = true,
					bChecked = JX3Helper.szHealSeclectOption.bPartyOnly,
					fnAction = function(UserData, bCheck)
						JX3Helper.szHealSeclectOption.bPartyOnly = not JX3Helper.szHealSeclectOption.bPartyOnly
					end
				},
				{
					szOption = "World",
					bCheck = true,
					bChecked = JX3Helper.szHealSeclectOption.bWorld,
					fnAction = function(UserData, bCheck)
						JX3Helper.szHealSeclectOption.bWorld = not JX3Helper.szHealSeclectOption.bWorld
					end
				},
			},
		},
		{
			szOption = "Grind Bot",
			bCheck = true,
			bChecked = JX3Helper.bGrindBot,
			fnAction = function(UserData, bCheck)
				JX3Helper.bGrindBot = not JX3Helper.bGrindBot
			end
		},			
	}
	return submenu
end

RegisterEvent("LOGIN_GAME", function()
	local tMenu = {
		function()
			return {JX3Helper.GetMenuList()}
		end,
	}
	Player_AppendAddonMenu(tMenu)
end)

JX3Helper.nFrame = GetLogicFrameCount()+1
Wnd.OpenWindow("interface/JX3Helper/JX3Helper.ini", "JX3Helper")