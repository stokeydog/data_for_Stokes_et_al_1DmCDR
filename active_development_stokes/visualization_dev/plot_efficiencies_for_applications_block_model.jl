using JLD2
using Plots
using PlotUtils
using PoseidonMRV
using Interpolations
using Measures
# using GRUtils
# using Makie

# Define a function to load data and extract variables
function load_simulation_data(file_path)
    data = JLD2.jldopen(file_path) do file
        read(file, "simulation_results")
    end
    # Extract relevant data
    DIC_p = data["output"]["DIC_p"]
    DIC_up = data["output"]["DIC_up"]
    pCO2_p = data["output"]["pCO2_p"]
    ΔpCO2 = data["output"]["ΔpCO2_p"]
    TI = data["output"]["TI"]
    z = data["output"]["z"]
    additionality = data["output"]["additionality"]
    additionality_flux = data["output"]["additionality_flux"]
    additionality_dic = data["output"]["additionality_dic"]
    return DIC_p, DIC_up, pCO2_p, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic
end


# Vector of file paths for different layer depths
file_paths_1m_layer = [
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_2eminus09/results_dilution_0.jld2",
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_4eminus08/results_dilution_1.jld2",
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_7eminus08/results_dilution_2.jld2",
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_1eminus07/results_dilution_5.jld2",
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_2eminus07/results_dilution_10.jld2",
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_2eminus07/results_dilution_20.jld2",
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_2eminus07/results_dilution_50.jld2",
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_2eminus07/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_3eminus07/results_dilution_200.jld2",
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_3eminus07/results_dilution_500.jld2",
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_3eminus07/results_dilution_1000.jld2",
]

file_paths_2m_layer = [
    "./results/inf_MLD_Bic_1_u6p63_2mEffLayer_variable_dilution_doc/diffusivity_5eminus09/results_dilution_0.jld2",
    "./results/inf_MLD_Bic_1_u6p63_2mEffLayer_variable_dilution_doc/diffusivity_8eminus08/results_dilution_1.jld2",
    "./results/inf_MLD_Bic_1_u6p63_2mEffLayer_variable_dilution_doc/diffusivity_1eminus07/results_dilution_2.jld2",
    "./results/inf_MLD_Bic_1_u6p63_2mEffLayer_variable_dilution_doc/diffusivity_3eminus07/results_dilution_5.jld2",
    "./results/inf_MLD_Bic_1_u6p63_2mEffLayer_variable_dilution_doc/diffusivity_4eminus07/results_dilution_10.jld2",
    "./results/inf_MLD_Bic_1_u6p63_2mEffLayer_variable_dilution_doc/diffusivity_4eminus07/results_dilution_20.jld2",
    "./results/inf_MLD_Bic_1_u6p63_2mEffLayer_variable_dilution_doc/diffusivity_5eminus07/results_dilution_50.jld2",
    "./results/inf_MLD_Bic_1_u6p63_2mEffLayer_variable_dilution_doc/diffusivity_5eminus07/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_1_u6p63_2mEffLayer_variable_dilution_doc/diffusivity_5eminus07/results_dilution_200.jld2",
    "./results/inf_MLD_Bic_1_u6p63_2mEffLayer_variable_dilution_doc/diffusivity_5eminus07/results_dilution_500.jld2",
    "./results/inf_MLD_Bic_1_u6p63_2mEffLayer_variable_dilution_doc/diffusivity_5eminus07/results_dilution_1000.jld2",
]

file_paths_3m_layer = [
    "./results/inf_MLD_Bic_1_u6p63_3mEffLayer_variable_dilution_doc/diffusivity_7eminus09/results_dilution_0.jld2",
    "./results/inf_MLD_Bic_1_u6p63_3mEffLayer_variable_dilution_doc/diffusivity_1eminus07/results_dilution_1.jld2",
    "./results/inf_MLD_Bic_1_u6p63_3mEffLayer_variable_dilution_doc/diffusivity_2eminus07/results_dilution_2.jld2",
    "./results/inf_MLD_Bic_1_u6p63_3mEffLayer_variable_dilution_doc/diffusivity_4eminus07/results_dilution_5.jld2",
    "./results/inf_MLD_Bic_1_u6p63_3mEffLayer_variable_dilution_doc/diffusivity_5eminus07/results_dilution_10.jld2",
    "./results/inf_MLD_Bic_1_u6p63_3mEffLayer_variable_dilution_doc/diffusivity_6eminus07/results_dilution_20.jld2",
    "./results/inf_MLD_Bic_1_u6p63_3mEffLayer_variable_dilution_doc/diffusivity_7eminus07/results_dilution_50.jld2",
    "./results/inf_MLD_Bic_1_u6p63_3mEffLayer_variable_dilution_doc/diffusivity_7eminus07/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_1_u6p63_3mEffLayer_variable_dilution_doc/diffusivity_8eminus07/results_dilution_200.jld2",
    "./results/inf_MLD_Bic_1_u6p63_3mEffLayer_variable_dilution_doc/diffusivity_8eminus07/results_dilution_500.jld2",
    "./results/inf_MLD_Bic_1_u6p63_3mEffLayer_variable_dilution_doc/diffusivity_8eminus07/results_dilution_1000.jld2",
]

