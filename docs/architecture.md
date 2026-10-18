# System & RTL Architecture

Technical specifications of the FPGA High-Speed Line Follower Robot architecture.

```mermaid
flowchart TD
    subgraph PowerSystem["Power Supply Subsystem"]
        BAT["3S LiPo Battery (11.1V - 12.6V)"] --> SW["Power Switch & 1N4007"]
        SW --> VM["Motor Bus (11.1V VM)"]
        SW --> BUCK["Mini360 DC-DC (5.0V)"]
        BUCK --> LDO["AMS1117-3.3V"]
        LDO --> VCC_FPGA["FPGA 3.3V Logic Rail"]
    end

    subgraph SensorFrontEnd["Optical Sensing Subsystem"]
        IR["8-IR Reflective Sensor Bar (S1 - S8)"] --> ADC["Analog Frontend / Pre-processor"]
        ADC -->|"8-bit Digital Vector"| FPGA_IN["FPGA GPIO (Pins 25-28, 36-39)"]
    end

    subgraph FPGACore["Sipeed Tang Nano 9K (GW1NR-9C) RTL Pipeline"]
        CLK["27 MHz Oscillator"] --> DIV["1 kHz Control Tick Generator"]
        FPGA_IN --> BARY["Error Barycenter Calculator"]
        BARY --> FUZZY["Fuzzy Logic Engine"]
        DIV --> FUZZY
        FUZZY --> DAMP["Derivative Damping Unit"]
        DAMP --> STEER["Steering Vector Defuzzifier"]
        STEER --> MIXER["Speed & Turn Mixer + Active Brake"]
        CLK --> PWM_A["20 kHz PWM Channel A (Left)"]
        CLK --> PWM_B["20 kHz PWM Channel B (Right)"]
        MIXER --> PWM_A
        MIXER --> PWM_B
    end

    subgraph MotorSubsystem["Actuation Subsystem"]
        PWM_A -->|"PWMA, IN1, IN2"| TB["TB6612FGN Dual Driver"]
        PWM_B -->|"PWMB, IN3, IN4"| TB
        VM --> TB
        TB -->|"Motor A"| MOT_L["Left High-RPM DC Motor"]
        TB -->|"Motor B"| MOT_R["Right High-RPM DC Motor"]
    end
```

---

## Hardware RTL Specifications

- **Target FPGA**: Gowin Semiconductor GW1NR-LV9QN88PC6/I5 (Tang Nano 9K)
- **Onboard Frequency**: 27.000 MHz
- **Logic Utilization**: ~600 LUT4s (< 7% of GW1NR-9 resource budget)
- **PWM Carrier Frequency**: 20.000 kHz
- **Control Loop Update Rate**: 1,000 Hz (1.00 ms cycle)
- **Clock Period**: 37.037 ns (Constrained via `FPGA_DO_LINE.sdc`)
