# Assembly & Mechanical Integration Guide

This guide details the fabrication, 3D printing, and mechanical/electronic assembly procedures for the FPGA High-Speed Line Follower Robot.

---

## 1. 3D Printing Specifications

The main chassis frame is located at [`mechanical/3d_models/chassis_frame.stl`](../mechanical/3d_models/chassis_frame.stl).

| Parameter | Recommended Value | Notes |
| :--- | :--- | :--- |
| **Material** | PLA+ / PETG / ABS | PETG or PLA+ recommended for impact resistance |
| **Layer Height** | 0.20 mm | Standard quality |
| **Infill Density** | 40% - 50% | High rigidity to prevent chassis flex under acceleration |
| **Infill Pattern** | Gyroid / Honeycomb | Multi-directional structural strength |
| **Wall Perimeters** | 4 walls (1.6 mm) | Reinforces motor mounting brackets |
| **Top / Bottom Layers** | 4 / 4 | Prevents puncture from battery tie-downs |
| **Supports** | Tree / Normal on motor mounts | Remove carefully after print |

---

## 2. Assembly Sequence

### Step 1: Front Support Caster
1. Press-fit the steel mini-ball caster into the front underside socket.
2. Ensure the ball rolls freely in 360 degrees without binding.

### Step 2: DC Motors & Hub Couplings
1. Slide the two micro DC geared motors into the rear motor retaining cradles.
2. Secure with M2 mounting screws.
3. Fit the aluminum hub couplings onto the motor D-shafts and tighten the set screws.
4. Mount the high-grip silicone tires onto the rims.

### Step 3: Main Carrier Board & Tang Nano 9K
1. Mount the custom carrier PCB onto the central chassis standoffs using M2.5 nylon screws.
2. Insert the Sipeed Tang Nano 9K module into the female 2.54mm header strips with the USB-C port facing upward for accessible programming.
3. Connect the TB6612FGN driver module to the motor terminal blocks.

### Step 4: 8-Channel IR Sensor Bar
1. Fasten the forward sensor wing to the front mounting plate using M3 screws.
2. Ensure the sensors maintain a **3 mm to 5 mm clearance** above the ground track surface.
3. Route the 10-pin ribbon cable back along the center channel to the carrier PCB connector `J1`.

### Step 5: Power & LiPo Retention
1. Fasten the 3S LiPo battery in the central battery tray using a velcro strap.
2. Verify that the master toggle switch is in the **OFF** position before connecting the XT30 power plug.
