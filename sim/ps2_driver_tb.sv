//--------------------------------------------------
// Testbench autoverificavel do ps2_driver
// Trabalho 4 - Driver PS/2
//
// Um modelo de teclado gera quadros PS/2 (Figura 2)
// e um monitor confere data_p / data_p_en.
//--------------------------------------------------
`timescale 1ns/1ps

module ps2_driver_tb;

    localparam int PS2_FAST = 500;     // meio periodo (ns) -> 1 MHz
    localparam int PS2_SLOW = 40000;   // meio periodo (ns) -> 12,5 kHz

    logic       clock_in  = 1'b0;
    logic       reset_in  = 1'b1;
    logic       clock_ps2 = 1'b1;
    logic       data_ps2  = 1'b1;
    logic [7:0] data_p;
    logic       data_p_en;

    int         en_count  = 0;
    int         en_width  = 0;
    logic [7:0] last_data = '0;
    int         errors    = 0;
    int         total     = 0;
    int         n_before;

    // relogio master: 100 MHz
    always #5 clock_in = ~clock_in;

    ps2_driver dut (
        .clock_in  (clock_in),
        .reset_in  (reset_in),
        .clock_ps2 (clock_ps2),
        .data_ps2  (data_ps2),
        .data_p    (data_p),
        .data_p_en (data_p_en)
    );

    //----------------------------------------------------------------
    // monitor: conta pulsos de data_p_en e mede sua largura
    //----------------------------------------------------------------
    always @(posedge clock_in) begin
        if (data_p_en) begin
            if (en_width == 0) begin
                en_count  <= en_count + 1;
                last_data <= data_p;
            end else begin
                $display("[%0t] FAIL | data_p_en ativo por mais de 1 ciclo", $time);
                errors = errors + 1;
            end
            en_width <= en_width + 1;
        end else begin
            en_width <= 0;
        end
    end

    //----------------------------------------------------------------
    // modelo do teclado: start + 8 bits (LSB primeiro) + P + stop
    // nbits < 11 gera quadro truncado
    //----------------------------------------------------------------
    task automatic ps2_send(input logic [7:0] code, input int half,
                            input bit bad_p, input bit bad_s, input int nbits);
        logic [10:0] frame;
        logic        p;
        p = ^code;                         // paridade impar
	if (bad_p) begin 
		p = ~p;	
	end
        frame = {~bad_s, p, code, 1'b0};    // stop, P, dados, start
        for (int i = 0; i < nbits; i++) begin
            data_ps2 = frame[i];            // dado muda com clock alto
            #(half/2);
            clock_ps2 = 1'b0;               // borda de descida: amostragem
            #(half);
            clock_ps2 = 1'b1;
            #(half/2);
        end
        data_ps2 = 1'b1;
        #(4*half);                          // intervalo entre quadros
    endtask

    task automatic check_result(input string name, input bit cond, input string msg);
        total = total + 1;
        if (cond)
            $display("[%0t] PASS | %s", $time, name);
        else begin
            $display("[%0t] FAIL | %s | %s", $time, name, msg);
            errors = errors + 1;
        end
    endtask

    // tecla pressionada: exatamente 1 pulso com o ASCII esperado
    task automatic press_key(input string name, input logic [7:0] code,
                             input logic [7:0] asc, input int half);
        n_before = en_count;
        ps2_send(code, half, 1'b0, 1'b0, 11);
        check_result($sformatf("%s sc=0x%02h", name, code),
                     (en_count == n_before + 1) && (last_data == asc),
                     $sformatf("esperado 0x%02h obtido 0x%02h pulsos=%0d",
                               asc, last_data, en_count - n_before));
    endtask

    // quadro que nao deve gerar data_p_en
    task automatic no_output(input string name, input logic [7:0] code,
                             input bit bad_p, input bit bad_s);
        n_before = en_count;
        ps2_send(code, PS2_FAST, bad_p, bad_s, 11);
        check_result($sformatf("%s sc=0x%02h", name, code),
                     en_count == n_before,
                     $sformatf("pulsos=%0d", en_count - n_before));
    endtask

    // teclas alfanumericas (Figura 3) e ASCII esperado
    logic [7:0] sc_tab  [36] = '{
        8'h16, 8'h1E, 8'h26, 8'h25, 8'h2E, 8'h36, 8'h3D, 8'h3E, 8'h46, 8'h45,
        8'h1C, 8'h32, 8'h21, 8'h23, 8'h24, 8'h2B, 8'h34, 8'h33, 8'h43, 8'h3B,
        8'h42, 8'h4B, 8'h3A, 8'h31, 8'h44, 8'h4D, 8'h15, 8'h2D, 8'h1B, 8'h2C,
        8'h3C, 8'h2A, 8'h1D, 8'h22, 8'h35, 8'h1A};
    logic [7:0] asc_tab [36] = '{
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
        "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
        "U", "V", "W", "X", "Y", "Z"};

    //----------------------------------------------------------------
    // estimulos e verificacao
    //----------------------------------------------------------------
    initial begin
        $display("=== Verificacao do ps2_driver ===");

        // T1: reset
        #100;
        check_result("T1 reset", (data_p == 8'h00) && (data_p_en == 1'b0),
                     $sformatf("data_p=0x%02h", data_p));
        @(negedge clock_in);
        reset_in = 1'b0;
        #1000;

        // T2: exemplo do enunciado (tecla A = 8'h1C)
        press_key("T2 tecla A", 8'h1C, "A", PS2_FAST);

        // T3: todas as teclas alfanumericas
        for (int i = 0; i < 36; i++)
            press_key("T3 alfanumerico", sc_tab[i], asc_tab[i], PS2_FAST);

        // T4: teclas com ASCII fora do alfanumerico
        press_key("T4 espaco",    8'h29, 8'h20, PS2_FAST);

        // T9: erro de paridade e de stop sao descartados
        no_output("T9 paridade errada", 8'h1C, 1'b1, 1'b0);
        no_output("T9 stop errado",     8'h1C, 1'b0, 1'b1);
        press_key("T9 recupera",        8'h1C, "A", PS2_FAST);

        // T10: quadro truncado e recuperado pelo timeout
        n_before = en_count;
        ps2_send(8'h1C, PS2_FAST, 1'b0, 1'b0, 5);
        #250000;
        check_result("T10 truncado", en_count == n_before, "gerou saida");
        press_key("T10 recupera", 8'h35, "Y", PS2_FAST);

        // T11: glitches curtos em clock_ps2 sao filtrados
        repeat (5) begin
            clock_ps2 = 1'b0; #30;
            clock_ps2 = 1'b1; #300;
        end
        press_key("T11 glitch + tecla", 8'h1A, "Z", PS2_FAST);

        // T12: teclado lento (12,5 kHz)
        press_key("T12 lento", 8'h3A, "M", PS2_SLOW);

        // T13: reset assincrono no meio do quadro
        press_key("T13 antes", 8'h45, "0", PS2_FAST);
        data_ps2  = 1'b0; #250;
        clock_ps2 = 1'b0; #500;
        clock_ps2 = 1'b1; #250;
        data_ps2  = 1'b1; #250;
        #3;                                 // fora da borda de clock_in
        reset_in = 1'b1;
        #1;
        check_result("T13 reset assincrono", (data_p == 8'h00) && (data_p_en == 1'b0),
                     $sformatf("data_p=0x%02h", data_p));
        #50;
        reset_in = 1'b0;
        #1000;
        press_key("T13 depois", 8'h16, "1", PS2_FAST);

        // resumo
        #1000;
        $display("=================================================");
        $display("Verificacoes: %0d  Erros: %0d", total, errors);
        if (errors == 0)
            $display("RESULTADO: TODOS OS TESTES PASSARAM");
        else
            $display("RESULTADO: HOUVE FALHAS");
        $display("=================================================");
        $stop;
    end

endmodule
