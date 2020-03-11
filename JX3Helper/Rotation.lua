Rotation = {}

function Rotation.Check()
	Core.print("Ngon rồi")
end

function Rotation.MinhGiao()
	if not etarget then return end
	--if not combat then return end
	
	Core.Cast("Xuống Ngựa", onhorse)
				
	if kungfu == "Minh Tôn Lưu Ly Thể" then
		Core.Cast("Ảo Quang Bộ", tdistance >= 10 and tdistance <= 20)
		Core.Cast("Lực Độ Ách", life < 50)
		Core.Cast("Tính Mệnh Hải", life < 40)
		Core.Cast("Đốc Mạch-Bách Hội", life < 40)
		Core.Cast("Quang Minh Tướng", (moon or sun) and (tplayer or tboss))
		Core.Cast("Thánh Minh Hựu", life < 60 and (moon or sun))
		Core.Cast("Triều Thánh Ngôn", life < 30)
		Core.Cast("Xung Mạch-Quan Môn", (moon or sun) and (tplayer or tboss))
		Core.Cast("Sinh Tử Kiếp", sun and tplayer)
		Core.Cast("Tịnh Thế Phá Ma Kích", moon or sun)
		Core.Cast("Hoàng Nhật Chiếu", nobuff("Chiết Xung") and tdistance <= 4)
		Core.Cast("Hàn Nguyệt Diệu", nobuff("Chiết Xung") and tdistance <= 4) 
		Core.Cast("Giới Hỏa Trảm", tnobuff("Giới Hỏa"))
		Core.Cast("Quy Tịch Đạo", true)
		Core.Cast("Liệt Nhật Trảm", tnobuff("Tịch Dương"))
		Core.Cast("Ngân Nguyệt Trảm", tnobuff("Ngân Nguyệt Trảm"))
		Core.Cast("Xích Nhật Luân", renemies >= 2)
		Core.Cast("U Nguyệt Luân", renemies <= 1)
	end

	if kungfu == "Phần Ảnh Thánh Quyết" then
		--print("fighting")
		Core.Cast("Sinh Diệt Dư Đoạt", tplayer or tboss)
		Core.Cast("Ám Trần Di Tán", nobuff("Ám Trần Di Tán") and nocombat)
		Core.Cast("Lưu Quang Tù Ảnh", tdistance >= 8)
		Core.Cast("Khu Dạ Đoạn Sầu", buff("Ám Trần Di Tán"))
		Core.Cast("Xung Mạch-Quang Môn", (moon or sun) and (tplayer or tboss))
		Core.Cast("Quang Minh Tướng", (moon or sun) and (tplayer or tboss))
		Core.Cast("Thánh Minh Hựu", life < 60 and sun)
		Core.Cast("Tịnh Thế Phá Ma Kích", moon or sun)
		Core.Cast("Sinh Tử Kiếp", sun and tplayer)
		Core.Cast("Xung Mạch-U Môn", nocd("Quang Minh Tướng"))
		Core.Cast("Nghiệp Hải Tội Phọc", tplayer)
		Core.Cast("Bố Úy Ám Hình", tlife < 80)
		Core.Cast("Liệt Nhật Trảm", tnobuff("Tịch Dương"))
		Core.Cast("Ngân Nguyệt Trảm", tnobuff("Ngân Nguyệt Trảm"))
		Core.Cast("Hoàng Nhật Chiếu", menemies >= 3)
		Core.Cast("Hàn Nguyệt Diệu", menemies >= 3) 
		Core.Cast("Xích Nhật Luân", menemies >= 2)
		Core.Cast("U Nguyệt Luân", menemies < 2)
	end
end

