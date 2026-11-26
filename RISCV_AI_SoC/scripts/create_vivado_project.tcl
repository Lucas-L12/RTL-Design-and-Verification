# Crea el proyecto Vivado de RISCV_AI_SoC referenciando los ficheros del repo (sin copiarlos).
# Uso (desde cualquier carpeta):  vivado -mode batch -source scripts/create_vivado_project.tcl
#   o en la GUI: Tools > Run Tcl Script...
set root [file normalize [file join [file dirname [info script]] ..]]
set proj_dir [file join $root vivado]
create_project -force RISCV_AI_SoC $proj_dir -part xc7a12ticsg325-1L

# --- Diseño ---
set rtl [concat \
    [glob $root/rtl/core/picorv32.v] \
    [glob $root/rtl/memory/*.sv] \
    [glob $root/rtl/bus/*.sv] \
    [glob $root/rtl/accelerator/*.sv] \
    [list $root/rtl/top.sv]]
add_files -norecurse -fileset sources_1 $rtl
set_property file_type SystemVerilog [get_files *.sv]
set_property top top [get_filesets sources_1]

# --- Constraints ---
add_files -norecurse -fileset constrs_1 $root/constraints/top.xdc

# --- Simulación ---
add_files -norecurse -fileset sim_1 [concat \
    [glob $root/sim/tb_*.sv] \
    [list $root/sw/firmware.mem $root/sim/data/image.mem $root/sim/data/expected_output.mem]]
set_property file_type SystemVerilog [get_files -of_objects [get_filesets sim_1] *.sv]
set_property top tb_wrapper [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "Proyecto creado en $proj_dir  (top=top, sim top=tb_wrapper)"
