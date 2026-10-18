# Bảng Tra Chân Kết Nối & Sơ Đồ Đấu Dây

Tài liệu định nghĩa chi tiết ánh xạ chân vật lý giữa **Sipeed Tang Nano 9K (Gowin GW1NR-9C)**, **Driver Động Cơ TB6612FGN**, **Thanh 8 Cảm Biến Hồng Ngoại** và **Hệ Thống Nguồn**.

---

## 1. Bảng Ánh Xạ Chân FPGA (File CST)

Các chân vật lý được khai báo trong file [`firmware/gowin_fpga/src/FPGA_DO_LINE.cst`](../firmware/gowin_fpga/src/FPGA_DO_LINE.cst):

| Tín Hiệu Trong RTL | Chân FPGA (GW1NR-9) | Chuẩn I/O | Kéo Lên | Dòng Lái | Thiết Bị Ngoại Vi | Chức Năng |
| :--- | :---: | :--- | :--- | :---: | :--- | :--- |
| `sys_clk` | **52** | LVCMOS33 | PULL_UP | - | Thạch anh bo mạch | Nguồn xung nhịp hệ thống 27 MHz |
| `s1` | **38** | LVCMOS33 | PULL_UP | - | Cảm biến 1 | Mắt ngoài cùng bên Trái |
| `s2` | **37** | LVCMOS33 | PULL_UP | - | Cảm biến 2 | Mắt lửng ngoài bên Trái |
| `s3` | **36** | LVCMOS33 | PULL_UP | - | Cảm biến 3 | Mắt giữa bên Trái |
| `s4` | **39** | LVCMOS33 | PULL_UP | - | Cảm biến 4 | Mắt tâm bên Trái |
| `s5` | **25** | LVCMOS33 | PULL_UP | - | Cảm biến 5 | Mắt tâm bên Phải |
| `s6` | **26** | LVCMOS33 | PULL_UP | - | Cảm biến 6 | Mắt giữa bên Phải |
| `s7` | **27** | LVCMOS33 | PULL_UP | - | Cảm biến 7 | Mắt lửng ngoài bên Phải |
| `s8` | **28** | LVCMOS33 | PULL_UP | - | Cảm biến 8 | Mắt ngoài cùng bên Phải |
| `PWMA` | **33** | LVCMOS33 | PULL_UP | 8 mA | TB6612FGN `PWMA` | Điều tốc PWM 20kHz Bánh Trái |
| `IN1` | **34** | LVCMOS33 | PULL_UP | 8 mA | TB6612FGN `AIN2` | Điều khiển chiều Bánh Trái Bit 1 |
| `IN2` | **40** | LVCMOS33 | PULL_UP | 8 mA | TB6612FGN `AIN1` | Điều khiển chiều Bánh Trái Bit 2 |
| `PWMB` | **35** | LVCMOS33 | PULL_UP | 8 mA | TB6612FGN `PWMB` | Điều tốc PWM 20kHz Bánh Phải |
| `IN3` | **42** | LVCMOS33 | PULL_UP | 8 mA | TB6612FGN `BIN1` | Điều khiển chiều Bánh Phải Bit 1 |
| `IN4` | **41** | LVCMOS33 | PULL_UP | 8 mA | TB6612FGN `BIN2` | Điều khiển chiều Bánh Phải Bit 2 |

---

## 2. Bảng Trạng Thái Điều Khiển Driver Cầu H TB6612FGN

Mỗi kênh động cơ của TB6612FGN được RTL điều khiển theo 4 chế độ trạng thái:

| IN1 / IN4 | IN2 / IN3 | PWM | Trạng Thái Động Cơ | Ý Nghĩa Trong Xe Dò Line |
| :---: | :---: | :---: | :--- | :--- |
| `1` | `0` | `Duty` | **Quay Tiến (Forward)** | Chế độ chạy bình thường khi đi thẳng và cua nhẹ |
| `0` | `1` | `Duty` | **Quay Lùi / Phanh Đảo Chiều (Reverse)** | Phanh chủ động bánh trong cua khi vào góc cua gắt |
| `1` | `1` | `x` | **Phanh Ngắn (Short Brake)** | Khóa chập cuộn dây động cơ |
| `0` | `0` | `x` | **Thả Trôi (Coast / Stop)** | Ngắt toàn bộ công suất motor |

---

## 3. Sơ Đồ Khối Đấu Nguồn Chi Tiết

```text
[ Pin LiPo 3S (11.1V - 12.6V) ]
                |
                +---> [ Công Tắc Gạt ] ---> [ Diode 1N4007 Chống Ngược ]
                                                        |
                                                        +-----------------------> Chân VM Driver TB6612FGN
                                                        |
                                                [ Mạch Buck Mini360 ]
                                                        | (Đường Nguồn 5.0V)
                                                        +-----------------------> VCC Cảm Biến và Mạch Đệm
                                                        |
                                                [ Ổn Áp AMS1117-3.3V ]
                                                        | (Đường Nguồn 3.3V)
                                                        +-----------------------> VCCIO và Lõi FPGA Tang Nano 9K
```
