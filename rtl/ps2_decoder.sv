module ps2_decoder(
	input logic  [7:0] scancode_in,
        output logic [7:0] ascii_out	
);

always_comb begin
	case(scancode_in)
		8'h16:   begin ascii_out = 8'("1"); end
		8'h1E:   begin ascii_out = 8'("2"); end
		8'h26:   begin ascii_out = 8'("3"); end
		8'h25:   begin ascii_out = 8'("4"); end
		8'h2E:   begin ascii_out = 8'("5"); end
		8'h36:   begin ascii_out = 8'("6"); end
		8'h3D:   begin ascii_out = 8'("7"); end
		8'h3E:   begin ascii_out = 8'("8"); end
		8'h46:   begin ascii_out = 8'("9"); end
		8'h45:   begin ascii_out = 8'("0"); end
		
		8'h15:   begin ascii_out = 8'("Q"); end
		8'h1D:   begin ascii_out = 8'("W"); end
		8'h24:   begin ascii_out = 8'("E"); end
		8'h2D:   begin ascii_out = 8'("R"); end
		8'h2C:   begin ascii_out = 8'("T"); end
		8'h35:   begin ascii_out = 8'("Y"); end
		8'h3C:   begin ascii_out = 8'("U"); end
		8'h43:   begin ascii_out = 8'("I"); end
		8'h44:   begin ascii_out = 8'("O"); end
		8'h4D:   begin ascii_out = 8'("P"); end

		8'h1C:   begin ascii_out = 8'("A"); end
		8'h1B:   begin ascii_out = 8'("S"); end
		8'h23:   begin ascii_out = 8'("D"); end
		8'h2B:   begin ascii_out = 8'("F"); end
		8'h34:   begin ascii_out = 8'("G"); end
		8'h33:   begin ascii_out = 8'("H"); end
		8'h3B:   begin ascii_out = 8'("J"); end
		8'h42:   begin ascii_out = 8'("K"); end
		8'h4B:   begin ascii_out = 8'("L"); end

		8'h1A:   begin ascii_out = 8'("Z"); end
		8'h22:   begin ascii_out = 8'("X"); end
		8'h21:   begin ascii_out = 8'("C"); end
		8'h2A:   begin ascii_out = 8'("V"); end
		8'h32:   begin ascii_out = 8'("B"); end
		8'h31:   begin ascii_out = 8'("N"); end
		8'h3A:   begin ascii_out = 8'("M"); end
		8'h29:   begin ascii_out = 8'(" "); end
		default: begin ascii_out = 8'hFF;   end
	endcase	
end

endmodule
