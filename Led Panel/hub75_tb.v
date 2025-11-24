// Módulo: hub75_tb.v
// Descripción: Testbench para simular el controlador HUB75

`timescale 1ns/1ps

module hub75_tb;

    // Parámetros
    parameter CLK_PERIOD = 40;  // 25 MHz
    parameter MAX_DELAY = 10;   // Delay corto para simulación
    
    // Señales del DUT
    reg clk;
    reg rst;
    wire r0, g0, b0;
    wire r1, g1, b1;
    wire [4:0] addr;
    wire clk_out;
    wire latch;
    wire oe;
    
    // Contadores para verificación
    integer cycle_count;
    integer pixel_count;
    
    // Instancia del DUT
    hub75_controller_top #(
        .MAX_DELAY(MAX_DELAY)
    ) dut (
        .clk(clk),
        .rst(rst),        // ← Asegúrate que esté conectado
        .r0(r0), .g0(g0), .b0(b0),
        .r1(r1), .g1(g1), .b1(b1),
        .addr(addr),
        .clk_out(clk_out),
        .latch(latch),
        .oe(oe)
    );
    
    // Generación de reloj
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Secuencia de reset y test
    initial begin
        // Inicialización
        rst = 1;
        cycle_count = 0;
        pixel_count = 0;
        
        // Crear archivo de imagen de prueba
        $display("=== Iniciando Test HUB75 Controller ===");
        $display("Tiempo: %0t", $time);
        
        // Reset
        #(CLK_PERIOD * 5);
        rst = 0;
        $display("[%0t] Reset liberado", $time);
        
        // Esperar varios frames completos
        #(CLK_PERIOD * 100);
        
        $display("\n=== Verificando señales de salida ===");
        check_signals();
        
        // Simular un frame completo (32 filas * 64 columnas)
        $display("\n=== Simulando frame completo ===");
        wait_full_frame();
        
        $display("\n=== Test completado exitosamente ===");
        $display("Total de ciclos: %0d", cycle_count);
        $display("Total de píxeles procesados: %0d", pixel_count);
        
        $finish;
    end
    
    // Monitor de señales
    initial begin
        $monitor("[%0t] addr=%0d, RGB0={%b,%b,%b}, RGB1={%b,%b,%b}, latch=%b, oe=%b", 
                 $time, addr, r0, g0, b0, r1, g1, b1, latch, oe);
    end
    
    // Detección de latch (indica fin de fila)
    always @(posedge latch) begin
        $display("[%0t] === LATCH activado - Fila %0d completada ===", $time, addr);
        pixel_count = pixel_count + 64;
    end
    
    // Contador de ciclos
    always @(posedge clk) begin
        if (!rst)
            cycle_count = cycle_count + 1;
    end
    
    // Tarea para verificar señales básicas
    task check_signals;
        begin
            $display("Verificando addr en rango [0:31]...");
            if (addr > 31) begin
                $display("ERROR: addr fuera de rango = %0d", addr);
                $finish;
            end else begin
                $display("OK: addr = %0d", addr);
            end
            
            $display("Verificando OE activo bajo...");
            if (oe === 1'bx) begin
                $display("ERROR: OE indefinido");
                $finish;
            end else begin
                $display("OK: OE = %b", oe);
            end
        end
    endtask
    
    // Tarea para esperar un frame completo
    task wait_full_frame;
        integer row_count;
        begin
            row_count = 0;
            // Esperar 32 pulsos de latch (una fila por pulso)
            repeat(32) begin
                @(posedge latch);
                row_count = row_count + 1;
                $display("Fila %0d/32 completada", row_count);
            end
            $display("Frame completo procesado: 32 filas × 64 columnas = 2048 píxeles");
        end
    endtask
    
    // Generar archivo VCD para visualización
    initial begin
        $dumpfile("hub75_tb.vcd");
        $dumpvars(0, hub75_tb);
    end
    
    // Timeout de seguridad
    initial begin
        #(CLK_PERIOD * 10000);
        $display("\n!!! TIMEOUT - La simulación tardó demasiado !!!");
        $finish;
    end

endmodule
