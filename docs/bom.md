# Bill of Materials (BOM)

Detailed component breakdown for the FPGA High-Speed Line Follower Robot.

| Item | Component | Reference / Model | Quantity | Package / Rating | Function |
| :--- | :--- | :--- | :---: | :--- | :--- |
| 1 | **FPGA Core Module** | Sipeed Tang Nano 9K | 1 | GW1NR-LV9QN88PC6/I5 (8640 LUT4, 27 MHz Crystal) | Main digital real-time control processor |
| 2 | **Motor Driver IC** | Toshiba TB6612FGN | 1 | SSOP-24 Carrier Module (VM: 2.5-15V, 1.2A cont / 3.2A peak) | Dual DC H-Bridge driver for differential steering |
| 3 | **DC Geared Motors** | N20 / Micro DC Motors | 2 | 6V-12V High-RPM (1000 - 3000 RPM) | Propulsion & differential steering |
| 4 | **Power Buck Converter** | Mini360 DC-DC | 1 | Ultra-compact step-down module (Vin: 4.75-23V, Vout: 1-17V, 1.8A) | Steps down 11.1V/12V LiPo battery to 5.0V system bus |
| 5 | **Linear Voltage Regulators** | AMS1117-3.3V / LT1117 | 2 | SOT-223 (3.3V, 1A) | Clean 3.3V power rails for FPGA I/O & logic |
| 6 | **Line Sensor Array** | 8-Channel IR Optical Bar | 1 | Custom boomerang PCB with TCRT5000 / ITR9909 | Ground reflectance detection (line tracking) |
| 7 | **Sensor ADC / Comparator** | ATmega328P / ATmega8 | 1 | TQFP-32 (Onboard carrier) | Analog sensor reading & digital thresholding |
| 8 | **Anti-Reverse Diode** | 1N4007 | 1 | DO-41 (1A, 1000V) | Reverse polarity protection from battery |
| 9 | **Battery Pack** | 3S LiPo Battery | 1 | 11.1V - 12.6V, 450mAh - 850mAh, 45C+ (XT30 connector) | Main power source |
| 10 | **Decoupling Capacitors** | Ceramic SMD / Electrolytic | 4 | 100nF, 1uF, 10uF, 100uF | Power filtering & motor noise suppression |
| 11 | **Power Switch** | Heavy-duty Toggle Switch | 1 | SPST / SPDT 3A+ | Master power switch |
| 12 | **Front Support Caster** | Steel Ball Caster | 1 | Mini Omni ball transfer unit (Dia 8mm - 12mm) | Low friction front pivot point |
| 13 | **Wheels & Hubs** | High-Grip Silicone Wheels | 2 | Aluminum D-shaft hub coupling + Silicon cast tire | Traction & power transfer |
| 14 | **Chassis Frame** | 3D Printed Delta Body | 1 | PLA / PETG (`mechanical/3d_models/chassis_frame.stl`) | Aerodynamic lightweight structural frame |
