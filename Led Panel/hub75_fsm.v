// Módulo: hub75_fsm.v
// Descripción: Máquina de estados basada en tus diagramas

module hub75_fsm (
    input wire clk,
    input wire rst,
    input wire col_max,           // select_col == 63
    input wire row_max,           // select_row == 31
    input wire delay_done,        // Delay completado
    output reg col_inc,           // Incrementar columna
    output reg row_inc,           // Incrementar fila  
    output reg delay_start,       // Iniciar delay
    output reg latch_set,
    output reg latch_clr,
    output reg oe_enable,
    output reg oe_disable
);

    // Estados según tus diagramas
    localparam IDLE   = 3'd0;
    localparam READ   = 3'd1;
    localparam COLUMN = 3'd2;
    localparam ROW    = 3'd3;
    localparam DELAY  = 3'd4;
    
    reg [2:0] state, next_state;
    
    // Registro de estado
    always @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    // Lógica de siguiente estado
    always @(*) begin
        // Valores por defecto
        next_state = state;
        col_inc = 1'b0;
        row_inc = 1'b0;
        delay_start = 1'b0;
        latch_set = 1'b0;
        latch_clr = 1'b0;
        oe_enable = 1'b0;
        oe_disable = 1'b0;
        
        case (state)
            IDLE: begin
                oe_disable = 1'b1;
                next_state = READ;
            end
            
            READ: begin
                // Leer datos de memoria
                next_state = COLUMN;
            end
            
            COLUMN: begin
                col_inc = 1'b1;
                if (col_max) begin
                    latch_set = 1'b1;
                    next_state = ROW;
                end else begin
                    next_state = READ;
                end
            end
            
            ROW: begin
                latch_clr = 1'b1;
                delay_start = 1'b1;
                next_state = DELAY;
            end
            
            DELAY: begin
                if (delay_done) begin
                    if (row_max) begin
                        next_state = IDLE;
                    end else begin
                        row_inc = 1'b1;
                        oe_enable = 1'b1;
                        next_state = READ;
                    end
                end
            end
            
            default: next_state = IDLE;
        endcase
    end

endmodule
