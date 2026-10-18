# Pinout and Hardware Interconnect Guide

This document defines the complete physical pin mapping between the **Sipeed Tang Nano 9K (Gowin GW1NR-9)**, the **TB6612FGN Dual Motor Driver**, the **8-Channel IR Sensor Array**, and the **Power System**.

---

## 1. Tang Nano 9K Physical Constraints (CST) Mapping

All FPGA pin assignments are specified in [`firmware/gowin_fpga/src/FPGA_DO_LINE.cst`](../firmware/gowin_fpga/src/FPGA_DO_LINE.cst):

| Net / Port | FPGA Pin (GW1NR-9) | I/O Standard | Pull Mode | Drive | Target Peripheral | Description |
| :--- | :---: | :--- | :--- | :---: | :--- | :--- |
| `sys_clk` | **52** | LVCMOS33 | PULL_UP | - | Onboard Oscillator | 27.000 MHz system clock source |
| `s1` | **38** | LVCMOS33 | PULL_UP | - | Sensor Bar Bit 0 | Outermost Left Sensor |
| `s2` | **37** | LVCMOS33 | PULL_UP | - | Sensor Bar Bit 1 | Mid-Outer Left Sensor |
| `s3` | **36** | LVCMOS33 | PULL_UP | - | Sensor Bar Bit 2 | Inner Left Sensor |
| `s4` | **39** | LVCMOS33 | PULL_UP | - | Sensor Bar Bit 3 | Center-Left Sensor |
| `s5` | **25** | LVCMOS33 | PULL_UP | - | Sensor Bar Bit 4 | Center-Right Sensor |
| `s6` | **26** | LVCMOS33 | PULL_UP | - | Sensor Bar Bit 5 | Inner Right Sensor |
| `s7` | **27** | LVCMOS33 | PULL_UP | - | Sensor Bar Bit 6 | Mid-Outer Right Sensor |
| `s8` | **28** | LVCMOS33 | PULL_UP | - | Sensor Bar Bit 7 | Outermost Right Sensor |
| `PWMA` | **33** | LVCMOS33 | PULL_UP | 8 mA | TB6612FGN `PWMA` | Left Motor Speed (20 kHz PWM) |
| `IN1` | **34** | LVCMOS33 | PULL_UP | 8 mA | TB6612FGN `AIN2` | Left Motor Direction Bit 1 |
| `IN2` | **40** | LVCMOS33 | PULL_UP | 8 mA | TB6612FGN `AIN1` | Left Motor Direction Bit 2 |
| `PWMB` | **35** | LVCMOS33 | PULL_UP | 8 mA | TB6612FGN `PWMB` | Right Motor Speed (20 kHz PWM) |
| `IN3` | **42** | LVCMOS33 | PULL_UP | 8 mA | TB6612FGN `BIN1` | Right Motor Direction Bit 1 |
| `IN4` | **41** | LVCMOS33 | PULL_UP | 8 mA | TB6612FGN `BIN2` | Right Motor Direction Bit 2 |

---

## 2. TB6612FGN Dual H-Bridge Truth Table

The Verilog RTL drives the TB6612FGN H-Bridge to achieve 4 operational modes per channel:

| IN1 / IN4 | IN2 / IN3 | PWM | Motor State | Function in Line Tracer |
| :---: | :---: | :---: | :--- | :--- |
| `1` | `0` | `Duty` | **Forward Drive** | Normal straight and gentle turning mode |
| `0` | `1` | `Duty` | **Reverse Active Brake** | Dynamic cornering brake on inside wheel |
| `1` | `1` | `x` | **Short Brake** | Instant motor lock |
| `0` | `0` | `x` | **Coast / Stop** | Free wheeling |

---

## 3. Power Distribution Architecture

```text
[ LiPo Battery 3S (11.1V - 12.6V) ]
                |
                +---> [ Toggle Switch ] ---> [ 1N4007 Reverse Diode ]
                                                      |
                                                      +-------------------------> TB6612FGN Motor Power (VM pin)
                                                      |
                                              [ Mini360 Buck DC-DC ]
                                                      | (5.0V Bus)
                                                      +-------------------------> Carrier VCC & Sensor VCC
                                                      |
                                              [ AMS1117-3.3V LDO ]
                                                      | (3.3V Bus)
                                                      +-------------------------> Tang Nano 9K VCCIO
```
