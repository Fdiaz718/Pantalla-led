// Módulo: timing_controller_icn2038s.v
// Descripción: Controlador de timing específico para ICN2038S
// Maneja el comando DATA_LATCH (3 pulsos de CLK con LE=HIGH)

module timing_controller_icn2038s #(
    parameter MAX_DELAY = 100  // Delay entre frames
)(
    input wire clk,
    input wire rst,
    
    // Control de comandos
    input wire delay_start,      // Iniciar delay entre frames
    input wire latch_cmd_start,  // Iniciar comando DATA_LATCH (3 pulsos)
    input wire reg1_cmd_start,   // Iniciar comando WR_REG1 (11 pulsos)
    input wire reg2_cmd_start,   // Iniciar comando WR_REG2 (12 pulsos)
    
    // Control directo de OE
    input wire oe_enable,        // Habilitar salida (OE=0)
    input wire oe_disable,       // Deshabilitar salida (OE=1)
    
    // Salidas
    output reg latch,            // LE (Latch Enable) para ICN2038S
    output reg clk_out,          // CLK para comando latch
    output reg oe,               // Output Enable (activo bajo)
    
    // Señales de estado
    output wire delay_done,      // Delay completado
    output wire latch_done,      // Comando latch completado
    output wire reg1_done,       // Comando REG1 completado
    output wire reg2_done        // Comando REG2 completado
);

    // ========================================
    // PARÁMETROS DE COMANDOS ICN2038S
    // ========================================
    localparam DATA_LATCH_PULSES = 3;   // 3 pulsos para DATA_LATCH
    localparam WR_REG1_PULSES = 11;     // 11 pulsos para WR_REG1
    localparam WR_REG2_PULSES = 12;     // 12 pulsos para WR_REG2
    
    // Estados del generador de pulsos
    localparam IDLE = 2'd0;
    localparam PULSE_HIGH = 2'd1;
    localparam PULSE_LOW = 2'd2;
    localparam DONE = 2'd3;
    
    // ========================================
    // CONTADOR DE DELAY
    // ========================================
    reg [$clog2(MAX_DELAY)-1:0] delay_counter;
    reg delay_active;
    
    assign delay_done = (delay_counter >= MAX_DELAY-1) && delay_active;
    
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
    
    // ========================================
    // GENERADOR DE COMANDOS LATCH
    // ========================================
    reg [1:0] cmd_state;
    reg [4:0] pulse_counter;     // Contador de pulsos (máx 12)
    reg [4:0] target_pulses;     // Número de pulsos objetivo
    reg cmd_active;
    
    assign latch_done = (cmd_state == DONE) && (target_pulses == DATA_LATCH_PULSES);
    assign reg1_done = (cmd_state == DONE) && (target_pulses == WR_REG1_PULSES);
    assign reg2_done = (cmd_state == DONE) && (target_pulses == WR_REG2_PULSES);
    
    always @(posedge clk) begin
        if (rst) begin
            cmd_state <= IDLE;
            pulse_counter <= 0;
            target_pulses <= 0;
            latch <= 1'b0;
            clk_out <= 1'b0;
            cmd_active <= 1'b0;
            
        end else begin
            case (cmd_state)
                IDLE: begin
                    latch <= 1'b0;
                    clk_out <= 1'b0;
                    pulse_counter <= 0;
                    cmd_active <= 1'b0;
                    
                    // Detectar inicio de comando
                    if (latch_cmd_start) begin
                        target_pulses <= DATA_LATCH_PULSES;
                        cmd_state <= PULSE_HIGH;
                        cmd_active <= 1'b1;
                        latch <= 1'b1;  // LE=HIGH durante comando
                    end else if (reg1_cmd_start) begin
                        target_pulses <= WR_REG1_PULSES;
                        cmd_state <= PULSE_HIGH;
                        cmd_active <= 1'b1;
                        latch <= 1'b1;
                    end else if (reg2_cmd_start) begin
                        target_pulses <= WR_REG2_PULSES;
                        cmd_state <= PULSE_HIGH;
                        cmd_active <= 1'b1;
                        latch <= 1'b1;
                    end
                end
                
                PULSE_HIGH: begin
                    // Flanco de subida de CLK
                    clk_out <= 1'b1;
                    cmd_state <= PULSE_LOW;
                end
                
                PULSE_LOW: begin
                    // Flanco de bajada de CLK
                    clk_out <= 1'b0;
                    pulse_counter <= pulse_counter + 1;
                    
                    // Verificar si completamos todos los pulsos
                    if (pulse_counter >= target_pulses - 1) begin
                        cmd_state <= DONE;
                    end else begin
                        cmd_state <= PULSE_HIGH;
                    end
                end
                
                DONE: begin
                    // Comando completado
                    latch <= 1'b0;  // LE=LOW
                    clk_out <= 1'b0;
                    cmd_state <= IDLE;
                end
                
                default: cmd_state <= IDLE;
            endcase
        end
    end
    
    // ========================================
    // CONTROL DE OE (Output Enable)
    // ========================================
    always @(posedge clk) begin
        if (rst)
            oe <= 1'b1;  // Deshabilitado por defecto (activo bajo)
        else if (oe_enable)
            oe <= 1'b0;  // Habilitar salida
        else if (oe_disable)
            oe <= 1'b1;  // Deshabilitar salida
    end

endmodule                delay_active <= 1'b0;
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
