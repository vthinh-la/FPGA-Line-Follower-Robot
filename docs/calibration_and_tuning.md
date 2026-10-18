# Calibration & Track Tuning Guide

Instructions for calibrating the optical line sensors, motor trim gain, and tuning control parameters for competition tracks.

---

## 1. Sensor Calibration

1. **Height Adjustment**: Ensure the front IR sensor array is positioned **3 mm - 5 mm** above the competition surface. Excessive height reduces contrast; insufficient height risks scraping on track seams.
2. **Threshold Setting**:
   - Place the robot over white reflective floor: Sensor output must read logic `0` (or `1` depending on active level).
   - Place each sensor over black vinyl tape: Sensor output must switch reliably.
   - If using the onboard ATmega comparator/ADC frontend, trigger the `Kali` pushbutton to store black and white threshold values in EEPROM.

---

## 2. Motor Trim Gain Calibration

Due to manufacturing tolerances in DC motors and gearbox friction, one motor will often spin slightly faster than the other. The Verilog RTL provides dedicated trim gain parameters in [`firmware/gowin_fpga/src/main.v`](../firmware/gowin_fpga/src/main.v#L15-L16):

```verilog
parameter integer GAIN_PWMA_PCT = 98;  // Left Motor Trim (Percentage)
parameter integer GAIN_PWMB_PCT = 100; // Right Motor Trim (Percentage)
```

- If the robot pulls to the right on straight tracks: Decrease `GAIN_PWMB_PCT` or increase `GAIN_PWMA_PCT`.
- If the robot pulls to the left: Decrease `GAIN_PWMA_PCT` or increase `GAIN_PWMB_PCT`.

---

## 3. High-Speed Track Tuning Parameters

| Parameter in `main.v` | Default | Description | Tuning Tip |
| :--- | :---: | :--- | :--- |
| `DUTY_FAST` | 60% | Cruising speed on normal curved track | Increase for faster overall lap times |
| `DUTY_STRAIGHT` | 60% | Maximum speed on confirmed straight track | Can be tuned up to 80-90% on long straights |
| `DUTY_SLOW` | 12% | Minimum speed during hard corners | Increase if the car stalls; decrease if car skids off |
| `FZ_STEER_HARD` | 35% | Maximum steering torque vector | Increase for hairpin / 90-degree corners |
| `FZ_DAMPING` | 14% | Anti-fishtailing derivative counter-torque | Increase if vehicle wobbles on straight line |
| `STRAIGHT_COUNT_GO` | 52 | Cycles needed to confirm straight line before boost | Decrease for earlier acceleration out of corners |