file_paths_4m_layer = [
    "./results/inf_MLD_Bic_1_u6p63_4mEffLayer_variable_dilution_doc/diffusivity_1eminus08/results_dilution_0.jld2",
    "./results/inf_MLD_Bic_1_u6p63_4mEffLayer_variable_dilution_doc/diffusivity_2eminus07/results_dilution_1.jld2",
    "./results/inf_MLD_Bic_1_u6p63_4mEffLayer_variable_dilution_doc/diffusivity_3eminus07/results_dilution_2.jld2",
    "./results/inf_MLD_Bic_1_u6p63_4mEffLayer_variable_dilution_doc/diffusivity_5eminus07/results_dilution_5.jld2",
    "./results/inf_MLD_Bic_1_u6p63_4mEffLayer_variable_dilution_doc/diffusivity_7eminus07/results_dilution_10.jld2",
    "./results/inf_MLD_Bic_1_u6p63_4mEffLayer_variable_dilution_doc/diffusivity_8eminus07/results_dilution_20.jld2",
    "./results/inf_MLD_Bic_1_u6p63_4mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_50.jld2",
    "./results/inf_MLD_Bic_1_u6p63_4mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_1_u6p63_4mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_200.jld2",
    "./results/inf_MLD_Bic_1_u6p63_4mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_500.jld2",
    "./results/inf_MLD_Bic_1_u6p63_4mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_1000.jld2",
]

file_paths_5m_layer = [
    "./results/inf_MLD_Bic_1_u6p63_5mEffLayer_variable_dilution_doc/diffusivity_1eminus08/results_dilution_0.jld2",
    "./results/inf_MLD_Bic_1_u6p63_5mEffLayer_variable_dilution_doc/diffusivity_2eminus07/results_dilution_1.jld2",
    "./results/inf_MLD_Bic_1_u6p63_5mEffLayer_variable_dilution_doc/diffusivity_4eminus07/results_dilution_2.jld2",
    "./results/inf_MLD_Bic_1_u6p63_5mEffLayer_variable_dilution_doc/diffusivity_7eminus07/results_dilution_5.jld2",
    "./results/inf_MLD_Bic_1_u6p63_5mEffLayer_variable_dilution_doc/diffusivity_9eminus07/results_dilution_10.jld2",
    "./results/inf_MLD_Bic_1_u6p63_5mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_20.jld2",
    "./results/inf_MLD_Bic_1_u6p63_5mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_50.jld2",
    "./results/inf_MLD_Bic_1_u6p63_5mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_1_u6p63_5mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_200.jld2",
    "./results/inf_MLD_Bic_1_u6p63_5mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_500.jld2",
    "./results/inf_MLD_Bic_1_u6p63_5mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_1000.jld2",
]

file_paths_6m_layer = [
    "./results/inf_MLD_Bic_1_u6p63_6mEffLayer_variable_dilution_doc/diffusivity_1eminus08/results_dilution_0.jld2",
    "./results/inf_MLD_Bic_1_u6p63_6mEffLayer_variable_dilution_doc/diffusivity_2eminus07/results_dilution_1.jld2",
    "./results/inf_MLD_Bic_1_u6p63_6mEffLayer_variable_dilution_doc/diffusivity_4eminus07/results_dilution_2.jld2",
    "./results/inf_MLD_Bic_1_u6p63_6mEffLayer_variable_dilution_doc/diffusivity_8eminus07/results_dilution_5.jld2",
    "./results/inf_MLD_Bic_1_u6p63_6mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_10.jld2",
    "./results/inf_MLD_Bic_1_u6p63_6mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_20.jld2",
    "./results/inf_MLD_Bic_1_u6p63_6mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_50.jld2",
    "./results/inf_MLD_Bic_1_u6p63_6mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_1_u6p63_6mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_200.jld2",
    "./results/inf_MLD_Bic_1_u6p63_6mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_500.jld2",
    "./results/inf_MLD_Bic_1_u6p63_6mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_1000.jld2",
]

file_paths_7m_layer = [
    "./results/inf_MLD_Bic_1_u6p63_7mEffLayer_variable_dilution_doc/diffusivity_2eminus08/results_dilution_0.jld2",
    "./results/inf_MLD_Bic_1_u6p63_7mEffLayer_variable_dilution_doc/diffusivity_3eminus07/results_dilution_1.jld2",
    "./results/inf_MLD_Bic_1_u6p63_7mEffLayer_variable_dilution_doc/diffusivity_5eminus07/results_dilution_2.jld2",
    "./results/inf_MLD_Bic_1_u6p63_7mEffLayer_variable_dilution_doc/diffusivity_9eminus07/results_dilution_5.jld2",
    "./results/inf_MLD_Bic_1_u6p63_7mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_10.jld2",
    "./results/inf_MLD_Bic_1_u6p63_7mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_20.jld2",
    "./results/inf_MLD_Bic_1_u6p63_7mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_50.jld2",
    "./results/inf_MLD_Bic_1_u6p63_7mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_1_u6p63_7mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_200.jld2",
    "./results/inf_MLD_Bic_1_u6p63_7mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_500.jld2",
    "./results/inf_MLD_Bic_1_u6p63_7mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_1000.jld2",
]

