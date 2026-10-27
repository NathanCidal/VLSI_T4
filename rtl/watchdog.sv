module watchdog(
    input logic clk,
    input logic rst,
    input logic sys_rst_i,
    input logic enable_i,
    input logic calibrate_i,
    output logic watch_rst_o
);

logic [63:0] contador_ref;
logic [63:0] contador;
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        contador_ref <= '0;
    end
    else begin
        if(sys_rst_i) begin
            contador_ref <= '0; 
        end
        else if(calibrate_i) begin
            contador_ref <= contador_ref + 1'b1;
        end 
    end
end

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        contador <= '0;
    end
    else begin
        if(sys_rst_i) begin
            contador <= '0; 
        end
        else if(calibrate_i || !enable_i) begin
            contador <= '0;
        end
        else begin
            contador <= contador + 1'b1;
        end
    end
end

logic stop_reg; 
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        stop_reg <= 1'b0;
    end
    else begin
        if(!sys_rst_i && !calibrate_i) begin
            if(contador == contador_ref) begin
                stop_reg <= 1'b1;
            end
            else begin
                stop_reg <= 1'b0;
            end
        end
        else begin
            stop_reg <= 1'b0;
        end
    end
end

assign watch_rst_o = stop_reg;

endmodule