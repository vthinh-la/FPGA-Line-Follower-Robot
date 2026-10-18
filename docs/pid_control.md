# Giải Thuật Điều Khiển PID Dò Line Trên FPGA

Tài liệu phân tích chi tiết nguyên lý toán học và cấu trúc thực thi phần cứng của bộ điều khiển **PID (Tỉ lệ - Vi phân / PD)** được lập trình bằng Verilog HDL trên chip FPGA Gowin GW1NR-9C.

---

## 1. Tổng Quan Kiến Trúc Điều Khiển

Hệ thống điều khiển bám vạch tốc độ cao hoạt động theo chu kỳ chính xác **1,000 Hz (1.00 ms/chu kỳ)** được tạo ra từ xung nhịp 27 MHz bằng bộ đếm phần cứng:

$$\text{CTRL\_TICKS} = \frac{27\,000\,000\text{ Hz}}{1\,000\text{ Hz}} = 27\,000\text{ chu kỳ clock}$$

Cứ mỗi 1 ms, hệ thống thực hiện tuần tự 4 tác vụ:
1. Đọc và lọc tín hiệu số từ 8 cảm biến hồng ngoại.
2. Tính toán sai số vị trí theo phương pháp trọng tâm (Weighted Barycenter).
3. Tính toán lượng điều khiển bẻ lái theo khâu tỉ lệ P phân cấp kết hợp khâu vi phân D giảm chấn.
4. Trộn tín hiệu lái vào tốc độ cơ sở và kích hoạt phanh chủ động vi sai khi vào cua gắt.

---

## 2. Phương Pháp Tính Sai Số Trọng Tâm (Weighted Barycenter)

Thanh cảm biến gồm 8 mắt hồng ngoại được đánh số từ $S_1$ (ngoài cùng bên trái) đến $S_8$ (ngoài cùng bên phải). Trọng số vị trí đối xứng qua trục tâm xe:

$$W = [-7, -5, -3, -1, +1, +3, +5, +7]$$

Sai số tức thời được tính theo công thức trọng tâm:

$$\text{line\_error} = \frac{\sum_{i=1}^{8} (S_i \cdot W_i)}{\sum_{i=1}^{8} S_i}$$

- Khi đường line nằm ngay chính giữa ($S_4$ và $S_5$ cùng sáng): $\text{line\_error} = \frac{(-1) + (+1)}{2} = 0$.
- Khi xe lệch sang trái (vạch nằm lệch về bên phải, $S_7, S_8$ sáng): $\text{line\_error} > 0$.
- Khi xe lệch sang phải (vạch nằm lệch về bên trái, $S_1, S_2$ sáng): $\text{line\_error} < 0$.

### Bộ Lọc Sai Số Dịch Bit (Low-Pass Filter)
Khi xe chạy ở vùng ổn định (lệch nhẹ), sai số được đưa qua bộ lọc thông thấp số học để loại bỏ nhiễu rung quang học:

$$\text{line\_error\_ctrl}[k] = \text{line\_error\_ctrl}[k-1] + \frac{\text{line\_error} - \text{line\_error\_ctrl}[k-1]}{2^{\text{ERR\_FILTER\_SHIFT}}}$$

Ngược lại, khi xe chạm các cảm biến mép ngoài ($S_1, S_2, S_7, S_8$), bộ lọc được bỏ qua ngay lập tức để đáp ứng phản xạ nhanh nhất.

---

## 3. Khâu Tỉ Lệ Phân Cấp (Proportional Action - P)

Khác với khâu P tuyến tính thông thường dễ gây quá điều khiển ở góc cua hẹp, hệ thống sử dụng luật tỉ lệ phân cấp phi tuyến tính:

