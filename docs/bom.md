# Danh Mục Vật Tư Linh Kiện (BOM)

Bảng kê chi tiết các linh kiện, module và vật tư chế tạo **Robot Dò Line Tốc Độ Cao Điều Khiển Bằng FPGA**, đối soát khớp 100% với Sơ đồ nguyên lý [`hardware/schematics/Schematic_FPGA.png`](../hardware/schematics/Schematic_FPGA.png) và mặt bằng linh kiện [`hardware/pcb/PCB_Layout.png`](../hardware/pcb/PCB_Layout.png).

---

## 1. Bảng Linh Kiện Điện Tử Trên Bo Mạch Chủ (Carrier Board)

| Ký Hiệu Sơ Đồ | Tên Linh Kiện / Module | Mã Linh Kiện / Model | Số Lượng | Đóng Gói / Thông Số | Chức Năng Kỹ Thuật |
| :---: | :--- | :--- | :---: | :--- | :--- |
| **U2** | **Module FPGA Trung Tâm** | Sipeed Tang Nano 9K | 1 | Chip Gowin GW1NR-LV9QN88PC6/I5 (8,640 LUT4, Clock 27 MHz) | Xử lý thuật toán PID phân cấp, tạo xung PWM 20kHz và phanh chủ động |
| **U3** | **Driver Động Cơ Cầu H** | Toshiba TB6612FGN-R | 1 | SSOP-24 (VM: 2.5V - 15V, dòng liên tục 1.2A, đỉnh 3.2A) | Dẫn động công suất vi sai cho 2 động cơ DC độc lập |
| **U1** | **Vi Điều Khiển Đọc ADC** | ATmega328P / ATmega8 | 1 | TQFP-32 (Thạch anh nội hoặc ngoại) | Đọc tín hiệu analog từ thanh cảm biến 8 kênh và số hóa ngưỡng xuất sang FPGA qua J3 |
| **U4** | **Module Hạ Áp DC-DC** | Mini360 DLA MNIE | 1 | Module Buck siêu nhỏ (Vin: 4.75V - 23V, Vout: 5.0V, dòng tải 1.8A) | Hạ áp hiệu suất cao từ pin LiPo 12V xuống đường nguồn 5V |
| **U5, U6** | **IC Ổn Áp Tuyến Tính** | AMS1117-3.3V / LT1117 | 2 | SOT-223 (Điện áp ra 3.3V, dòng tải cực đại 1.0A) | Cấp nguồn 3.3V ổn định, độ gợn thấp cho lõi và chân I/O FPGA |
| **D2** | **Diode Chống Ngược Cực** | 1N4007 | 1 | DO-41 (Dòng thuận 1A, điện áp ngược cực đại 1000V) | Bảo vệ an toàn chống cắm nhầm cực tính pin LiPo |
| **C1, C6** | **Tụ Gốm Lọc Nguồn** | Tụ gốm nhiều lớp (MLCC) | 2 | 1 uF (Chịu áp 25V) | Lọc nguồn vào / ra của IC ổn áp |
| **C2, C5** | **Tụ Gốm Thoát Nhiễu** | Tụ gốm SMD | 2 | 0.1 uF (100 nF) | Thoát nhiễu xung cao tần cho các đường nguồn VCC |
| **C3, C4** | **Tụ Hóa Ổn Định Nguồn** | Tụ điện phân nhôm | 2 | 10 uF (Chịu áp 25V - 35V) | Chống sụt áp tức thời khi động cơ đảo chiều đột ngột |
| **R1** | **Mạng Trở Kéo Lên** | Trở băng SIP / SMD | 1 | 10 kΩ x 8 (Kéo lên VCC cho đường dữ liệu J3) | Định mức logic ổn định cho 8 đường tín hiệu số `s1` - `s8` |
| **R10** | **Điện Trở Hạn Dòng** | Điện trở cố định | 1 | 1 kΩ (Chuẩn SMD/chân cắm 1/8W) | Hạn dòng cấp cho LED báo trạng thái tại chân PB0 của U1 |
| **J1** | **Cọc Cắm Cảm Biến** | HDR-M-2.54_2x5 | 1 | Header 10 chân đực góc thẳng (Khoảng cách chân 2.54 mm) | Cắm cáp dẹp 10 sợi nối tới thanh cảm biến hồng ngoại 8 kênh |
| **J2** | **Cổng Nạp Firmware ISP** | HDR-M-2.54_1x4 | 1 | Header 4 chân đực (RST, MOSI, MISO, SCK) | Cổng nạp chương trình nạp bootloader/code cho vi điều khiển U1 |
| **J3** | **Cầu Nối Tín Hiệu Số** | HDR-M-2.54_1x9 | 1 | Header 9 chân (8 đường sensor + 1 đường GND) | Chuyển tiếp tín hiệu số từ vi điều khiển U1 sang các chân I/O của FPGA U2 |
| **POWER** | **Cọc Đấu Nguồn Pin** | Domino 2 chân (Terminal Block) | 1 | Bước chân 5.08 mm (Chịu dòng 10A) | Nối dây nguồn từ Pin LiPo 3S (+12V và GND) |
| **MT1, MT2** | **Cọc Đấu Động Cơ** | Domino 2 chân (Terminal Block) | 2 | Bước chân 5.08 mm (Chịu dòng 10A) | Đấu nối 2 dây động cơ bánh trái (MT1) và bánh phải (MT2) |
| **Kali** | **Nút Nhấn Cân Chỉnh** | Nút nhấn cơ khí 4 chân | 1 | Nút nhấn Tact Switch 6x6 mm | Kích hoạt chu trình cân chỉnh tự động ngưỡng sáng/tối |

