# Define the compiler and simulation tools
VCS = vcs
VCS_FLAGS = -full64 -debug_all -sverilog

# Define the top-level testbench
TB = top_tb

# Define the source files
SRCS = \
    top.v \
    driver.sv \
    environment.sv \
    generator.sv \
    interface.sv \
    monitor.sv \
    scoreboard.sv \
    test.sv \
    top_tb.sv \
    top_tb_direct.sv

# Define the include directories
INCLUDES = \
    -I.

# Define the output directory
OUT_DIR = ./output

# Define the rules
all: compile run

compile:
	@mkdir -p $(OUT_DIR)
	$(VCS) $(VCS_FLAGS) $(INCLUDES) $(SRCS) -o $(OUT_DIR)/$(TB).sim

run:
	@mkdir -p $(OUT_DIR)
	$(OUT_DIR)/$(TB).sim

clean:
	@rm -rf $(OUT_DIR)
	@rm -f *.vpd *.vcd

.PHONY: all compile run clean