| Mức Độ Sai Số Lệch (`line_error_ctrl`) | Trạng Thái Xe | Lượng Bẻ Lái Cơ Sở (`steer_base`) |
| :---: | :--- | :--- |
| $\le -5$ | Lệch rất nhiều về bên phải (Vạch ở cực trái) | $+FZ\_STEER\_HARD$ ($35\%$ PWM) - Quặp lái gắt sang trái |
| $-4, -3$ | Lệch vừa về bên phải | $+FZ\_STEER\_MID$ ($10\%$ PWM) - Bẻ lái vừa sang trái |
| $-2, -1$ | Lệch nhẹ về bên phải | $+FZ\_STEER\_SOFT$ ($8\%$ PWM) - Nhích lái nhẹ sang trái |
| $0$ | Xe đi đúng tâm vạch | $0$ - Giữ thẳng lái |
| $+1, +2$ | Lệch nhẹ về bên trái | $-FZ\_STEER\_SOFT$ ($8\%$ PWM) - Nhích lái nhẹ sang phải |
| $+3, +4$ | Lệch vừa về bên trái | $-FZ\_STEER\_MID$ ($10\%$ PWM) - Bẻ lái vừa sang phải |
| $\ge +5$ | Lệch rất nhiều về bên trái (Vạch ở cực phải) | $-FZ\_STEER\_HARD$ ($35\%$ PWM) - Quặp lái gắt sang phải |

---

## 4. Khâu Vi Phân Giảm Chấn Động Học (Derivative Action - D)

Hiện tượng **văng đuôi (fishtailing)** xảy ra khi quán tính quay của thân xe đưa xe vượt quá tâm vạch sang phía đối diện, tạo thành chu kỳ lắc lư cộng hưởng ngày càng mạnh.

Khâu vi phân tính tốc độ biến thiên sai số trong mỗi chu kỳ 1 ms:

$$\Delta e = \text{line\_error\_ctrl}[k] - \text{pid\_prev\_error}[k-1]$$

Luật phản hồi vi phân chống văng đuôi:
- Nếu $\Delta e \ge +2$ (Xe đang văng dạt nhanh về bên phải):
  $$\text{damping\_output} = -FZ\_DAMPING\quad (14\%\text{ PWM})$$
  *(Tác dụng một mô-men xoắn ngược lại để ghìm chuyển động văng)*.
- Nếu $\Delta e \le -2$ (Xe đang văng dạt nhanh về bên trái):
  $$\text{damping\_output} = +FZ\_DAMPING\quad (14\%\text{ PWM})$$
- Nếu xe chuyển động êm ($|\Delta e| < 2$):
  $$\text{damping\_output} = 0$$

Tổng vector lái hợp thành:

$$\text{pid\_output} = \text{steer\_base} + \text{damping\_output}$$

---

## 5. Bộ Trộn Tốc Độ & Phanh Chủ Động Đảo Chiều Vi Sai

Tín hiệu điều khiển được phối hợp vào hai bánh xe:

$$\text{duty\_a\_calc} = \text{base\_duty} - \text{pid\_output\_drive}$$

$$\text{duty\_b\_calc} = \text{base\_duty} + \text{pid\_output\_drive}$$

### Kích Hoạt Phanh Đảo Chiều (Active Reverse Braking)
Khi vào cua gấp (`hard_corner` hoặc `pre_corner`), tốc độ cơ sở giảm xuống `DUTY_SLOW = 12%`, bánh ngoài cua được kích thêm xung lực `corner_boost = 10%`. 

Lúc này, bánh phía trong cua có giá trị duty tính toán bị âm:

$$\text{duty\_calc} < 0$$

Thay vì chỉ ngắt điện thả trôi bánh (free-wheeling), hệ thống phần cứng Verilog sẽ **đảo chiều cầu H** (`IN1 = dir_rev, IN2 = dir_fwd`) và phát xung ngược chiều với độ rộng bằng $|\text{duty\_calc}|$. Lực hãm chủ động này kéo ghì bánh trong cua xuống mặt đường, tạo tâm quay tức thời giúp xe bo gọn góc 90 độ ở tốc độ cao.

---

## 6. Chiến Lược Hồi Phục Khi Mất Line (`QUICK_RECOVER_ON_LOST`)

Khi xe văng khỏi vạch dẫn đến tất cả cảm biến đều không nhận vạch:
- Hệ thống dựa vào cờ lưu hướng `last_line_right` (ghi nhận vị trí vạch xuất hiện lần cuối cùng).
- Thay vì dừng 1 bánh khiến xe bị xoay vòng tại chỗ (spin out), thuật toán kích hoạt chạy cả hai bánh theo tỷ lệ vi sai: bánh ngoài chạy `DUTY_FAST = 60%`, bánh trong chạy chậm `DUTY_SLOW = 12%`.
- Điều này tạo quỹ đạo vòng cung uốn lượn mượt mà đưa mũi xe nhanh chóng bắt lại vạch line.
