# for development purposes only:
using Revise

# Script begins here:
using YAML
using Plots
using Printf
using Profile, ProfileView
using JLD2

# Add PoseidonMRV module to the LOAD_PATH
# Edit this to wherever you have the main package folder saved. Mine is:
push!(LOAD_PATH, "C:/Users/istok/Programming/Julia/PoseidonMRV/src")
using PoseidonMRV

# Load configuration
config_file_path    = "examples/CN_1D_examples2/example_config_CN_1D.yaml"
config              = PoseidonMRV.Utils.load_config(config_file_path)

# Extract properties from configuration file
co2sys_params       = config["co2sys_params"]
ocn_props_config    = config["ocn_props"]
atm_props_config    = config["atm_props"]
pert_props          = config["pert_props"]
depth_grid_config   = config["depth_grid"]
timestepping_config = config["timestepping"]

# Generate grid, timestepping, output config, ocn&atm properties
grid                = PoseidonMRV.Grids.generate_grid_1D(depth_grid_config["max_depth"], depth_grid_config["dz"])
time_steps          = PoseidonMRV.TimeStepping.generate_timestepping(timestepping_config["sim_duration_days"], timestepping_config["timestep"])
output_config       = PoseidonMRV.OutputConfig.generate_output_config_CN_1D(timestepping_config["save_interval_hours"], timestepping_config["timestep"], timestepping_config["sim_duration_days"])
ocn_props           = PoseidonMRV.OcnProperties.generate_ocn_properties_1D(ocn_props_config, grid.z, time_steps.nt)
atm_props           = PoseidonMRV.AtmProperties.generate_atm_properties_1D(atm_props_config)

# Generate ICs - Options are 'unperturbed', 'surface_step', 'depth_step', 'gaussian'
initial_conditions_unperturbed  = PoseidonMRV.InitialConditions.generate_initial_conditions_1D(pert_props, grid, ocn_props_config; case = "unperturbed")
initial_conditions_perturbed  = PoseidonMRV.InitialConditions.generate_initial_conditions_1D(pert_props, grid, ocn_props_config; case = "surface_step")
println("grid and initial conditions generated")

# Call model with necessary inputs for unperturbed case
ALK_up, DIC_up, pH_up, pCO2_up, ΔpCO2_up, F_up, tiF_up, rho_matrix_up, kg_m_per_s = PoseidonMRV.CrankNicholson1D.timestep!(
    initial_conditions_unperturbed,
    grid,
    time_steps,
    output_config,
    ocn_props,
    atm_props,
    pert_props,
    co2sys_params
)
println("Unperturbed Crank-Nicholson Ran Successfully")

# Call model with necessary inputs for perturbed case
ALK_p, DIC_p, pH_p, pCO2_p, ΔpCO2_p, F_p, tiF_p, rho_matrix_p, kg_m_per_s = PoseidonMRV.CrankNicholson1D.timestep!(
    initial_conditions_perturbed,
    grid,
    time_steps,
    output_config,
    ocn_props,
    atm_props,
    pert_props,
    co2sys_params
)
println("Perturbed Crank-Nicholson Ran Successfully")

# need line of code extracting case-type from provided conditions.
if pert_props["dic_pert"] == ocn_props_config["dic_sw"] && pert_props["alk_pert"] == ocn_props_config["alk_sw"]
    efficiency_case = "unperturbed"
    max_efficiency = 0
elseif pert_props["dic_pert"] != ocn_props_config["dic_sw"] && pert_props["alk_pert"] == ocn_props_config["alk_sw"]
    efficiency_case = "doc"
    max_efficiency = PoseidonMRV.CalcDrawdown.calc_max_efficiency(ALK_up, ALK_p, DIC_p, rho_matrix_p, grid, ocn_props, co2sys_params; case = efficiency_case)
elseif pert_props["dic_pert"] == ocn_props_config["dic_sw"] && pert_props["alk_pert"] != ocn_props_config["alk_sw"]
    efficiency_case = "oae"
    max_efficiency = PoseidonMRV.CalcDrawdown.calc_max_efficiency(ALK_up, ALK_p, DIC_p, rho_matrix_p, grid, ocn_props, co2sys_params; case = efficiency_case)