file_paths_8m_layer = [
    "./results/inf_MLD_Bic_1_u6p63_8mEffLayer_variable_dilution_doc/diffusivity_2eminus08/results_dilution_0.jld2",
    "./results/inf_MLD_Bic_1_u6p63_8mEffLayer_variable_dilution_doc/diffusivity_3eminus07/results_dilution_1.jld2",
    "./results/inf_MLD_Bic_1_u6p63_8mEffLayer_variable_dilution_doc/diffusivity_6eminus07/results_dilution_2.jld2",
    "./results/inf_MLD_Bic_1_u6p63_8mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_5.jld2",
    "./results/inf_MLD_Bic_1_u6p63_8mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_10.jld2",
    "./results/inf_MLD_Bic_1_u6p63_8mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_20.jld2",
    "./results/inf_MLD_Bic_1_u6p63_8mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_50.jld2",
    "./results/inf_MLD_Bic_1_u6p63_8mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_1_u6p63_8mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_200.jld2",
    "./results/inf_MLD_Bic_1_u6p63_8mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_500.jld2",
    "./results/inf_MLD_Bic_1_u6p63_8mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_1000.jld2",
]

file_paths_9m_layer = [
    "./results/inf_MLD_Bic_1_u6p63_9mEffLayer_variable_dilution_doc/diffusivity_2eminus08/results_dilution_0.jld2",
    "./results/inf_MLD_Bic_1_u6p63_9mEffLayer_variable_dilution_doc/diffusivity_3eminus07/results_dilution_1.jld2",
    "./results/inf_MLD_Bic_1_u6p63_9mEffLayer_variable_dilution_doc/diffusivity_6eminus07/results_dilution_2.jld2",
    "./results/inf_MLD_Bic_1_u6p63_9mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_5.jld2",
    "./results/inf_MLD_Bic_1_u6p63_9mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_10.jld2",
    "./results/inf_MLD_Bic_1_u6p63_9mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_20.jld2",
    "./results/inf_MLD_Bic_1_u6p63_9mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_50.jld2",
    "./results/inf_MLD_Bic_1_u6p63_9mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_1_u6p63_9mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_200.jld2",
    "./results/inf_MLD_Bic_1_u6p63_9mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_500.jld2",
    "./results/inf_MLD_Bic_1_u6p63_9mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_1000.jld2",
]

file_paths_10m_layer = [
    "./results/inf_MLD_Bic_1_u6p63_10mEffLayer_variable_dilution_doc/diffusivity_2eminus08/results_dilution_0.jld2",
    "./results/inf_MLD_Bic_1_u6p63_10mEffLayer_variable_dilution_doc/diffusivity_4eminus07/results_dilution_1.jld2",
    "./results/inf_MLD_Bic_1_u6p63_10mEffLayer_variable_dilution_doc/diffusivity_7eminus07/results_dilution_2.jld2",
    "./results/inf_MLD_Bic_1_u6p63_10mEffLayer_variable_dilution_doc/diffusivity_1eminus06/results_dilution_5.jld2",
    "./results/inf_MLD_Bic_1_u6p63_10mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_10.jld2",
    "./results/inf_MLD_Bic_1_u6p63_10mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_20.jld2",
    "./results/inf_MLD_Bic_1_u6p63_10mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_50.jld2",
    "./results/inf_MLD_Bic_1_u6p63_10mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_1_u6p63_10mEffLayer_variable_dilution_doc/diffusivity_3eminus06/results_dilution_200.jld2",
    "./results/inf_MLD_Bic_1_u6p63_10mEffLayer_variable_dilution_doc/diffusivity_3eminus06/results_dilution_500.jld2",
    "./results/inf_MLD_Bic_1_u6p63_10mEffLayer_variable_dilution_doc/diffusivity_3eminus06/results_dilution_1000.jld2",
]

# get vectors of float64's
dilution_values = [0.0,1.0,2.0,5.0,10.0,20.0,50.0,100.0,200.0,500.0,1000.0]
layer_depths = [1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0]

# sim stuff...
sim_days = 100
sim_res = 3600 # hourly resolution
target_efficiency_idx = Int(sim_days * 86400 / sim_res + 1)

# Prepare data
final_efficiency = Matrix{Float64}(undef, length(layer_depths), length(dilution_values))
final_additionality = Matrix{Float64}(undef, length(layer_depths), length(dilution_values))

# vectorize file paths
all_file_paths = [
            file_paths_1m_layer, 
            file_paths_2m_layer, 
            file_paths_3m_layer, 
            file_paths_4m_layer, 
            file_paths_5m_layer, 
            file_paths_6m_layer,
            file_paths_7m_layer,
            file_paths_8m_layer,
            file_paths_9m_layer,
            file_paths_10m_layer,
]

# First, define arrays to hold the 1D data
n_depths    = length(layer_depths)
n_dilutions = length(dilution_values)

initial_deficit_1D = Matrix{Float64}(undef, n_depths, n_dilutions)
final_add_1D       = Matrix{Float64}(undef, n_depths, n_dilutions)

