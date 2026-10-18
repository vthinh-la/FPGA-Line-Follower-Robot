# Quy Trình Căn Chỉnh & Tinh Chỉnh Thông Số Trên Sa Hình

Hướng dẫn chi tiết cách căn chỉnh cảm biến quang học, bù sai lệch tốc độ hai motor và hiệu chỉnh thông số điều khiển PID cho xe thi đấu.

---

## 1. Căn Chỉnh Cảm Biến Quang Học

1. **Khoảng Cách Mặt Sàn**: Đảm bảo khoảng cách từ thanh cảm biến tới mặt sàn nằm trong khoảng **3 mm - 5 mm**. Nếu quá cao, độ tương phản quang học sẽ yếu; nếu quá sát đất, xe dễ bị chạm gầm khi qua các mối nối bạt sân thi đấu.
2. **Kiểm Tra Ngưỡng Tín Hiệu**:
   - Đặt xe lên nền bạt trắng: Đèn LED báo trên bo mạch cảm biến phải tắt (hoặc bật tùy theo mức tích cực).
   - Đặt từng mắt cảm biến lên vạch đen: Đèn LED phải chuyển trạng thái rõ ràng, dứt khoát.
   - Nếu dùng mạch tiền xử lý ATmega, nhấn nút nhấn `Kali` trên bo mạch để mạch tự động lưu ngưỡng trắng/đen vào bộ nhớ EEPROM.

---

## 2. Bù Sai Lệch Tốc Độ Giữa Hai Động Cơ (Motor Trim Gain)

Do dung sai chế tạo cơ khí và lực ma sát hộp số, hai động cơ DC khi cấp cùng mức PWM sẽ có tốc độ quay chênh lệch nhẹ. Mã nguồn Verilog cung cấp sẵn hai thông số bù tỉ lệ phần trăm tại [`firmware/gowin_fpga/src/main.v`](../firmware/gowin_fpga/src/main.v#L15-L16):

```verilog
parameter integer GAIN_PWMA_PCT = 98;  // Bù công suất Bánh Trái (Phần trăm %)
parameter integer GAIN_PWMB_PCT = 100; // Bù công suất Bánh Phải (Phần trăm %)
```

- Nếu xe chạy trên đường thẳng có xu hướng nhao về bên Phải: Giảm `GAIN_PWMB_PCT` hoặc tăng `GAIN_PWMA_PCT`.
- Nếu xe chạy trên đường thẳng có xu hướng nhao về bên Trái: Giảm `GAIN_PWMA_PCT` hoặc tăng `GAIN_PWMB_PCT`.

---

## 3. Tinh Chỉnh Thông Số PID Khi Chạy Đua Tốc Độ Cao

Các tham số chính trong file `main.v` cần hiệu chỉnh theo từng loại sa hình:

| Tham số trong `main.v` | Giá trị mặc định | Ý nghĩa chức năng | Hướng dẫn tinh chỉnh |
| :--- | :---: | :--- | :--- |
| `DUTY_FAST` | 60% | Tốc độ chạy tuần tra trên cung cua thường | Tăng lên để cải thiện thời gian hoàn thành vòng đua |
| `DUTY_STRAIGHT` | 60% | Tốc độ tối đa khi phát hiện đường thẳng | Có thể nâng lên 80% - 90% nếu sa hình có đoạn thẳng dài |
| `DUTY_SLOW` | 12% | Tốc độ hãm khi vào cua gấp (gặp mắt ngoài) | Tăng nhẹ nếu xe bị khựng đứng; giảm nếu xe bị trượt văng khỏi cua |
| `FZ_STEER_HARD` | 35% | Lực bẻ lái tối đa của khâu P | Tăng lên nếu xe không kịp quẹo qua các góc vuông 90 độ |
| `FZ_DAMPING` | 14% | Lực hãm vi phân D chống văng lắc đuôi xe | Tăng lên nếu xe bị lắc lư hình sin (fishtailing) trên đường thẳng |
| `STRAIGHT_COUNT_GO` | 52 | Số chu kỳ ổn định cần thiết trước khi boost ga | Giảm xuống nếu muốn xe tăng tốc sớm hơn khi vừa thoát cua |
