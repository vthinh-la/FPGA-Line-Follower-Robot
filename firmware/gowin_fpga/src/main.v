module main (
    input  wire sys_clk,  
    input  wire s1, input  wire s2, input  wire s3, input  wire s4,
    input  wire s5, input  wire s6, input  wire s7, input  wire s8,
    
    output wire PWMA,     // Bánh Trái
    output reg  IN1, output reg  IN2,
    output wire PWMB,     // Bánh Phải
    output reg  IN4, output reg  IN3
);

    parameter SENSOR_ACTIVE_LOW   = 1'b0;
    parameter MOTOR_FORWARD_LEVEL = 1'b1;
    parameter PWM_ACTIVE_HIGH     = 1'b1;
    parameter integer GAIN_PWMA_PCT = 98;
    parameter integer GAIN_PWMB_PCT = 100;
    parameter QUICK_RECOVER_ON_LOST = 1'b1;
    parameter SENSOR_LEFT_RIGHT_SWAP = 1'b0;

    localparam integer CLK_HZ       = 27_000_000;
    localparam integer PWM_HZ       = 20000;
    localparam integer PWM_PERIOD   = CLK_HZ / PWM_HZ;
    
    // ==========================================
    // KHỐI 1: NÂNG CẤP TỐC ĐỘ (SPEED BOOST)
    // ==========================================
    localparam integer DUTY_FAST    = (PWM_PERIOD * 60) / 100; 
    localparam integer DUTY_STRAIGHT = (PWM_PERIOD * 60) / 100; 
    localparam integer DUTY_PRE_CORNER = (PWM_PERIOD * 20) / 100; 
    localparam integer DUTY_MID     = (PWM_PERIOD * 36) / 100; 
    localparam integer DUTY_SLOW    = (PWM_PERIOD * 12) / 100; 
    localparam integer DUTY_MIN     = (PWM_PERIOD * 18) / 100; 
    
    localparam integer DUTY_STEP_UP = (PWM_PERIOD * 4) / 100;  
    localparam integer DUTY_STEP_UP_STRAIGHT = (PWM_PERIOD * 1) / 100; 
    localparam integer DUTY_STEP_DOWN = (PWM_PERIOD * 60) / 100; 

    // ==========================================
    // KHỐI 2: BỘ ĐIỀU KHIỂN PID PHÂN CẤP (GAIN-SCHEDULED PID)
    // ==========================================
    // Các mức độ bẻ lái khâu P (Piecewise Proportional Outputs)
    localparam integer PID_STEER_ZERO = 0;
    localparam integer PID_STEER_SOFT = (PWM_PERIOD * 8) / 100;   // Lệch nhẹ -> Nhích lái nhẹ (Đằm xe) - Giảm từ 6% để tránh chao
    localparam integer PID_STEER_MID  = (PWM_PERIOD * 10) / 100;  // Lệch vừa -> Bẻ lái vừa - Giảm từ 15%
    localparam integer PID_STEER_HARD = (PWM_PERIOD * 35) / 100;  // Lệch gắt -> Quặp đầu xe ngay lập tức
    localparam integer PID_DAMPING    = (PWM_PERIOD * 14) / 100;  // Lực hãm vi phân D chống văng đuôi xe - Tăng từ 8% để chống rung
    
    localparam integer PID_OUT_LIMIT = (PWM_PERIOD * 40) / 100; 
    localparam integer PID_OUT_LIMIT_CORNER = (PWM_PERIOD * 35) / 100; 
    localparam integer PID_OUT_LIMIT_STRAIGHT = (PWM_PERIOD * 5) / 100;  // Giảm từ 8% để steering mượt hơn khi đi thẳng
    localparam integer PID_OUT_LIMIT_EXIT = (PWM_PERIOD * 12) / 100; 
    localparam integer PID_STRAIGHT_DEADBAND = (PWM_PERIOD * 12) / 1000; 

    localparam integer CORNER_OUTER_BOOST_MID = (PWM_PERIOD * 4) / 100; 
    localparam integer CORNER_OUTER_BOOST_HARD = (PWM_PERIOD * 10) / 100; 

    localparam integer CORNER_ENTRY_ERR_TH = 2;  
    localparam integer CORNER_HARD_ERR_TH = 4;   
    localparam integer ERR_FILTER_SHIFT = 2;     
    localparam integer STRAIGHT_ERR_TH = 1;      
    localparam integer STRAIGHT_RELEASE_ERR_TH = 2; 
    localparam integer STRAIGHT_COUNT_GO = 52;   
    localparam integer STRAIGHT_COUNT_MAX = 100;  
    
    localparam integer CORNER_EXIT_HOLD = 80;    
    localparam integer STRAIGHT_PID_FILTER_SHIFT = 5;  // Tăng từ 4 để filter nhẹ nhàng hơn (chia 32 thay vì chia 16)
    localparam integer STRAIGHT_PID_DECAY_SHIFT = 2;  
    localparam integer CTRL_HZ      = 1000;      
    localparam integer CTRL_TICKS   = CLK_HZ / CTRL_HZ; 

    reg [31:0] pwm_cnt     = 32'd0;
    reg [31:0] ctrl_cnt    = 32'd0;
    reg [31:0] duty_a      = DUTY_FAST;
    reg [31:0] duty_b      = DUTY_FAST;
    reg [31:0] duty_a_target = DUTY_FAST;
    reg [31:0] duty_b_target = DUTY_FAST;
    reg        last_turn_right = 1'b0;
    reg        last_line_right = 1'b0;
    reg        last_extreme_right = 1'b0;
    reg        extreme_hint_valid = 1'b0;
    
    reg signed [11:0] line_error = 12'sd0;
    reg signed [11:0] line_error_sum = 12'sd0;
    reg [3:0] line_count = 4'd0;
    reg [11:0] abs_line_error = 12'd0;
    reg signed [11:0] line_error_ctrl = 12'sd0;
    reg [11:0] abs_line_error_ctrl = 12'd0;
    
    // Các biến dùng cho bộ điều khiển PID phân cấp
    reg signed [11:0] pid_prev_error = 12'sd0;
    reg signed [15:0] pid_steer_p = 16'sd0;
    reg signed [15:0] pid_damping_d = 16'sd0;
    reg signed [15:0] error_diff = 16'sd0;
    
    reg signed [31:0] pid_output = 32'sd0;
    reg signed [31:0] pid_output_drive = 32'sd0;
    reg signed [31:0] pid_output_straight = 32'sd0;
    reg [31:0] base_duty = DUTY_MID;
    reg [7:0] straight_cnt = 8'd0;
    
    reg signed [11:0] prev_error_sign = 12'sd0; 
    reg [7:0]  corner_exit_cnt = 8'd0;
    reg corner_mode = 1'b0;
    reg allow_active_brake = 1'b0;
    reg [31:0] corner_boost = 32'd0;
    reg signed [31:0] duty_a_calc = 32'sd0;
    reg signed [31:0] duty_b_calc = 32'sd0;

    wire [7:0] sensor_raw = {s8, s7, s6, s5, s4, s3, s2, s1};
    wire [7:0] sensor     = SENSOR_ACTIVE_LOW ? ~sensor_raw : sensor_raw;
    wire [7:0] line_bits  = SENSOR_ACTIVE_LOW ? sensor : ~sensor;

    wire s1_on = line_bits[0];
    wire s2_on = line_bits[1];
    wire s3_on = line_bits[2];
    wire s4_on = line_bits[3];
    wire s5_on = line_bits[4];
    wire s6_on = line_bits[5];
    wire s7_on = line_bits[6];
    wire s8_on = line_bits[7];

    wire any_line = s1_on | s2_on | s3_on | s4_on | s5_on | s6_on | s7_on | s8_on;
    wire all_sensor_zero = ~(|sensor);
    wire straight_pattern = s3_on && s4_on && s5_on && s6_on && !s1_on && !s2_on && !s7_on && !s8_on;
    wire pre_corner = s2_on || s7_on || (abs_line_error >= CORNER_ENTRY_ERR_TH);
    wire hard_corner = s1_on || s8_on || (abs_line_error >= CORNER_HARD_ERR_TH);
    wire dir_fwd    = MOTOR_FORWARD_LEVEL;
    wire dir_rev    = ~MOTOR_FORWARD_LEVEL;
    wire [31:0] duty_a_trim = (duty_a * GAIN_PWMA_PCT) / 100;
    wire [31:0] duty_b_trim = (duty_b * GAIN_PWMB_PCT) / 100;

    always @(*) begin
        line_error_sum = 12'sd0;
        line_count = 4'd0;
        if (s1_on) begin line_error_sum = line_error_sum - 12'sd7; line_count = line_count + 1'b1; end
        if (s2_on) begin line_error_sum = line_error_sum - 12'sd5; line_count = line_count + 1'b1; end
        if (s3_on) begin line_error_sum = line_error_sum - 12'sd3; line_count = line_count + 1'b1; end
        if (s4_on) begin line_error_sum = line_error_sum - 12'sd1; line_count = line_count + 1'b1; end
        if (s5_on) begin line_error_sum = line_error_sum + 12'sd1; line_count = line_count + 1'b1; end
        if (s6_on) begin line_error_sum = line_error_sum + 12'sd3; line_count = line_count + 1'b1; end
        if (s7_on) begin line_error_sum = line_error_sum + 12'sd5; line_count = line_count + 1'b1; end
        if (s8_on) begin line_error_sum = line_error_sum + 12'sd7; line_count = line_count + 1'b1; end

        if (line_count != 0) begin
            line_error = line_error_sum / $signed({1'b0, line_count});
        end else begin
            line_error = 12'sd0;
        end

        if (s3_on && s4_on && s5_on && s6_on && !s1_on && !s2_on && !s7_on && !s8_on) begin
            line_error = 12'sd0;
        end

        if (SENSOR_LEFT_RIGHT_SWAP) line_error = -line_error;
        if (line_error < 0) begin
            abs_line_error = -line_error;
        end else begin
            abs_line_error = line_error;
        end

        if (line_error_ctrl < 0) begin
            abs_line_error_ctrl = -line_error_ctrl;
        end else begin
            abs_line_error_ctrl = line_error_ctrl;
        end
    end

    always @(posedge sys_clk) begin
        if (pwm_cnt == PWM_PERIOD - 1) begin
            pwm_cnt <= 32'd0;
        end else begin
            pwm_cnt <= pwm_cnt + 1'b1;
        end

        if (s1_on && !s8_on) begin
            last_extreme_right <= 1'b0;
            extreme_hint_valid <= 1'b1;
            last_turn_right <= 1'b0;
        end else if (s8_on && !s1_on) begin
            last_extreme_right <= 1'b1;
            extreme_hint_valid <= 1'b1;
            last_turn_right <= 1'b1;
        end else if (s3_on || s4_on || s5_on || s6_on) begin
            extreme_hint_valid <= 1'b0;
        end

        if (ctrl_cnt == CTRL_TICKS - 1) begin
            ctrl_cnt <= 32'd0;
            if (any_line) begin
                if (s1_on || s2_on || s7_on || s8_on || (abs_line_error >= CORNER_ENTRY_ERR_TH)) begin
                    line_error_ctrl <= line_error;
                end else begin
                    line_error_ctrl <= line_error_ctrl + ((line_error - line_error_ctrl) >>> ERR_FILTER_SHIFT);
                end

                pid_prev_error <= line_error_ctrl;
                
                if (line_error_ctrl < 0) begin
                    last_line_right <= 1'b0;
                    last_turn_right <= 1'b0;
                end else if (line_error_ctrl > 0) begin
                    last_line_right <= 1'b1;
                    last_turn_right <= 1'b1;
                end
            end else begin
                line_error_ctrl <= 12'sd0;
                pid_prev_error <= 12'sd0;
            end

            if (any_line && pre_corner) begin
                corner_exit_cnt <= CORNER_EXIT_HOLD[7:0];
            end else if (corner_exit_cnt > 8'd0) begin
                corner_exit_cnt <= corner_exit_cnt - 8'd1;
            end

            if (any_line && (abs_line_error <= STRAIGHT_ERR_TH) && straight_pattern) begin
                if (straight_cnt < STRAIGHT_COUNT_MAX[7:0]) begin
                    straight_cnt <= straight_cnt + 1'b1;
                end
            end else if (abs_line_error >= STRAIGHT_RELEASE_ERR_TH || s1_on || s8_on) begin
                straight_cnt <= 8'd0;
            end else begin
                if (straight_cnt > 8'd4) begin
                    straight_cnt <= straight_cnt - 8'd4;
                end else begin
                    straight_cnt <= 8'd0;
                end
            end

            if ((straight_cnt >= STRAIGHT_COUNT_GO[7:0]) && any_line && straight_pattern) begin
                pid_output_straight <= pid_output_straight + ((pid_output - pid_output_straight) >>> STRAIGHT_PID_FILTER_SHIFT);
            end else begin
                pid_output_straight <= pid_output_straight - (pid_output_straight >>> STRAIGHT_PID_DECAY_SHIFT);
            end

            if (duty_a < duty_a_target) begin
                if ((duty_a_target - duty_a) > ((straight_cnt >= STRAIGHT_COUNT_GO[7:0]) ? DUTY_STEP_UP_STRAIGHT : DUTY_STEP_UP))
                    duty_a <= duty_a + ((straight_cnt >= STRAIGHT_COUNT_GO[7:0]) ? DUTY_STEP_UP_STRAIGHT : DUTY_STEP_UP);
                else
                    duty_a <= duty_a_target;
            end else if (duty_a > duty_a_target) begin
                if ((duty_a - duty_a_target) > DUTY_STEP_DOWN)
                    duty_a <= duty_a - DUTY_STEP_DOWN;
                else
                    duty_a <= duty_a_target;
            end

            if (duty_b < duty_b_target) begin
                if ((duty_b_target - duty_b) > ((straight_cnt >= STRAIGHT_COUNT_GO[7:0]) ? DUTY_STEP_UP_STRAIGHT : DUTY_STEP_UP))
                    duty_b <= duty_b + ((straight_cnt >= STRAIGHT_COUNT_GO[7:0]) ? DUTY_STEP_UP_STRAIGHT : DUTY_STEP_UP);
                else
                    duty_b <= duty_b_target;
            end else if (duty_b > duty_b_target) begin
                if ((duty_b - duty_b_target) > DUTY_STEP_DOWN)
                    duty_b <= duty_b - DUTY_STEP_DOWN;
                else
                    duty_b <= duty_b_target;
            end
        end else begin
            ctrl_cnt <= ctrl_cnt + 1'b1;
        end
    end

    // TÍNH TOÁN ĐIỀU KHIỂN PID (PIECEWISE P-D STEERING COMPUTATION)
    always @(*) begin
        // 1. Khâu Tỉ lệ P phân cấp theo sai số lệch tâm (Proportional Steering)
        if      (line_error_ctrl <= -5) pid_steer_p =  PID_STEER_HARD; // Rẽ Trái Gắt
        else if (line_error_ctrl == -4) pid_steer_p =  PID_STEER_MID;  // Rẽ Trái Vừa
        else if (line_error_ctrl == -3) pid_steer_p =  PID_STEER_MID;
        else if (line_error_ctrl == -2) pid_steer_p =  PID_STEER_SOFT; // Rẽ Trái Nhẹ
        else if (line_error_ctrl == -1) pid_steer_p =  PID_STEER_SOFT;
        else if (line_error_ctrl ==  0) pid_steer_p =  PID_STEER_ZERO; // Tâm vạch
        else if (line_error_ctrl ==  1) pid_steer_p = -PID_STEER_SOFT; // Rẽ Phải Nhẹ
        else if (line_error_ctrl ==  2) pid_steer_p = -PID_STEER_SOFT;
        else if (line_error_ctrl ==  3) pid_steer_p = -PID_STEER_MID;  // Rẽ Phải Vừa
        else if (line_error_ctrl ==  4) pid_steer_p = -PID_STEER_MID;
        else if (line_error_ctrl >=  5) pid_steer_p = -PID_STEER_HARD; // Rẽ Phải Gắt
        else                            pid_steer_p =  PID_STEER_ZERO;

        // 2. Khâu Vi phân D giảm chấn động học (Derivative Damping) - Hãm văng đuôi
        error_diff = line_error_ctrl - pid_prev_error;
        if      (error_diff >=  2) pid_damping_d = -PID_DAMPING; // Lao ra phải nhanh -> Ép ngược lại
        else if (error_diff <= -2) pid_damping_d =  PID_DAMPING; // Lao ra trái nhanh -> Ép ngược lại
        else                       pid_damping_d =  0;

        // 3. Tổng hợp tín hiệu điều khiển lái PID (pid_output = P + D)
        pid_output = pid_steer_p + pid_damping_d;

        if (pid_output > PID_OUT_LIMIT) begin
            pid_output = PID_OUT_LIMIT;
        end else if (pid_output < -PID_OUT_LIMIT) begin
            pid_output = -PID_OUT_LIMIT;
        end
    end

    always @(*) begin
        duty_a_calc = 32'sd0;
        duty_b_calc = 32'sd0;
        pid_output_drive = pid_output;
        base_duty = DUTY_FAST;
        corner_mode = 1'b0;
        allow_active_brake = 1'b0;
        corner_boost = 32'd0;

        if (all_sensor_zero) begin
            IN1 = dir_fwd; IN2 = dir_rev;
            IN4 = dir_fwd; IN3 = dir_rev;
            duty_a_target = 32'd0;
            duty_b_target = 32'd0;
        end else if (!any_line) begin
            // Xử lý khi văng mất line - Khôi phục nhẹ nhàng (không chao mạnh)
            // Thay vì 1 bánh quay tối đa + bánh kia dừng, ta chạy cả 2 bánh nhưng bánh ngoài chậm hơn
            if (QUICK_RECOVER_ON_LOST) begin
                if (last_line_right) begin
                    // Line bên phải -> bánh trái chạy nhanh hơn, bánh phải chạy chậm (không dừng)
                    IN1 = dir_fwd; IN2 = dir_rev;
                    IN4 = dir_fwd; IN3 = dir_rev;
                    duty_a_target = DUTY_FAST; 
                    duty_b_target = DUTY_SLOW;     // Thay vì 32'd0 (dừng) -> chạy chậm
                end else begin
                    // Line bên trái -> bánh phải chạy nhanh hơn, bánh trái chạy chậm (không dừng)
                    IN1 = dir_fwd; IN2 = dir_rev;
                    IN4 = dir_fwd; IN3 = dir_rev;
                    duty_a_target = DUTY_SLOW;     // Thay vì 32'd0 (dừng) -> chạy chậm
                    duty_b_target = DUTY_FAST; 
                end
            end else begin
                IN1 = dir_fwd; IN2 = dir_rev;
                IN4 = dir_fwd; IN3 = dir_rev;
                if (last_turn_right) begin
                    duty_a_target = DUTY_MIN;
                    duty_b_target = DUTY_MID;
                end else begin
                    duty_a_target = DUTY_MID;
                    duty_b_target = DUTY_MIN;
                end
            end
        end else begin
            // ĐANG CÓ LINE - ĐI BÌNH THƯỜNG
            if ((straight_cnt >= STRAIGHT_COUNT_GO[7:0]) && (abs_line_error <= STRAIGHT_ERR_TH) && straight_pattern) begin
                base_duty = DUTY_STRAIGHT;
                pid_output_drive = pid_output_straight;
                if (pid_output_drive > PID_OUT_LIMIT_STRAIGHT) begin
                    pid_output_drive = PID_OUT_LIMIT_STRAIGHT;
                end else if (pid_output_drive < -PID_OUT_LIMIT_STRAIGHT) begin
                    pid_output_drive = -PID_OUT_LIMIT_STRAIGHT;
                end
                if ((pid_output_drive < PID_STRAIGHT_DEADBAND) && (pid_output_drive > -PID_STRAIGHT_DEADBAND)) begin
                    pid_output_drive = 32'sd0;
                end
            end else if (hard_corner) begin
                base_duty = DUTY_SLOW;
                corner_mode = 1'b1;
                allow_active_brake = 1'b1;
                corner_boost = CORNER_OUTER_BOOST_HARD;
                if (pid_output_drive > PID_OUT_LIMIT_CORNER) pid_output_drive = PID_OUT_LIMIT_CORNER;
                else if (pid_output_drive < -PID_OUT_LIMIT_CORNER) pid_output_drive = -PID_OUT_LIMIT_CORNER;
            end else if (pre_corner) begin
                base_duty = DUTY_PRE_CORNER;
                corner_mode = 1'b1;
                corner_boost = CORNER_OUTER_BOOST_MID;
                if (pid_output_drive > PID_OUT_LIMIT_CORNER) pid_output_drive = PID_OUT_LIMIT_CORNER;
                else if (pid_output_drive < -PID_OUT_LIMIT_CORNER) pid_output_drive = -PID_OUT_LIMIT_CORNER;
            end else if (corner_exit_cnt > 8'd0) begin
                base_duty = DUTY_MID;
                pid_output_drive = (pid_output_drive >>> 1);
                if (pid_output_drive > PID_OUT_LIMIT_EXIT) pid_output_drive = PID_OUT_LIMIT_EXIT;
                else if (pid_output_drive < -PID_OUT_LIMIT_EXIT) pid_output_drive = -PID_OUT_LIMIT_EXIT;
            end else begin
                base_duty = DUTY_FAST;
            end

            duty_a_calc = $signed(base_duty) - pid_output_drive;
            duty_b_calc = $signed(base_duty) + pid_output_drive;

            if (corner_mode) begin
                if (duty_a_calc >= duty_b_calc) duty_a_calc = duty_a_calc + corner_boost;
                else duty_b_calc = duty_b_calc + corner_boost;
            end

            // KÍCH HOẠT PHANH CHỦ ĐỘNG (ACTIVE BRAKING)
            if (allow_active_brake && (duty_a_calc < 0)) begin
                IN1 = dir_rev; 
                IN2 = dir_fwd;
                duty_a_target = (-duty_a_calc > (PWM_PERIOD - 1)) ? (PWM_PERIOD - 1) : -duty_a_calc[31:0];
            end else begin
                IN1 = dir_fwd; 
                IN2 = dir_rev;
                if (duty_a_calc < 0) duty_a_target = 32'd0;
                else duty_a_target = (duty_a_calc > (PWM_PERIOD - 1)) ? (PWM_PERIOD - 1) : duty_a_calc[31:0];
            end

            if (allow_active_brake && (duty_b_calc < 0)) begin
                IN4 = dir_rev; 
                IN3 = dir_fwd;
                duty_b_target = (-duty_b_calc > (PWM_PERIOD - 1)) ? (PWM_PERIOD - 1) : -duty_b_calc[31:0];
            end else begin
                IN4 = dir_fwd; 
                IN3 = dir_rev;
                if (duty_b_calc < 0) duty_b_target = 32'd0;
                else duty_b_target = (duty_b_calc > (PWM_PERIOD - 1)) ? (PWM_PERIOD - 1) : duty_b_calc[31:0];
            end
        end
    end

    assign PWMA = PWM_ACTIVE_HIGH ? ((pwm_cnt < duty_a_trim) ? 1'b1 : 1'b0)
                                 : ((pwm_cnt < duty_a_trim) ? 1'b0 : 1'b1);
    assign PWMB = PWM_ACTIVE_HIGH ? ((pwm_cnt < duty_b_trim) ? 1'b1 : 1'b0)
                                 : ((pwm_cnt < duty_b_trim) ? 1'b0 : 1'b1);

endmodule