# Loop over all files to fill the arrays
for (row_i, paths_for_layer) in enumerate(all_file_paths)
    for (col_j, fp) in enumerate(paths_for_layer)
        DIC_p, DIC_up, pCO2_p, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(fp)

        # Suppose your domain has uniform vertical spacing:
        Δz  = abs(z[2] - z[1])
        rho = 1025

        # For time=0, total unperturbed DIC_up_0, DIC_p_0 in [mol/m^2]
        DIC_up_0 = sum(DIC_up[:,1]) * Δz * rho * 1e-6
        DIC_p_0  = sum(DIC_p[:,1])  * Δz * rho * 1e-6
        initial_deficit_1D[row_i, col_j] = DIC_up_0 - DIC_p_0  # [mol/m^2]

        # final additionality at 100 days (or your target)
        final_add_1D[row_i, col_j] = additionality_dic[target_efficiency_idx]  # [mol/m^2]
    end
end

# Build a 2D interpolant and interpolation function
depth_grid = layer_depths
dilution_grid = dilution_values

itp_add = interpolate(
    (depth_grid, dilution_grid),    # the coordinate tuples
    final_add_1D,                       # the matrix to interpolate
    Gridded(Linear())               # linear interpolation in both dims
)

function clamp_and_interpolate_add_1D(H_star::Float64, D_star::Float64)
    H_clamped = min(H_star, depth_grid[end])                  # e.g. clamp to 10
    D_clamped = min(D_star, dilution_grid[end])               # e.g. clamp to 1000
    return itp_add(H_clamped, D_clamped)  # yields a Float64
end

itp_def = interpolate(
    (depth_grid, dilution_grid),    # the coordinate tuples
    initial_deficit_1D,                       # the matrix to interpolate
    Gridded(Linear())               # linear interpolation in both dims
)

function clamp_and_interpolate_def_1D(H_star::Float64, D_star::Float64)
    H_clamped = min(H_star, depth_grid[end])                  # e.g. clamp to 10
    D_clamped = min(D_star, dilution_grid[end])               # e.g. clamp to 1000
    return itp_def(H_clamped, D_clamped)  # yields a Float64
end

# define a function for the "block model" area
function block_model_top_area(D::Float64, alpha::Float64, H0::Float64; Vorig::Float64=1.0)
    A0 = Vorig / H0   # original area for that "1 m^3" volume
    # alpha = R/(1+R)   # fraction expanding horizontally
    A_new = A0 * (D+1)^alpha
    final_depth = H0 * (D+1)^(1-alpha)
    return A_new, final_depth
end

# Arrays for final geometry and 3D results:
final_area_3D       = Matrix{Float64}(undef, n_depths, n_dilutions)
final_depth_3D      = Matrix{Float64}(undef, n_depths, n_dilutions)
final_deficit_3D    = Matrix{Float64}(undef, n_depths, n_dilutions)
final_additionality_3D = Matrix{Float64}(undef, n_depths, n_dilutions)
final_efficiency_3D = Matrix{Float64}(undef, n_depths, n_dilutions)

# set the lateral-to-vertical dilution ratio
# R_local = 100.0  
alpha = 1.0

for row_i in 1:n_depths
    H0 = layer_depths[row_i]   # original thickness (e.g. 2.0, 3.0, etc.)

    for col_j in 1:n_dilutions
        D = dilution_values[col_j]  # e.g. 0, 1, 2, 5, etc.

        # =========== 1D data =========== 
        # "per‐area" initial deficit and final additionality, both [mol/m^2]
        init_def_1D = initial_deficit_1D[row_i, col_j]
        add_1D      = final_add_1D[row_i, col_j]

        # =========== Block model geometry ===========
        A_new, depth_new = block_model_top_area(D, alpha, H0; Vorig=1.0)
        add_1D_interpolated = clamp_and_interpolate_add_1D(depth_new, D)
        def_1D_interpolated = clamp_and_interpolate_def_1D(depth_new, D)

        final_area_3D[row_i, col_j]  = A_new
        final_depth_3D[row_i, col_j] = depth_new

        # =========== 3D totals ===========
        # total deficit in [mol] = (deficit [mol/m^2]) * area [m^2]
        # (assuming uniform concentration “1D style”)
        final_deficit_3D[row_i, col_j] = def_1D_interpolated * A_new 

        # total additionality in [mol] = add_1D * area
        final_additionality_3D[row_i, col_j] = add_1D_interpolated * A_new

        # =========== efficiency = total_add / total_def =========== 
        final_efficiency_3D[row_i, col_j] = final_additionality_3D[row_i, col_j] / final_deficit_3D[row_i, col_j]
        # final_additionality_3D[row_i, col_j] / final_deficit_3D[row_i, col_j]
    end
end


# Visualize
nlevels1 = 34
my_palette1 = cgrad(:thermal, nlevels1; categorical=true)

nlevels2 = 30
my_palette2 = cgrad(:ocean, nlevels2; categorical=true)

