module ps2_driver(
    input  logic       clock_in,
    input  logic       reset_in,
    input  logic       clock_ps2,
    input  logic       data_ps2,   
    output logic [7:0] data_p,
    output logic       data_p_en
);

// Pass signals through a flip-flop for sync
logic slow_clk;
logic old_slow_clk; // For fall edge
logic data_ps2_q;

logic sysreset;
logic calibrate;
logic reset_fsm;
logic enable_watch;

always_ff @(posedge clock_in or posedge reset_in) begin
    if(reset_in) begin
        slow_clk     <= 1'b1;
        old_slow_clk <= 1'b1;
        data_ps2_q   <= 1'b1;
    end else begin
        data_ps2_q   <= data_ps2;
        old_slow_clk <= slow_clk;
        slow_clk     <= clock_ps2;
    end
end

logic fall_edge_slow;
logic rise_edge_slow;
assign fall_edge_slow = (old_slow_clk & !slow_clk);
assign rise_edge_slow = (!old_slow_clk & slow_clk);

logic parity_ok;

typedef enum logic [4:0] {
    IDLE   = 0,
    START  = 1,
    D0     = 2,
    D1     = 3,
    D2     = 4,
    D3     = 5,
    D4     = 6,
    D5     = 7,
    D6     = 8,
    D7     = 9,
    PARITY = 10,
    STOP   = 11,
    ERROR  = 12
} state_t;

state_t current_state;
state_t next_state;

always_ff @(posedge clock_in or posedge reset_in) begin
    if(reset_in) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

logic [7:0] data;

logic parity_bit;
logic expected_parity;

always_ff @(posedge clock_in or posedge reset_in) begin
    if(reset_in) begin
        data             <= '0;
        parity_bit       <= 1'b1;
        expected_parity  <= 1'b0;
    end else begin
        if(current_state == IDLE) begin
            parity_bit       <= 1'b1;
            expected_parity  <= 1'b0;
            data             <= '0;
        end
        else if(current_state >= D0 && current_state <= D7) begin
            if(fall_edge_slow) begin
                data <= {data_ps2_q, data[7:1]}; 
                parity_bit       <= 1'b1;
                expected_parity  <= 1'b0;
            end
        end
        else if(current_state == PARITY) begin
            if(fall_edge_slow) begin
                parity_bit      <= ^data;          
                expected_parity <= data_ps2_q;
            end
        end
    end
end

always_ff @(posedge clock_in or posedge reset_in) begin
	if(reset_in) begin
		parity_ok <= 1'b0;
	end else begin
		parity_ok <= (parity_bit == expected_parity);
	end
end


always_comb begin
    next_state = current_state;
    calibrate = 0;
    sysreset = 0;
    enable_watch = 1;

    unique case(current_state)
        IDLE: begin
            sysreset = 1;
            enable_watch = 0;
            if(fall_edge_slow && !data_ps2_q) begin
                next_state = START;
                calibrate = 1;
            end
        end

        START: begin
            calibrate = 1;
            
            if(rise_edge_slow) begin
                enable_watch = 0;
                next_state = D0;
            end
        end

        D0: begin
            calibrate = 1;
            if(rise_edge_slow) begin
                enable_watch = 0;
                calibrate = 0;
                next_state = D1;
            end
        end

        D1: begin
            if(reset_fsm) begin
                next_state = IDLE;
            end
            else if(rise_edge_slow) begin
                enable_watch = 0;
                next_state = D2;
            end
        end

        D2: begin
            if(reset_fsm) begin
                next_state = IDLE;
            end
            else if(rise_edge_slow) begin
                enable_watch = 0; 
                next_state = D3;
            end
        end

        D3: begin
            if(reset_fsm) begin
                next_state = IDLE;
            end
            else if(rise_edge_slow) begin
                enable_watch = 0; 
                next_state = D4;
            end
        end

        D4: begin
            if(reset_fsm) begin
                next_state = IDLE;
            end
            else if(rise_edge_slow) begin
                enable_watch = 0;
                next_state = D5;
            end
        end

        D5: begin
            if(reset_fsm) begin
                next_state = IDLE;
            end
            else if(rise_edge_slow) begin
                enable_watch = 0;
                next_state = D6;
            end
        end

        D6: begin
            if(reset_fsm) begin
                next_state = IDLE;
            end
            else if(rise_edge_slow) begin
                enable_watch = 0;
                next_state = D7;
            end
        end

        D7: begin
            if(reset_fsm) begin
                next_state = IDLE;
            end
            else if(rise_edge_slow) begin
                enable_watch = 0;
                next_state = PARITY;
            end
        end

        PARITY: begin
            if(reset_fsm) begin
                next_state = IDLE;
            end
            else if(rise_edge_slow) begin
                enable_watch = 0;
                next_state = STOP;
            end
        end

        STOP: begin
            if(reset_fsm) begin
                next_state = ERROR;
            end
            else if(rise_edge_slow) begin
                enable_watch = 0;
                if(data_ps2_q) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = ERROR;
                end
            end
        end

        ERROR: begin
            enable_watch = 0;
            next_state = IDLE;
        end

        default: begin
            next_state = IDLE;
        end
    endcase
end

logic [7:0] out_payload;
ps2_decoder ps2_ascii_dut(
    .scancode_in(data),
    .ascii_out(out_payload)
);

watchdog u_watchdog(
    .clk         (clock_in),
    .rst         (reset_in),
    .sys_rst_i   (sysreset),
    .calibrate_i (calibrate),
    .enable_i    (enable_watch),
    .watch_rst_o (reset_fsm)
);

assign data_p = (parity_ok)? out_payload : 8'h00;
assign data_p_en = ((current_state == STOP && next_state == IDLE) && parity_ok);

endmodule
