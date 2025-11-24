# Makefile para proyecto HUB75 con FPGA ECP5 (5A-75E)

# Configuración del proyecto
PROJECT = hub75_controller
TOP_MODULE = test_leds
TESTBENCH = hub75_tb

# Archivos fuente
SOURCES = test_leds.v

# Directorio de construcción
BUILD_DIR = build

# Herramientas
YOSYS = yosys
NEXTPNR = nextpnr-ecp5
ECPPACK = ecppack
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Configuración FPGA (5A-75E v8.2)
DEVICE = 25k
PACKAGE = CABGA256
SPEED = 7

# Archivo de restricciones
LPF_FILE = constraints_5a75e_v82_j16.lpf

# Colores para output
COLOR_RESET = \033[0m
COLOR_GREEN = \033[32m
COLOR_YELLOW = \033[33m
COLOR_BLUE = \033[34m

.PHONY: all clean sim view synth pnr bitstream program dirs test

# Target principal
all: dirs bitstream

# Crear directorios
dirs:
	@echo "$(COLOR_BLUE)Creando directorios...$(COLOR_RESET)"
	@mkdir -p $(BUILD_DIR)

# Generar archivo de imagen de prueba
$(BUILD_DIR)/image.hex:
	@echo "$(COLOR_YELLOW)Generando archivo de imagen de prueba...$(COLOR_RESET)"
	@python3 generate_test_image.py -o $(BUILD_DIR)/image.hex

# Simulación con Icarus Verilog
sim: dirs $(BUILD_DIR)/image.hex
	@echo "$(COLOR_BLUE)Compilando simulación...$(COLOR_RESET)"
	$(IVERILOG) -o $(BUILD_DIR)/$(TESTBENCH).vvp -s $(TESTBENCH) \
		$(TESTBENCH).v $(SOURCES) -DSIMULATION
	@echo "$(COLOR_GREEN)Ejecutando simulación...$(COLOR_RESET)"
	cd $(BUILD_DIR) && $(VVP) $(TESTBENCH).vvp

# Visualizar forma de onda
view: sim
	@echo "$(COLOR_BLUE)Abriendo GTKWave...$(COLOR_RESET)"
	$(GTKWAVE) $(BUILD_DIR)/$(TESTBENCH).vcd &

# Síntesis con Yosys
synth: dirs
	@echo "$(COLOR_BLUE)Iniciando síntesis con Yosys...$(COLOR_RESET)"
	$(YOSYS) -p "read_verilog $(SOURCES); \
	            synth_ecp5 -top $(TOP_MODULE) -json $(BUILD_DIR)/$(PROJECT).json" \
	            -l $(BUILD_DIR)/yosys.log
	@echo "$(COLOR_GREEN)Síntesis completada!$(COLOR_RESET)"

# Place and Route con nextpnr
pnr: synth
	@echo "$(COLOR_BLUE)Iniciando Place & Route con nextpnr...$(COLOR_RESET)"
	$(NEXTPNR) --$(DEVICE) --package $(PACKAGE) --speed $(SPEED) \
	           --json $(BUILD_DIR)/$(PROJECT).json \
	           --lpf $(LPF_FILE) \
	           --textcfg $(BUILD_DIR)/$(PROJECT).config \
	           --log $(BUILD_DIR)/nextpnr.log
	@echo "$(COLOR_GREEN)Place & Route completado!$(COLOR_RESET)"

# Generar bitstream
bitstream: pnr
	@echo "$(COLOR_BLUE)Generando bitstream...$(COLOR_RESET)"
	$(ECPPACK) --compress --svf $(BUILD_DIR)/$(PROJECT).svf \
	           $(BUILD_DIR)/$(PROJECT).config \
	           $(BUILD_DIR)/$(PROJECT).bit
	@echo "$(COLOR_GREEN)Bitstream generado: $(BUILD_DIR)/$(PROJECT).bit$(COLOR_RESET)"

# Programar FPGA (usando openFPGALoader con ft232RL)
program: bitstream
	@echo "$(COLOR_BLUE)Programando FPGA...$(COLOR_RESET)"
	openFPGALoader --cable ft232RL --pins=0:3:4:1 --freq 3000000 -b colorlight $(BUILD_DIR)/$(PROJECT).bit
	@echo "$(COLOR_GREEN)FPGA programada!$(COLOR_RESET)"
	
# Test completo: simulación + síntesis
test: sim synth
	@echo "$(COLOR_GREEN)Test completo finalizado!$(COLOR_RESET)"

# Estadísticas del diseño
stats: synth
	@echo "$(COLOR_BLUE)=== Estadísticas del Diseño ===$(COLOR_RESET)"
	@grep -A 20 "Printing statistics" $(BUILD_DIR)/yosys.log

# Timing report
timing: pnr
	@echo "$(COLOR_BLUE)=== Reporte de Timing ===$(COLOR_RESET)"
	@grep -A 10 "Critical path" $(BUILD_DIR)/nextpnr.log

# Limpiar archivos generados
clean:
	@echo "$(COLOR_YELLOW)Limpiando archivos generados...$(COLOR_RESET)"
	rm -rf $(BUILD_DIR)
	rm -f *.vcd *.vvp
	@echo "$(COLOR_GREEN)Limpieza completada!$(COLOR_RESET)"

# Ayuda
help:
	@echo "$(COLOR_BLUE)=== Makefile para HUB75 Controller ===$(COLOR_RESET)"
	@echo ""
	@echo "Targets disponibles:"
	@echo "  $(COLOR_GREEN)make all$(COLOR_RESET)       - Compilar todo y generar bitstream"
	@echo "  $(COLOR_GREEN)make sim$(COLOR_RESET)       - Ejecutar simulación con Icarus Verilog"
	@echo "  $(COLOR_GREEN)make view$(COLOR_RESET)      - Ver forma de onda con GTKWave"
	@echo "  $(COLOR_GREEN)make synth$(COLOR_RESET)     - Solo síntesis (Yosys)"
	@echo "  $(COLOR_GREEN)make pnr$(COLOR_RESET)       - Place & Route (nextpnr)"
	@echo "  $(COLOR_GREEN)make bitstream$(COLOR_RESET) - Generar bitstream (ecppack)"
	@echo "  $(COLOR_GREEN)make program$(COLOR_RESET)   - Programar FPGA"
	@echo "  $(COLOR_GREEN)make test$(COLOR_RESET)      - Simulación + Síntesis"
	@echo "  $(COLOR_GREEN)make stats$(COLOR_RESET)     - Ver estadísticas del diseño"
	@echo "  $(COLOR_GREEN)make timing$(COLOR_RESET)    - Ver reporte de timing"
	@echo "  $(COLOR_GREEN)make clean$(COLOR_RESET)     - Limpiar archivos generados"
	@echo ""

