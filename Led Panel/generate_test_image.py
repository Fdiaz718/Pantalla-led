#!/usr/bin/env python3
"""
Script para generar archivo .hex de prueba para matriz LED 64x64
Formato: {R1,G1,B1,R0,G0,B0} por cada dirección
"""

import argparse
import sys

def generate_test_pattern(pattern_type='gradient'):
    """
    Genera datos de imagen para 32 filas x 64 columnas
    Formato 12bpp: 4 bits R, 4 bits G, 4 bits B por píxel
    24 bits por entrada: {R1[3:0],G1[3:0],B1[3:0],R0[3:0],G0[3:0],B0[3:0]}
    """
    data = []
    
    for row in range(32):  # 32 filas de escaneo
        for col in range(64):  # 64 columnas
            if pattern_type == 'gradient':
                # Gradiente horizontal con 16 niveles (4 bits)
                if col < 21:
                    r, g, b = 15, 0, 0   # Rojo
                elif col < 42:
                    r, g, b = 0, 15, 0   # Verde
                else:
                    r, g, b = 0, 0, 15   # Azul
                    
                # Gradiente de brillo por fila
                brightness = (row * 15) // 31
                r = (r * brightness) // 15
                g = (g * brightness) // 15
                b = (b * brightness) // 15
                
            elif pattern_type == 'checkerboard':
                # Patrón de tablero
                if (row + col) % 2 == 0:
                    r, g, b = 15, 15, 15  # Blanco
                else:
                    r, g, b = 0, 0, 0      # Negro
                    
            elif pattern_type == 'stripes':
                # Franjas verticales RGB
                if col < 21:
                    r, g, b = 15, 0, 0  # Rojo
                elif col < 42:
                    r, g, b = 0, 15, 0  # Verde
                else:
                    r, g, b = 0, 0, 15  # Azul
                    
            elif pattern_type == 'all_white':
                r, g, b = 15, 15, 15
                
            elif pattern_type == 'all_black':
                r, g, b = 0, 0, 0
                
            else:
                # Patrón de prueba
                r = col % 16
                g = row % 16
                b = (col + row) % 16
            
            # Mismo color para píxel superior e inferior (0 y 1)
            # Formato: R1(4) G1(4) B1(4) R0(4) G0(4) B0(4) = 24 bits
            pixel = (r << 20) | (g << 16) | (b << 12) | (r << 8) | (g << 4) | b
            data.append(pixel)
    
    return data

def write_hex_file(data, filename):
    """Escribe los datos en formato hexadecimal (24 bits = 6 dígitos hex)"""
    with open(filename, 'w') as f:
        for value in data:
            f.write(f"{value:06X}\n")  # 6 dígitos hex para 24 bits
    print(f"✓ Archivo generado: {filename}")
    print(f"  Total de píxeles: {len(data)}")
    print(f"  Formato: 12bpp (4 bits por color)")
    print(f"  Tamaño: {len(data) * 3} bytes")

def main():
    parser = argparse.ArgumentParser(
        description='Genera archivo .hex para matriz LED 64x64'
    )
    parser.add_argument(
        '-o', '--output',
        default='image.hex',
        help='Archivo de salida (default: image.hex)'
    )
    parser.add_argument(
        '-p', '--pattern',
        choices=['gradient', 'checkerboard', 'stripes', 'frame', 'all_white', 'all_black'],
        default='gradient',
        help='Tipo de patrón a generar'
    )
    
    args = parser.parse_args()
    
    print(f"Generando patrón: {args.pattern}")
    data = generate_test_pattern(args.pattern)
    write_hex_file(data, args.output)
    
    # Mostrar primeros bytes como ejemplo
    print("\nPrimeros 8 bytes:")
    for i in range(min(8, len(data))):
        print(f"  [{i:04d}] 0x{data[i]:02X} = {data[i]:06b}")

if __name__ == '__main__':
    main()
