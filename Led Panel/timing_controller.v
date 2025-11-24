// Módulo: timing_controller.v
// Descripción: Controla Delay, Latch y OE según tu máquina de estados

module timing_controller #(
    parameter MAX_DELAY = 100  // Ajustar según tu frecuencia de reloj
)(
    input wire clk,
    input wire rst,
    input wire delay_start,      // Iniciar delay
    input wire latch_set,        // Activar latch
    input wire latch_clr,        // Desactivar latch
    input wire oe_enable,        // Habilitar salida (OE=0)
    input wire oe_disable,       // Deshabilitar salida (OE=1)
    output reg latch,
    output reg oe,               // Output Enable (activo bajo)
    output wire delay_done       // Delay completado
);

    // Contador de delay
    reg [$clog2(MAX_DELAY)-1:0] delay_counter;
    reg delay_active;
    
    assign delay_done = (delay_counter >= MAX_DELAY-1) && delay_active;
    
    // Control de Delay
    always @(posedge clk) begin
        if (rst) begin
            delay_counter <= 0;
            delay_active <= 1'b0;
        end else if (delay_start) begin
            delay_counter <= 0;
            delay_active <= 1'b1;
        end else if (delay_active) begin
            if (delay_counter < MAX_DELAY-1)
                delay_counter <= delay_counter + 1'b1;
            else
                delay_active <= 1'b0;
        end
    end
    
    // Control de Latch
    always @(posedge clk) begin
        if (rst)
            latch <= 1'b0;
        else if (latch_set)
            latch <= 1'b1;
        else if (latch_clr)
            latch <= 1'b0;
    end
    
    // Control de OE (activo bajo)
    always @(posedge clk) begin
        if (rst)
            oe <= 1'b1;  // Deshabilitado por defecto
        else if (oe_enable)
            oe <= 1'b0;  // Habilitar salida
        else if (oe_disable)
            oe <= 1'b1;  // Deshabilitar salida
    end

endmodule
