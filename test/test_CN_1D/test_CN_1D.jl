# for development purposes only:
using Revise
# include("C:/Users/istok/Programming/Julia/PoseidonMRV/src/utils/Utils.jl")

# Script begins here:
using YAML

# include("C:/Users/istok/Programming/Julia/PoseidonMRV/src/PoseidonMRV.jl")
# using ..src.PoseidonMRV

# Add PoseidonMRV module to the LOAD_PATH
push!(LOAD_PATH, "C:/Users/istok/Programming/Julia/PoseidonMRV")
using PoseidonMRV

# Load configuration
# config_file_path = "C:/Users/istok/Programming/Julia/PoseidonMRV/test/test_CN_1D/test_config_CN_1D.yaml"
config_file_path = "test_config_CN_1D.yaml"
config = PoseidonMRV.Utils.load_config(config_file_path)

# Extract properties from configuration file
co2sys_params = config["co2sys_params"]
ocn_props_config = config["ocn_props"]
atm_props_config = config["atm_props"]
pert_props = config["pert_props"]
depth_grid_config = config["depth_grid"]
timestepping_config = config["timestepping"]

# Generate grid, timestepping, ICs, output config, ocn&atm properties
grid                = PoseidonMRV.Grids.generate_grid_1D(depth_grid_config["max_depth"], depth_grid_config["dz"])
time_steps          = PoseidonMRV.TimeStepping.generate_timestepping(timestepping_config["sim_duration_days"], timestepping_config["timestep"])
initial_conditions  = PoseidonMRV.InitialConditions.generate_initial_conditions_1D(pert_props, grid.nz)
output_config       = PoseidonMRV.OutputConfig.generate_output_config_CN_1D(timestepping_config["save_interval_hours"], time_steps.dt, time_steps.Tend)
ocn_props           = PoseidonMRV.OcnProperties.generate_oceanographic_properties_1D(ocn_props_config, grid.z, time_steps.nt)
atm_props           = PoseidonMRV.AtmProperties.generate_atmospheric_properties_1D(atm_props_config)

# Call perform_calculations with necessary inputs
ALK, DIC, pH, pCO2, ΔpCO2, F, tiF = PoseidonMRV.Models.CrankNicholson1D.timestep!(
    grid,
    time_steps,
    initial_conditions,
    output_config,
    ocn_props,
    atm_props,
    pert_props,
    co2sys_params
)
println("Crank-Nicholson Ran Successfully")

# Add a visualization to make sure results arent garbage

# Visualize results
PoseidonMRV.Visualize.plot_results(ALK, DIC, pH, pCO2, ΔpCO2, F, tiF, grid.z, time_steps.ti)
