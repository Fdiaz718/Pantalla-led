// Módulo: scan_counters.v
// Descripción: Contadores para filas (select_row) y columnas (select_col)

module scan_counters (
    input wire clk,
    input wire rst,
    input wire col_inc,           // Señal para incrementar columna
    input wire row_inc,           // Señal para incrementar fila
    output reg [5:0] select_col,  // 0-63 columnas
    output reg [4:0] select_row,  // 0-31 filas (scan 1/32)
    output wire col_max,          // select_col == 63
    output wire row_max           // select_row == 31
);

    // Señales de máximo
    assign col_max = (select_col == 6'd63);
    assign row_max = (select_row == 5'd31);
    
    // Contador de columnas
    always @(posedge clk) begin
        if (rst) begin
            select_col <= 6'd0;
        end else if (col_inc) begin
            if (col_max)
                select_col <= 6'd0;
            else
                select_col <= select_col + 1'b1;
        end
    end
    
    // Contador de filas
    always @(posedge clk) begin
        if (rst) begin
            select_row <= 5'd0;
        end else if (row_inc) begin
            if (row_max)
                select_row <= 5'd0;
            else
                select_row <= select_row + 1'b1;
        end
    end

endmodule
