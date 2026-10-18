# Hướng Dẫn In 3D & Lắp Ráp Cơ Điện

Tài liệu hướng dẫn quy trình in 3D khung xe, lắp ráp cơ khí và hàn nối hệ thống điện tử cho Robot Dò Line FPGA.

---

## 1. Thông Số Cài Đặt Khi In 3D

File mô hình 3D khung xe: [`mechanical/3d_models/chassis_frame.stl`](../mechanical/3d_models/chassis_frame.stl).

| Thông số cài đặt | Giá trị khuyến nghị | Lưu ý kỹ thuật |
| :--- | :--- | :--- |
| **Vật liệu in** | PLA+ hoặc PETG | PETG cho độ bền cơ học cao, chống nứt gãy khi va chạm mạnh |
| **Độ cao lớp in (Layer Height)** | 0.20 mm | Cân bằng giữa tốc độ in và độ bóng bề mặt |
| **Mật độ điền đầy (Infill Density)** | 40% - 50% | Khung cần độ cứng vững cao để chống vặn xoắn khi tăng tốc |
| **Kiểu điền đầy (Infill Pattern)** | Gyroid hoặc Honeycomb | Chịu lực va đập đa hướng |
| **Số lớp thành (Wall Perimeters)** | 4 lớp (1.6 mm) | Tăng cường độ chịu lực tại vị trí hốc kẹp động cơ |
| **Lớp mặt trên / dưới** | 4 lớp / 4 lớp | Chống thủng đáy khi siết ốc cố định pin LiPo |
| **Support (Vật liệu đỡ)** | Bật Tree Support tại gá motor | Bóc tách cẩn thận sau khi hoàn tất |

---

## 2. Trình Tự Lắp Ráp Xe

### Bước 1: Lắp Bi Cầu Dẫn Hướng Phía Trước
1. Ép chặt cụm bi cầu kim loại vào hốc tròn ở mặt dưới mũi xe.
2. Kiểm tra bằng tay đảm bảo bi xoay nhẹ nhàng 360 độ, không bị kẹt ba via nhựa.

### Bước 2: Lắp Động Cơ và Bánh Xe
1. Luồn hai động cơ DC Micro vào hai rãnh giữ ở phía đuôi xe.
2. Cố định bằng vít M2 và gá kẹp chắc chắn.
3. Lắp khớp nối nhôm D-shaft vào trục động cơ, siết ốc chìm lục giác.
4. Gắn vành bánh và lốp cao su silicon vào trục nhôm.

### Bước 3: Lắp Bo Mạch Chủ và Module Tang Nano 9K
1. Gắn bo mạch carrier lên các trụ đỡ trên thân xe bằng vít nhựa nylon M2.5.
2. Cắm module Sipeed Tang Nano 9K vào hàng rào cái (header), hướng cổng nạp USB-C lên trên để tiện cắm dây nạp code.
3. Cắm module driver TB6612FGN vào socket tương ứng và siết dây động cơ vào cọc đấu nối vít.

### Bước 4: Lắp Thanh Cảm Biến 8 Mắt Hồng Ngoại
1. Bắt vít cố định thanh cảm biến dạng cánh cung vào gá đỡ phía trước mũi xe.
2. Căn chỉnh khoảng cách: Khoảng cách từ mặt dưới cảm biến tới mặt sàn sa hình phải đạt từ **3 mm đến 5 mm**.
3. Cắm cáp dẹp 10 sợi nối từ thanh cảm biến về cọc `J1` trên bo mạch chủ.

### Bước 5: Cố Định Pin và Kiểm Tra Nguồn Điện
1. Đặt pin LiPo 3S vào khoang chứa pin ở trung tâm thân xe, siết dây đai dán velcro cố định.
2. Đảm bảo công tắc nguồn đang ở vị trí **TẮT (OFF)** trước khi cắm jack pin XT30.