### FOR THE EFFICIENCY HEATMAP/CONTOURF:
p1 = heatmap(
    dilution_values .+ 5e-1,  # shift for log scale plot
    layer_depths,
    final_additionality_3D,
    # final_efficiency_3D,
    xscale = :log10,
    color = my_palette1,
    xlabel = "Dilution Ratio",
    ylabel = "Effluent Layer Depth (m)",
    colorbar_title = "100-day Additionality [mol/m\$^3\$]",
    xticks = ([5e-1,1.3,2.8,5.5,10,20,50,100,1000],
              ["0","1","2","5","10","20","50","100","1000"]),
    size = (2000, 500),
    clims = (0.0, 0.85),
    wireframe = true,

    # uncomment for contourf
    linecolor = :black,        # Contour line color
    linewidth = 2,           # Line thickness
    
    # MARGINS
    left_margin   = 5mm,
    right_margin  = 5mm,
    top_margin    = 5mm,
    bottom_margin = 5mm,

    # FONTS
    guidefont  = font(14),
    tickfont   = font(12),
    titlefont  = font(16),
    colorbar_font = font(14),
    colorbar_titlepadding = 10,
    legendfont = font(12)
)

p2 = heatmap(
    dilution_values .+ 5e-1,  # shift for log scale plot
    layer_depths,
    # final_additionality_3D,
    final_efficiency_3D,
    xscale = :log10,
    color = my_palette2,
    xlabel = "Dilution Ratio",
    # ylabel = "Effluent Layer Depth (m)",
    colorbar_title = "100-day Efficiency [%]",
    xticks = ([5e-1,1.3,2.8,5.5,10,20,50,100,1000],
              ["0","1","2","5","10","20","50","100","1000"]),
    size = (2000, 500),
    clims = (0.0, 0.75),

    # uncomment for contourf
    linecolor = :black,        # Contour line color
    linewidth = 2,           # Line thickness
    
    # MARGINS
    left_margin   = 5mm,
    right_margin  = 5mm,
    top_margin    = 5mm,
    bottom_margin = 5mm,

    # FONTS
    guidefont  = font(14),
    tickfont   = font(12),
    titlefont  = font(16),
    colorbar_font = font(14),
    colorbar_titlepadding = 10,
    legendfont = font(12)
)

plot(p1, p2; layout = (1,2),
    xlabel = "Dilution Ratio [1]",
    ylabel = "Effluent Layer Depth [m]"
)


# savefig("ellipsoid_additionality_heatmap.png")
# println("Heatmap saved to ellipsoid_additionality_heatmap.png")





###############################################################################
# 1)  Suppose we have:
#       final_add_1D[row_i, col_j]        in [mol/m^2]
#       initial_deficit_1D[row_i, col_j]  in [mol/m^2]
#     and interpolation functions:
#       clamp_and_interpolate_add_1D(H_star, D_star) => [mol/m^2]
#       clamp_and_interpolate_def_1D(H_star, D_star) => [mol/m^2]
#
#     We also define a block_model_top_area(D, alpha, H0) that returns
#       (A_new, depth_new).
###############################################################################

# We'll define the alpha range:
alpha_values = 0.0:0.2:1.0

# We assume you already have:
# dilution_values = [0.0, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0, 200.0, 500.0, 1000.0]

# We'll store final_additionality_2D and final_efficiency_2D
#   dimension 1 => alpha
#   dimension 2 => dilution
# so final_additionality_2D[i, j] => the 3D total additionality for alpha_values[i], D = dilution_values[j].
n_alpha     = length(alpha_values)
n_dilutions = length(dilution_values)

final_additionality_2D = Matrix{Float64}(undef, n_alpha, n_dilutions)
final_efficiency_2D    = Matrix{Float64}(undef, n_alpha, n_dilutions)

# Let's fix H0 = 1 m
H0 = 1.0

for (i, alpha) in enumerate(alpha_values)
    for (j, D) in enumerate(dilution_values)
        # 1) block-model geometry from volume scale (D+1)
        A_new, depth_new = block_model_top_area(D, alpha, H0; Vorig=1.0)

        # 2) Interpolate the 1D per-area results
        add_1D = clamp_and_interpolate_add_1D(depth_new, D)  # [mol/m^2]
        def_1D = clamp_and_interpolate_def_1D(depth_new, D)  # [mol/m^2]

        # 3) Multiply by area to get total [mol]
        total_add_3D = add_1D * A_new
        total_def_3D = def_1D * A_new

        # 4) store
        final_additionality_2D[i, j] = total_add_3D
        # final_efficiency_2D[i, j]    = total_add_3D / total_def_3D
        final_efficiency_2D[i, j]    = total_add_3D / initial_deficit_1D[1,1]
    end
end

###############################################################################
# 2) Plot as a 2-panel figure: left= final_additionality, right= final_efficiency
###############################################################################
# my_colors = cgrad(:viridis, n_alpha, categorical=false)
p = Plots.palette(:viridis, 11)
# theme(:viridis)
# --- Panel 1: Additionality vs. Dilution ---
dilution_values_plot = dilution_values
dilution_values_plot[1] = 0.5

