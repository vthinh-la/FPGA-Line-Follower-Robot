# Kiến Trúc Hệ Thống & Luồng Dữ Liệu Phần Cứng

Tài liệu mô tả chi tiết kiến trúc phần cứng điện tử và luồng thực thi trong FPGA của Robot Dò Line Tốc Độ Cao.

---

## 1. Sơ Đồ Kiến Trúc Toàn Hệ Thống

```mermaid
flowchart TD
    subgraph PowerSystem["Hệ Thống Phân Phối Nguồn Điện"]
        BAT["Pin LiPo 3S (11.1V - 12.6V)"] --> SW["Công Tắc Nguồn và Diode 1N4007"]
        SW --> VM["Đường Nguồn Động Cơ VM (11.1V)"]
        SW --> BUCK["Mạch Giảm Áp Mini360 DC-DC (5.0V)"]
        BUCK --> LDO["IC Ổn Áp Tuyến Tính AMS1117-3.3V"]
        LDO --> VCC_FPGA["Nguồn Logic 3.3V Cấp Cho FPGA và I/O"]
    end

    subgraph SensorFrontEnd["Hệ Thống Cảm Biến Dò Vạch"]
        IR["Thanh 8 Cảm Biến Hồng Ngoại (S1..S8)"] --> ADC["Mạch Tiền Xử Lý Quang"]
        ADC -->|"Bus Tín Hiệu 8-bit Số"| FPGA_IN["Chân I/O FPGA (Pins 25-28, 36-39)"]
    end

    subgraph FPGACore["Khối Xử Lý Trung Tâm FPGA Sipeed Tang Nano 9K"]
        CLK["Thạch Anh Tích Hợp 27 MHz"] --> DIV["Bộ Tạo Chu Kỳ Điều Khiển 1 kHz (1 ms)"]
        FPGA_IN --> BARY["Khối Tính Trọng Tâm Sai Số Lệch Line"]
        BARY --> PID["Khối Tính Toán Sai Số Tỉ Lệ P"]
        DIV --> PID
        PID --> DAMP["Khối Vi Phân D Giảm Chấn Quán Tính"]
        DAMP --> STEER["Bộ Hợp Nhất Vector Lái"]
        STEER --> MIXER["Bộ Trộn Tốc Độ và Phanh Đảo Chiều Vi Sai"]
        CLK --> PWM_A["Bộ Tạo Xung PWM 20 kHz Kênh A (Bánh Trái)"]
        CLK --> PWM_B["Bộ Tạo Xung PWM 20 kHz Kênh B (Bánh Phải)"]
        MIXER --> PWM_A
        MIXER --> PWM_B
    end

    subgraph MotorSubsystem["Hệ Thống Chấp Hành Động Cơ"]
        PWM_A -->|"PWMA, IN1, IN2"| TB["Driver Cầu H Toshiba TB6612FGN"]
        PWM_B -->|"PWMB, IN3, IN4"| TB
        VM --> TB
        TB -->|"Kênh A"| MOT_L["Động Cơ DC Bánh Trái"]
        TB -->|"Kênh B"| MOT_R["Động Cơ DC Bánh Phải"]
    end
```

---

## 2. Thông Số Tài Nguyên RTL Trên FPGA

- **Dòng chip FPGA**: Gowin Semiconductor GW1NR-LV9QN88PC6/I5 (Tang Nano 9K).
- **Tần số xung nhịp chính**: 27.000 MHz (Clock period: 37.037 ns).
- **Tần số sóng mang PWM**: 20.000 kHz (Chu kỳ: 1,350 chu kỳ clock tại 27 MHz).
- **Tần số vòng lặp điều khiển PID**: 1,000 Hz (Cập nhật góc lái và ga mỗi 1.00 ms).
- **Tài nguyên logic sử dụng**: ~600 LUT4 (< 7% tổng số 8,640 LUT của chip).
- **Điện áp chân I/O**: Chuẩn LVCMOS 3.3V với điện trở kéo lên nội (PULL_UP).
