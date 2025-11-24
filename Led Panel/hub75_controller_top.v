// Módulo: hub75_controller_top.v
// Descripción: Integración de todos los módulos para controlar matriz LED 64x64 HUB75-E

module hub75_controller_top #(
    parameter MAX_DELAY = 80
)(
    input wire clk,              // Reloj del sistema
    input wire rst,              // Reset desde botón físico J28
    
    // Salidas HUB75
    output wire r0, g0, b0,      // Píxeles fila superior
    output wire r1, g1, b1,      // Píxeles fila inferior
    output wire [4:0] addr,      // Dirección de fila (A,B,C,D,E)
    output wire clk_out,         // Reloj de datos
    output wire latch,           // Latch (STB)
    output wire oe               // Output Enable (activo bajo)
);

    // Señales internas
    wire [5:0] select_col;
    wire [4:0] select_row;
    wire col_max, row_max;
    wire col_inc, row_inc;
    wire [23:0] pixel_data;
    wire [10:0] mem_addr;
    wire delay_start, delay_done;
    wire latch_set, latch_clr;
    wire oe_enable, oe_disable;
    
    
    
    // Dirección de memoria = {select_row[4:0], select_col[5:0]}
    assign mem_addr = {select_row, select_col};
    
    // Asignar dirección de fila a la salida
    assign addr = select_row;
    
    // Extraer componentes de 4 bits
    wire [3:0] r0_4bit = pixel_data[3:0];
    wire [3:0] g0_4bit = pixel_data[7:4];
    wire [3:0] b0_4bit = pixel_data[11:8];
    wire [3:0] r1_4bit = pixel_data[15:12];
    wire [3:0] g1_4bit = pixel_data[19:16];
    wire [3:0] b1_4bit = pixel_data[23:20];
    
    // Contador PWM para 4 bits (0-15)
    reg [3:0] pwm_counter = 4'd0;
    
    always @(posedge clk) begin
        if (rst)
            pwm_counter <= 4'd0;
        else
            pwm_counter <= pwm_counter + 1'b1;
    end
    
    // Generar salidas PWM
    assign r0 = (r0_4bit >= pwm_counter);
    assign g0 = (g0_4bit >= pwm_counter);
    assign b0 = (b0_4bit >= pwm_counter);
    assign r1 = (r1_4bit >= pwm_counter);
    assign g1 = (g1_4bit >= pwm_counter);
    assign b1 = (b1_4bit >= pwm_counter);
    
    // Reloj de salida (puede ser el mismo clk o dividido)
    assign clk_out = clk;
    
    // Instancia de ROM de imagen
    image_rom #(
        .ADDR_WIDTH(11),
        .DATA_WIDTH(24)
    ) img_rmm (
        .clk(clk),
        .addr(mem_addr),
        .data(pixel_data)
    );
    
    // Instancia de contadores
    scan_counters counters (
        .clk(clk),
        .rst(rst),
        .col_inc(col_inc),
        .row_inc(row_inc),
        .select_col(select_col),
        .select_row(select_row),
        .col_max(col_max),
        .row_max(row_max)
    );
    
    // Instancia de control de timing
    timing_controller #(
        .MAX_DELAY(MAX_DELAY)
    ) timing (
        .clk(clk),
        .rst(rst),
        .delay_start(delay_start),
        .latch_set(latch_set),
        .latch_clr(latch_clr),
        .oe_enable(oe_enable),
        .oe_disable(oe_disable),
        .latch(latch),
        .oe(oe),
        .delay_done(delay_done)
    );
    
    // Instancia de máquina de estados
    hub75_fsm fsm (
        .clk(clk),
        .rst(rst),
        .col_max(col_max),
        .row_max(row_max),
        .delay_done(delay_done),
        .col_inc(col_inc),
        .row_inc(row_inc),
        .delay_start(delay_start),
        .latch_set(latch_set),
        .latch_clr(latch_clr),
        .oe_enable(oe_enable),
        .oe_disable(oe_disable)
    );

endmodule