plt1 = plot(
    xscale = :log10,
    xticks = (dilution_values_plot,
    ["0","1","2","5","10","20","50","100", "200", "500","1000"]),
    xlabel = "Dilution Ratio",
    ylabel = "Additionality [mol]",
    title  = "100-day Additionality vs. Dilution with variable anisotropy \$(\\alpha)\$. \$V_0\$ = 1 m\$^3\$."
)

for (i, α) in enumerate(alpha_values)
    # Y-values = final_additionality_2D for this alpha, all dilutions
    yvals = final_additionality_2D[i, :]
    plot!(
        dilution_values_plot,
        yvals;
        label = "\$\\alpha\$ = $(α)",
        lw = 2,
        marker = :o,
        # color = my_colors[i]
        palette = p
    )
end
# legend(maxrows = 2)

# --- Panel 2: Efficiency vs. Dilution ---
plt2 = plot(
    xscale = :log10,
    xticks = (dilution_values_plot,
    ["0","1","2","5","10","20","50","100","200","500","1000"]),
    xlabel = "Dilution Ratio",
    ylabel = "Efficiency [–]",
    title  = "Block Model Efficiency vs. Dilution"
)

for (i, α) in enumerate(alpha_values)
    # Y-values = final_efficiency_2D for this alpha
        # println("$i")
        # current_color = my_colors[i]
        # println("$current_color")
    yvals = final_efficiency_2D[i, :]
    plot!(
        dilution_values_plot,
        yvals;
        label = "\$\\alpha\$ = $(α)",
        lw = 2,
        marker = :diamond,
        # color = current_color
        palette = p
    )
end

# Combine into a 2-row layout:
plot(plt1, plt2; layout=(2,1), size=(800, 800))






# ###############################################################################
# # EXAMPLE: Plot flux(t) and its time‐integral for 1‐m effluent layer files
# ###############################################################################

# using Statistics: cumsum  # to get cumulative sums

# file_paths = file_paths_1m_layer  # or whichever set you want

# # We'll store the flux(t) curves, time arrays, and the final “dilution” or label
# flux_vs_time_list = []
# cumulative_flux_list = []
# time_list = []
# dilution_labels = String[]

# # We know each file name includes something like "results_dilution_X.jld2",
# # so we can parse out X from the path (just as an example).
# # function parse_dilution_from_path(fname::String)
# #     # very rough example looking for "...results_dilution_XX.jld2"
# #     # you could refine with a regex, etc.
# #     parts = split(fname, "_")
# #     # last part might be "dilution_XX.jld2"
# #     for (i, part) in enumerate(parts)
# #         if startswith(part, "dilution")
# #             # parse numeric
# #             dil_val_str = replace(part, "dilution_" => "")
# #             dil_val_str = replace(dil_val_str, ".jld2" => "")
# #             return parse(Float64, dil_val_str)
# #         end
# #     end
# #     return missing
# # end

# function parse_dilution_from_path(fname::String)
#     # This regex looks for: the substring "dilution_" followed by
#     # one or more digits, optionally a decimal point, then more digits.
#     # The numeric portion is captured in m.captures[1].
#     m = match(r"dilution_(\d+\.?\d*)", fname)
#     if m !== nothing
#         return parse(Float64, m.captures[1])
#     else
#         return missing
#     end
# end


# for fp in file_paths
#     # Load simulation data
#     DIC_p, DIC_up, pCO2_p, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(fp)
    
#     # Suppose TI is the time vector in [s], and additionality_flux is the flux in [mol/(m^2·s)] or similar
#     # Convert time to days (for plotting convenience)
#     time_days = TI ./ 86400.0
    
#     # If additionality_flux is [mol m^-2 s^-1], then the instantaneous flux is that array directly.
#     # The cumulative flux would be its time integral (with respect to dt).
#     dt = time_days[2] - time_days[1]  # in days
#     # But watch out for units (days vs seconds). If additionality_flux is in [mol m^-2 s^-1],
#     # we should do dt_s = (TI[2] - TI[1]) in seconds, then multiply in seconds:
#     dt_s = TI[2] - TI[1]
    
#     flux_array = additionality_flux  # rename for clarity
#     cumflux_array = cumsum(flux_array .* dt_s)  # [mol m^-2] integrated over time

#     push!(flux_vs_time_list, flux_array)
#     push!(cumulative_flux_list, cumflux_array)
#     push!(time_list, time_days)
    
#     # parse a short label from the file name
#     dil_val = parse_dilution_from_path(fp)
#     push!(dilution_labels, "D=$(dil_val)")
# end

# # Now plot them in a two‐panel figure
# plt_flux = plot(
#     title="Instantaneous Flux vs. Time (1‑m layer)",
#     xlabel="Time [days]", ylabel="Flux [mol m^{-2} s^{-1}]",
#     yscale=:linear,
#     xscale=:linear
# )

# plt_cum = plot(
#     title="Cumulative Flux vs. Time (1‑m layer)",
#     xlabel="Time [days]", ylabel="Cumulative Flux [mol m^{-2}]",
#     yscale=:linear,
#     xscale=:linear
# )