elseif pert_props["dic_pert"] != ocn_props_config["dic_sw"] && pert_props["alk_pert"] != ocn_props_config["alk_sw"]
    efficiency_case = "mixed"
    max_efficiency = PoseidonMRV.CalcDrawdown.calc_max_efficiency(ALK_up, ALK_p, DIC_p, rho_matrix_p, grid, ocn_props, co2sys_params; case = efficiency_case)
end
    
# Calculate and compare carbon uptake over time, unperturbed case
drawdown_flux_interp_up, drawdown_dic_up, drawdown_difference_up, drawdown_relative_difference_up = PoseidonMRV.CalcDrawdown.compare_drawdown_flux_vs_dic_1D(
    F_up,
    tiF_up,
    time_steps.dt,
    DIC_up,
    rho_matrix_up,
    output_config.TI,
    grid
)

# Calculate and compare carbon uptake over time, perturbed case
drawdown_flux_interp_p, drawdown_dic_p, drawdown_difference_p, drawdown_relative_difference_p = PoseidonMRV.CalcDrawdown.compare_drawdown_flux_vs_dic_1D(
    F_p,
    tiF_p,
    time_steps.dt,
    DIC_p,
    rho_matrix_p,
    output_config.TI,
    grid
)

# Verify that the calculations from flux and DIC are comparable. 
threshold = 1.0 # percent diff for error, e.g. if >1% difference, review the sim output

# Report the threshold and maximum values of drawdown relative differences
println("Threshold percent, perturbed case: ", threshold)
println("Max value of drawdown_relative_difference_up: ", PoseidonMRV.Utils.max_non_nan(drawdown_relative_difference_up))
println("Max value of drawdown_relative_difference_p: ", PoseidonMRV.Utils.max_non_nan(drawdown_relative_difference_p))

if any(x -> x > threshold, drawdown_relative_difference_up) || any(x -> x > threshold, drawdown_relative_difference_p)
    println("WARNING: Calculations of drawdown from flux and DIC are not consistent. Check resolution and review model output, or consider adjusting threshold.")
end

# Calculate additionality (difference between perturbed and unperturbed cases)
additionality_dic = drawdown_dic_p .- drawdown_dic_up
additionality_flux = drawdown_flux_interp_p .- drawdown_flux_interp_up

# Visualize results
PoseidonMRV.Visualize.plot_profiles(ALK_p, DIC_p, pH_p, pCO2_p, ΔpCO2_p, F_p, tiF_p, grid.z, output_config.TI)
# PoseidonMRV.Visualize.plot_drawdown(output_config.TI, drawdown_dic_p, drawdown_flux_interp_p, drawdown_difference_p, drawdown_relative_difference_p)
PoseidonMRV.Visualize.plot_additionality(output_config.TI, additionality_dic, additionality_flux)

# Choose the more conservative results
if additionality_dic[end] < additionality_flux[end]
    additionality = additionality_dic
else
    additionality = additionality_flux
end

# Collect results into a dictionary
simulation_results = Dict(
    "input" => Dict(
        # "diffusivity" => diffusivity,
        "config" => config
    ),   
    "output" => Dict(
        "ALK_p" => ALK_p,
        "DIC_p" => DIC_p,
        "DIC_up" => DIC_up,
        "pCO2_p" => pCO2_p,
        "pH_p" => pH_p,
        "ΔpCO2_p" => ΔpCO2_p,
        "TI" => output_config.TI,
        "z" => grid.z,
        "additionality" => additionality,
        "additionality_flux" => additionality_flux,
        "additionality_dic" => additionality_dic,
        "kg_m_per_s" => kg_m_per_s
    ) 
)

# Save results
diffusivity = config["ocn_props"]["vertical_diffusivity_ML"]
setup = config["setup"]

# Format diffusivity and dilution for directory and file naming
formatted_diffusivity = Printf.@sprintf("%.0e", diffusivity)  # e.g., "1e-03"
formatted_diffusivity = replace(formatted_diffusivity, "-" => "minus")  # Replace negative sign for file safety
formatted_dilution = string(pert_props["dilution"])  # Convert dilution ratio to string

# Define output directory, including setup and efficiency case
output_dir = "results/data/for_ms/$(setup)_$(efficiency_case)/diffusivity_$(formatted_diffusivity)"
mkpath(output_dir)  # Create the directory structure if it doesn't exist

# Define output file path, including formatted dilution value
output_file = joinpath(output_dir, "results_dilution_$(formatted_dilution).jld2")
JLD2.@save output_file simulation_results