# for development purposes only:
using Revise

# Script begins here:
using YAML

# Add PoseidonMRV module to the LOAD_PATH
push!(LOAD_PATH, "C:/Users/istok/Programming/Julia/PoseidonMRV/src")
using PoseidonMRV

# Load configuration
config_file_path = "test/test_CN_1D/test_config_CN_1D.yaml"
config = PoseidonMRV.Utils.load_config(config_file_path)

# Extract properties from configuration file
co2sys_params = config["co2sys_params"]
ocn_props_config = config["ocn_props"]
atm_props_config = config["atm_props"]
pert_props = config["pert_props"]
depth_grid_config = config["depth_grid"]
timestepping_config = config["timestepping"]

# Generate grid, timestepping, output config, ocn&atm properties
grid                = PoseidonMRV.Grids.generate_grid_1D(depth_grid_config["max_depth"], depth_grid_config["dz"])
time_steps          = PoseidonMRV.TimeStepping.generate_timestepping(timestepping_config["sim_duration_days"], timestepping_config["timestep"])
output_config       = PoseidonMRV.OutputConfig.generate_output_config_CN_1D(timestepping_config["save_interval_hours"], timestepping_config["timestep"], timestepping_config["sim_duration_days"])
ocn_props           = PoseidonMRV.OcnProperties.generate_ocn_properties_1D(ocn_props_config, grid.z, time_steps.nt)
atm_props           = PoseidonMRV.AtmProperties.generate_atm_properties_1D(atm_props_config)

# Generate ICs - Options are 'unperturbed', 'surface_step', 'depth_step', 'gaussian'
initial_conditions  = PoseidonMRV.InitialConditions.generate_initial_conditions_1D(pert_props, grid, ocn_props_config; case = "surface_step")
println("everything generated")

# Call perform_calculations with necessary inputs
ALK, DIC, pH, pCO2, ΔpCO2, F, tiF, rho_matrix, kg_m_per_s = PoseidonMRV.CrankNicholson1D.timestep!(
    initial_conditions,
    grid,
    time_steps,
    output_config,
    ocn_props,
    atm_props,
    pert_props,
    co2sys_params
)
println("Crank-Nicholson Ran Successfully")

# Visualize results
# Initialize the figure with a two-panel layout
plt = plot(layout=(3, 1),  # Two rows, one column
    size=(800, 800),        # Adjust size for better visibility
)

# Plot Surface DIC in the top panel
plot!(plt[1], TI / 86400, DIC[end,:], label=label_text,
    xlabel="Time (days)", ylabel="DIC (μmol/kgSW)", title="Surface DIC over time",
    linewidth=2, legend=:topleft)

# Plot surface pCO2 in the middle panel
plot!(plt[2], TI / 86400, pCO2[end,:], label=label_text,
    xlabel="Time (days)", ylabel="pCO₂ (μatm)", title="Surface pCO₂ Over Time",
    linewidth=2, legend=:topleft)

# Plot ΔpCO2 in the bottom panel
plot!(plt[2], TI / 86400, ΔpCO2, label=label_text,
    xlabel="Time (days)", ylabel="pCO₂ (μatm)", title="Surface pCO₂ Over Time",
    linewidth=2, legend=:topleft)    

# Display the final two-panel plot
display(plt)