function Rotation.ThatTu()
	Core.Cast("Bà La Môn", nobuff("Tụ Khí"))
	Core.Cast("Danh Động Tứ Phương", nobuff("Kiếm Vũ") and stay)
	if kungfu == "Băng Tâm Quyết" then
		if nocombat then return end
		if not etarget then return end
		Core.Cast("Phồn Âm Cấp Tiết", tplayer or tboss)
		Core.Cast("Kiếm Thần Vô Ngã", tdistance <= 10 and nobuff("Kiếm Thần Vô Ngã"))
		Core.Cast("Kiếm Khí Trường Giang", dance >= 3)
		Core.Cast("Kiếm Phá Hư Không", dance == 10 and renemies >= 3)
		Core.Cast("Danh Kiếm Vô Địch", dance <= 8)
		Core.Cast("Kiếm Linh Hoàn Vũ", renemies >= 3)
		Core.Cast("Mãn Đường Thế", dance <= 5 and tboss)
		Core.Cast("Long Trì Nhạc", tboss)
		Core.Cast("Đại Huyền Cấp Khúc", true)
		Core.Cast("Thiên Địa Đê Ngang", life < 65)
		Core.Cast("Thước Đạp Chi", life < 30)
	end

	if kungfu == "Vân Thường Tâm Kinh" then
		IgnoreChannelling = {"Phong Tụ Đê Ngang", "Vương Mẫu Huy Duệ", "Linh Lung Không Hầu", "Khiêu Châu Hám Ngọc"}
		Core.Cast("Long Trì Nhạc", mana < 80)

		if JX3Helper.bHealAutoSelect then
			Core.HealAutoSelect()
		end

		if not tplayer then return end
		if etarget then return end

		Core.Heal("Tả Hoàn Hữu Chuyển", needaoeheal)
		Core.Heal("Khiêu Châu Hám Ngọc", dispelabledebuff)
		Core.Heal("Vũ Lâm Linh", nobuff("Vũ Lâm Linh") and tlife < 40)
		Core.Heal("Phong Tụ Đê Ngang", tlife <= 30)
		Core.Heal("Linh Lung Không Hầu", tlife <= 30 and cd("Phong Tụ Đê Ngang"))
		Core.Heal("Vương Mẫu Huy Duệ", tlife <= 50)
		Core.Heal("Tường Loan Vũ Liễu", tlife <= 90 and tnobuff("Bay Lượn")) 
		Core.Heal("Thượng Nguyên Điểm Hoàn", tlife <= 85 and tnobuff("Thượng Nguyên Điểm Hoàn"))
		Core.Heal("Hồi Tuyết Phiêu Dao", tlife <= 80)	
		Core.Cast("Thiên Địa Đê Ngang", life <= 65)
		Core.Cast("Thước Đạp Chi", life <= 30)
	end
end

function Rotation.DuongMon()
	if kungfu == "Kinh Vũ Quyết" then
		Core.print("Chưa code")
	end
	if kungfu == "Thiên La Ngụy Đạo" then
		Core.print("Chưa code")
	end	
end

function Rotation.NguDoc()
	if kungfu == "Bổ Thiên Quyết" then
		Core.print("Chưa code")
	end
	if kungfu == "Độc Kinh" then
		Core.print("Chưa code")
	end	
end

function Rotation.ThieuLam()
	if kungfu == "Dịch Cân Kinh" then
		Core.print("Chưa code")
	end
	if kungfu == "Tẩy Tủy Kinh" then
		Core.print("Chưa code")
	end	
end

function Rotation.ThienSach()
	if kungfu == "Thiết Lao Luật" then
		Core.print("Chưa code")
	end
	if kungfu == "Ngạo Huyết Chiến Ý" then
		Core.print("Chưa code")
	end	
end

function Rotation.VanHoa()
	if kungfu == "Hoa Gian Du" then
		Core.print("Chưa code")
	end
	if kungfu == "Ly Kinh Dịch Đạo" then
		Core.print("Chưa code")
	end	
end

function Rotation.ThuanDuong()
	if kungfu == "Thái Hư Kiếm Ý" then
		Core.print("Chưa code")
	end
	if kungfu == "Tử Hà Công" then
		Core.print("Chưa code")
	end	
end

function Rotation.TangKiem()
	if kungfu == "Vấn Thủy Quyết" then
		Core.print("Chưa code")
	end
	if kungfu == "Sơn Cư Kiếm Ý" then
		Core.print("Chưa code")
	end	
end
