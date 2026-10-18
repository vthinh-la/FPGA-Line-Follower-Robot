# Danh Mục Vật Tư Linh Kiện (BOM)

Bảng kê chi tiết các linh kiện, module và vật tư chế tạo Robot Dò Line Tốc Độ Cao điều khiển bằng FPGA.

| STT | Tên Linh Kiện / Module | Mã Linh Kiện / Model | Số Lượng | Thông Số / Đóng Gói | Chức Năng Chính |
| :---: | :--- | :--- | :---: | :--- | :--- |
| 1 | **Module FPGA Trung Tâm** | Sipeed Tang Nano 9K | 1 | Chip Gowin GW1NR-LV9QN88PC6/I5 (8640 LUT4, Clock 27MHz) | Xử lý thuật toán PID, PWM và phanh chủ động |
| 2 | **Driver Động Cơ Cầu H** | Toshiba TB6612FGN | 1 | Module chân cắm SSOP-24 (VM: 2.5-15V, dòng đỉnh 3.2A) | Dẫn động 2 động cơ DC độc lập |
| 3 | **Động Cơ DC Giảm Tốc** | Micro DC Geared Motor | 2 | Điện áp 6V - 12V, Tốc độ cao 1000 - 3000 RPM | Truyền động vi sai 2 bánh sau |
| 4 | **Mạch Hạ Áp DC-DC** | Mini360 Buck Converter | 1 | Siêu nhỏ gọn (Vin: 4.75-23V, Vout: 5.0V, dòng tải 1.8A) | Hạ áp xung từ pin LiPo 12V xuống 5V |
| 5 | **IC Ổn Áp Tuyến Tính** | AMS1117-3.3V / LT1117 | 2 | Đóng gói SOT-223 (3.3V, dòng tải 1A) | Cấp nguồn 3.3V sạch cho FPGA và logic I/O |
| 6 | **Thanh Cảm Biến Dò Line** | Mảng 8 Cảm Biến Hồng Ngoại | 1 | Bo mạch cong cánh cung (Dùng TCRT5000 / ITR9909) | Thu nhận độ tương phản đen/trắng mặt đường |
| 7 | **Mạch Tiền Xử Lý / ADC** | ATmega328P / ATmega8 | 1 | Đóng gói TQFP-32 (Tích hợp trên bo carrier) | Đọc analog cảm biến và xuất mức logic cho FPGA |
| 8 | **Diode Chống Ngược Cực** | 1N4007 | 1 | Đóng gói chân cắm DO-41 (1A, 1000V) | Bảo vệ toàn bộ hệ thống khi cắm nhầm cực pin |
| 9 | **Pin Nguồn Năng Lượng** | Pin LiPo 3S | 1 | 11.1V - 12.6V, dung lượng 450mAh - 850mAh, dòng xả 45C+ | Nguồn cung cấp toàn bộ xe |
| 10 | **Tụ Điện Lọc Nguồn** | Tụ gốm SMD và Tụ hóa | 4 | 100nF, 1uF, 10uF, 100uF | Lọc nhiễu cao tần và sụt áp khi khởi động motor |
| 11 | **Công Tắc Bật Tắt** | Công tắc gạt cơ khí | 1 | Chịu dòng 3A+ | Bật tắt nguồn tổng của xe |
| 12 | **Bánh Xe Đa Hướng Trước** | Bi cầu kim loại (Ball Caster) | 1 | Đường kính bi 8 mm - 12 mm | Điểm tựa trượt dẫn hướng phía mũi xe |
| 13 | **Bánh Xe và Khớp Nối** | Bánh bọc cao su Silicon | 2 | Khớp nối trục nhôm D-shaft đường kính bánh 42 mm | Bám đường chống trượt quán tính khi bo cua |
| 14 | **Khung Xe Cơ Khí** | Khung xe Delta in 3D | 1 | Nhựa in PLA+ hoặc PETG (`mechanical/3d_models/chassis_frame.stl`) | Khung gầm chịu lực và liên kết toàn bộ xe |