# for i in 1:length(flux_vs_time_list)
#     plot!(plt_flux, time_list[i], flux_vs_time_list[i],
#           label=dilution_labels[i], lw=2)
#     plot!(plt_cum,  time_list[i], cumulative_flux_list[i],
#           label=dilution_labels[i], lw=2)
# end

# # Combine both panels side by side
# plot(plt_flux, plt_cum; layout=(1,2), legend=:bottom)

# savefig("flux_and_cumulative_1m_layer.png")
# println("Saved flux/cumulative figure to flux_and_cumulative_1m_layer.png")




using JLD2
using Plots
using Statistics: cumsum

# 1) Define a function to load your data from a JLD2 file
function load_simulation_data(file_path)
    data = JLD2.jldopen(file_path) do file
        read(file, "simulation_results")
    end
    DIC_p  = data["output"]["DIC_p"]
    DIC_up = data["output"]["DIC_up"]
    pCO2_p = data["output"]["pCO2_p"]
    ΔpCO2  = data["output"]["ΔpCO2_p"]
    TI     = data["output"]["TI"]            # time array [s]
    z      = data["output"]["z"]             # depth array
    additionality = data["output"]["additionality"]
    additionality_flux = data["output"]["additionality_flux"]  # flux(t) [mol m^-2 s^-1]
    additionality_dic = data["output"]["additionality_dic"]
    return DIC_p, DIC_up, pCO2_p, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic
end

# 2) Define a helper function to parse the dilution ratio from a file name
#    (or just label them manually if you prefer).
function parse_dilution_from_path(fname::String)
    # Regex for "dilution_X", capturing X
    m = match(r"dilution_(\d+\.?\d*)", fname)
    if m !== nothing
        return parse(Float64, m.captures[1])
    else
        return missing
    end
end

# 3) Define a function that:
#    - Takes a list of JLD2 file paths (all same alpha, different dilution).
#    - Loads each, extracts flux(t), integrates it, and plots them.
using JLD2
using Plots
using Statistics: cumsum

function flux_analysis_and_plot(file_paths::Vector{String}, alpha::Float64; alpha_label::String="")
    # We assume A0 = 1 m^2 before dilution, but do NOT multiply the final flux by area
    # if additionality_flux is already [mol m^-2].
    A0 = 1
    p = Plots.palette(:viridis, length(file_paths))

    flux_vs_time_list     = []  # instantaneous flux(t) in [mol m^-2 s^-1]
    flux_time_list        = []  # time vector for instantaneous flux
    cumulative_flux_list  = []  # cumulative flux(t) in [mol m^-2]
    cumulative_time_list  = []  # time vector for cumulative flux
    delta_pco2_list       = []
    ionization_list         = []
    dil_labels            = String[]

    for fp in file_paths
        # ------------------------------------------------------
        # 1) Parse the dilution ratio S from filename
        # ------------------------------------------------------
        dval = parse_dilution_from_path(fp)  # e.g. 0, 1, 2, 5, 10
        if dval === missing
            @warn "Could not parse dilution from $fp. Setting S=???"
            dval = 0.0
        end

        surface_area = A0 * (dval + 1)^alpha
        # ------------------------------------------------------
        # 2) Load data from JLD2 file
        # ------------------------------------------------------
        DIC_p, DIC_up, pCO2_p, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(fp)
        # According to your note, `additionality_flux` is ALREADY the
        # cumulative additionality in [mol m^-2], at each time step.

        # Convert time [s] to [days]
        time_days = TI ./ 86400.0
        nt        = length(TI)

        # ------------------------------------------------------
        # 3) Instantaneous flux via finite difference
        #    additionality_flux[t] is in [mol m^-2].
        # ------------------------------------------------------
        flux_array = zeros(nt-1)  # will hold [mol m^-2 s^-1]
        ionization_array = zeros(nt)
        for i in 1:(nt-1)
            dt_s = TI[i+1] - TI[i]  # time step in seconds
            # difference in [mol m^-2], divided by dt_s => [mol m^-2 s^-1]
            flux_array[i] = (additionality_dic[i+1] - additionality_dic[i]) / dt_s * surface_area
        end
        for i in 1:nt
            ionization_array[i] = DIC_p[end,i]/pCO2_p[end,i]
        end

        # For plotting, define the flux time as midpoints or just use the left edge:
        flux_time = 0.5 .* (time_days[1:end-1] .+ time_days[2:end])

        # ------------------------------------------------------
        # 4) The cumulative flux is simply additionality_flux itself
        #    in [mol m^-2].
        # ------------------------------------------------------
        cumflux_array      = additionality_dic * surface_area
        cumflux_time       = time_days

        dpco2_array = ΔpCO2
        

        # ------------------------------------------------------
        # 5) Store for plotting
        # ------------------------------------------------------
        push!(flux_vs_time_list, flux_array)
        push!(flux_time_list,    flux_time)
        push!(cumulative_flux_list, cumflux_array)
        push!(cumulative_time_list, cumflux_time)
        push!(delta_pco2_list, dpco2_array)
        push!(ionization_list, ionization_array)

        label_str = "S = $(dval)"
        push!(dil_labels, label_str)
    end

    # ----------------------------------------------------------
    # 6) Plot everything
    # ----------------------------------------------------------
    plt_flux = plot(
        title  = "Ionization fraction vs. Time ($alpha_label)",
        xlabel = "Time [days]",
        ylabel = "ΔpCO2 [uatm]",
        legend = :bottomright,
    )
    plt_cum = plot(
        title  = "Cumulative Flux vs. Time ($alpha_label)",
        xlabel = "Time [days]",
        ylabel = "Cumulative Flux [mol]",
        legend = :topleft
    )

    for i in 1:length(flux_vs_time_list)
        plot!(plt_flux,
                cumulative_time_list[i], ionization_list[i],
                palette = p,
                label = dil_labels[i], lw=2)
        plot!(plt_cum,
                cumulative_time_list[i], cumulative_flux_list[i],
                # flux_time_list[i], flux_vs_time_list[i],
                palette = p,
                label = dil_labels[i], lw=2)
    end

    fig = plot(plt_flux, plt_cum; layout=(1,2), size=(1200,500))
    return fig