---

## 2. Danh Mục Vật Tư Cơ Khí & Ngoại Vi

| STT | Tên Vật Tư / Bộ Phận | Thông Số Chi Tiết | Số Lượng | Chức Năng |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **Khung Xe Khí Động Học** | File STL in 3D: [`chassis_frame.stl`](../mechanical/3d_models/chassis_frame.stl) | 1 | Nhựa in PLA+/PETG, mật độ 40-50%, chịu lực cho toàn bộ thân xe |
| 2 | **Động Cơ DC Micro** | DC Geared Motor 6V - 12V (Tốc độ 1,500 - 3,000 RPM) | 2 | Động cơ tốc độ cao truyền động trực tiếp tới 2 bánh sau |
| 3 | **Bánh Xe Cao Su Silicon** | Đường kính 42 mm, bề rộng lốp 22 mm, bọc silicon đúc | 2 | Lốp mềm siêu bám đường, chống trượt văng khi bo cua gắt |
| 4 | **Khớp Nối Trục Nhôm** | Khớp nối D-shaft hợp kim nhôm định hình siết ốc chìm | 2 | Truyền mô-men xoắn trực tiếp từ trục động cơ sang bánh xe |
| 5 | **Bi Cầu Đa Hướng (Ball Caster)** | Bi kim loại dẫn hướng xoay 360 độ (Đường kính 8 - 12 mm) | 1 | Điểm tựa trượt ma sát thấp ở đầu mũi xe |
| 6 | **Thanh Cảm Biến Hồng Ngoại** | Mạch in cánh cung cong gắn 8 cặp diode thu-phát IR | 1 | Thu nhận độ phản xạ của vạch đen trên nền trắng |
| 7 | **Pin Nguồn Năng Lượng** | Pin LiPo 3S (11.1V - 12.6V, dung lượng 450 - 850 mAh, dòng xả 45C+) | 1 | Cung cấp nguồn dòng xả tức thời lớn cho xe |
| 8 | **Công Tắc Nguồn Tổng** | Công tắc gạt kim loại chịu dòng 3A+ | 1 | Đóng cắt nguồn chính an toàn |
| 9 | **Dây Cáp & Ốc Vít Lắp Ráp** | Cáp dẹp 10 sợi, ốc vít M2, M2.5, M3 và trụ đồng | 1 bộ | Liên kết cơ khí và đấu nối điện |
