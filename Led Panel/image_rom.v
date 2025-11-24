// Módulo: image_rom.v
// Descripción: ROM que contiene los datos de la imagen en formato HEX
// Para matriz 64x64 con 12bpp (4 bits por color R,G,B)

module image_rom #(
    parameter ADDR_WIDTH = 11,  // 32 filas * 64 columnas = 2048 direcciones
    parameter DATA_WIDTH = 24   // 12 bits para píxel superior + 12 bits para píxel inferior
)(
    input wire clk,
    input wire [ADDR_WIDTH-1:0] addr,  // Dirección = {fila[4:0], columna[5:0]}
    output reg [DATA_WIDTH-1:0] data   // {R1[3:0],G1[3:0],B1[3:0],R0[3:0],G0[3:0],B0[3:0]}
);

    // Memoria ROM - inicializada desde archivo .hex
    reg [DATA_WIDTH-1:0] rom [0:(1<<ADDR_WIDTH)-1];
    
    // Inicialización de la memoria desde archivo
    initial begin
        $readmemh("image.hex", rom);
    end
    
    // Lectura síncrona
    always @(posedge clk) begin
        data <= rom[addr];
    end

endmodule