end


################################################################################
# 4) Now define the file paths for each alpha case
#    (just an example — adjust to your actual directories/files).
################################################################################

# We pick only the five dilution values [0, 1, 2, 5, 10] for each alpha.

# (A) Purely vertical (alpha=0)
# vertical_paths = [
#     "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_2eminus09/results_dilution_0.jld2", # d = 0, alpha = 0
#     "./results/inf_MLD_Bic_1_u6p63_2mEffLayer_variable_dilution_doc/diffusivity_8eminus08/results_dilution_1.jld2", # d = 1, alpha = 0
#     "./results/inf_MLD_Bic_1_u6p63_3mEffLayer_variable_dilution_doc/diffusivity_2eminus07/results_dilution_2.jld2", # d = 2, alpha = 0
#     "./results/inf_MLD_Bic_1_u6p63_6mEffLayer_variable_dilution_doc/diffusivity_8eminus07/results_dilution_5.jld2", # d = 5, alpha = 0
#     "./results/inf_MLD_Bic_1_u6p63_10mEffLayer_variable_dilution_doc/diffusivity_2eminus06/results_dilution_10.jld2" # d = 10, alpha = 0
# ]

vertical_paths = [
    "results/inf_MLD_variable_dilution_doc_fixed_Bic/results_dilution_0.0.jld2",
    "results/inf_MLD_variable_dilution_doc_fixed_Bic/results_dilution_0.5.jld2",
    "results/inf_MLD_variable_dilution_doc_fixed_Bic/results_dilution_1.0.jld2",
    "results/inf_MLD_variable_dilution_doc_fixed_Bic/results_dilution_0.5.jld2",
    "results/inf_MLD_variable_dilution_doc_fixed_Bic/results_dilution_2.0.jld2",
    "results/inf_MLD_variable_dilution_doc_fixed_Bic/results_dilution_2.5.jld2",
    "results/inf_MLD_variable_dilution_doc_fixed_Bic/results_dilution_3.0.jld2",
    "results/inf_MLD_variable_dilution_doc_fixed_Bic/results_dilution_3.5.jld2",
    "results/inf_MLD_variable_dilution_doc_fixed_Bic/results_dilution_4.0.jld2",
    "results/inf_MLD_variable_dilution_doc_fixed_Bic/results_dilution_4.5.jld2",
    "results/inf_MLD_variable_dilution_doc_fixed_Bic/results_dilution_5.0.jld2"
]

# (B) Isotropic (alpha=0.5)
# isotropic_paths = [
#     "./results/alpha_0p5/results_dilution_0.jld2",
#     "./results/alpha_0p5/results_dilution_1.jld2",
#     "./results/alpha_0p5/results_dilution_2.jld2",
#     "./results/alpha_0p5/results_dilution_5.jld2",
#     "./results/alpha_0p5/results_dilution_10.jld2",
# ]

# (C) Purely lateral (alpha=1.0)
lateral_paths = [
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_2eminus09/results_dilution_0.jld2", # d = 0, alpha = 1
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_4eminus08/results_dilution_1.jld2", # d = 1, alpha = 1
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_7eminus08/results_dilution_2.jld2", # d = 2, alpha = 1
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_1eminus07/results_dilution_5.jld2", # d = 5, alpha = 1
    "./results/inf_MLD_Bic_1_u6p63_1mEffLayer_variable_dilution_doc/diffusivity_2eminus07/results_dilution_10.jld2" # d = 10, alpha = 1
]


################################################################################
# 5) Generate and save the plots
################################################################################

fig_vertical  = flux_analysis_and_plot(vertical_paths, 0.0;  alpha_label="(α=0)")
# fig_isotropic = flux_analysis_and_plot(isotropic_paths; alpha_label="α=0.5 (isotropic)")
fig_lateral   = flux_analysis_and_plot(lateral_paths, 1.0;   alpha_label="(α=1)")

# Save them
Plots.savefig(fig_vertical,  "flux_and_cumulative_vertical.png")
# Plots.savefig(fig_isotropic, "flux_and_cumulative_isotropic.png")
Plots.savefig(fig_lateral,   "flux_and_cumulative_lateral.png")

println("Saved 3 sets of flux/cumulative plots.")
