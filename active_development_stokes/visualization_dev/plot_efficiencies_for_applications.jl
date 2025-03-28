using JLD2
using Plots
using PlotUtils
using PoseidonMRV
using Interpolations
using Measures
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

# # A small helper to find the index at or closest to 100 days in your time vector
# function time_index_for_100days(TI)
#     # TI is presumably in seconds
#     t_100_days = 100*86400  # 100 days in seconds
#     # Find the index in TI that is closest to 100 days
#     idx = findall(t -> t ≥ t_100_days, TI)
#     if !isempty(idx)
#         return first(idx)
#     else
#         # if 100 days is beyond the last time step,
#         # just use the final index
#         return length(TI)
#     end
# end

"""
Compute the top‐surface area of a half‐ellipsoid whose total volume is 
(D+1) times the original hemisphere volume, **but** with a minimum 
vertical axis (no shallower than the original).

Inputs:
- D:   dilution ratio (0 => no extra volume, 1 => double the volume, etc.)
- R:   lateral vs. vertical diffusivity ratio, R = D_lateral / D_vertical
- r:   the original “hemisphere radius” in meters. 
       (In your code, this could be the same as `layer_depths[row_i]`
       if your “layer depth” is the hemisphere’s vertical dimension.)
Returns:
- top_area: the area of the circular top in m²
"""
function half_ellipsoid_top_area_min_depth(D::Float64, R::Float64, r::Float64)
    # Original hemisphere volume:
    V_orig = (2/3)*pi*r^3
    
    # New volume = (D+1)* V_orig
    # Under an unconstrained half‐ellipsoid with ratio R = D_lateral/D_vertical:
    #   λ_L^2 * λ_V = (D+1)
    #   λ_L / λ_V   = sqrt(R)
    # => λ_V = ((D+1)/R)^(1/3),   λ_L = sqrt(R)*λ_V
    
    # 1) compute unconstrained scale factors
    lambda_V = ((D+1)/R)^(1/3)
    lambda_L = sqrt(R)*lambda_V
    
    # 2) check if the vertical axis is < 1 (which would shrink below r)
    if lambda_V < 1
        # clamp vertical dimension at the original => λ_V = 1
        lambda_V = 1
        # re‐solve for λ_L so that the volume remains (D+1)*V_orig
        # we need λ_L^2 * λ_V = (D+1), but now λ_V=1 => λ_L^2 = (D+1)
        lambda_L = sqrt(D+1)
    end
    
    # 3) The new top area is the horizontal cross‐section at z=0:
    #    radius in horizontal = r*λ_L
    #    => area = π * (r*λ_L)²
    return pi * (r*lambda_L)^2
end


# Vector of file paths for different layer depths

# use this for infinite MLD, 10m ELD
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

dilution_values = [0,1,2,5,10,20,50,100,200,500,1000]
layer_depths = [1,2,3,4,5,6,7,8,9,10]

sim_days = 100
sim_res = 3600 # hourly resolution
target_efficiency_idx = Int(sim_days * 86400 / sim_res + 1)
# ---------------
# 3) Prepare data
# ---------------
# We'll store final (100-day) EFFICIENCY in a 2D matrix:
#   rows = each layer depth
#   columns = each dilution
final_efficiency = Matrix{Float64}(undef, length(layer_depths), length(dilution_values))
final_additionality = Matrix{Float64}(undef, length(layer_depths), length(dilution_values))

# A function to compute efficiency array from loaded data
function calc_efficiency(DIC_p, DIC_up, z, add_dic)
    # For each time step:
    #   efficiency(t) = (additionality_dic(t)) / (initial_deficit)
    # with initial_deficit = DIC_up_0 - DIC_p_0
    # where DIC_up_0 is total unperturbed DIC at t=0.
    # We'll assume z is typically descending or ascending.
    # We'll pick the difference z[1]-z[2] as the layer thickness if uniform?
    
    # For example, compute total DIC in the domain at t=0
    # If your code is 1D layers with shape (nz, nt):
    rho = 1025
    Δz  = abs(z[2] - z[1])  # hopefully uniform; adapt if not
    DIC_up_0 = sum(DIC_up[:,1]) * Δz * rho * 1e-6
    DIC_p_0  = sum(DIC_p[:,1])  * Δz * rho * 1e-6
    initial_deficit = DIC_up_0 - DIC_p_0
    
    # The array "add_dic" is the additionality over time from your model
    # So efficiency(t) = add_dic(t) / initial_deficit
    efficiency = add_dic ./ initial_deficit
    return efficiency
end

# 4) Load data & fill the final_efficiency matrix
#    - first row (row 1) = 1m layer paths
#    - second row (row 2) = 2m layer paths
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

V1 = 1
R = 1

# for (row_i, paths_for_layer) in enumerate(all_file_paths)
#     # row_i will be 1, then 2
#     for (col_j, fp) in enumerate(paths_for_layer)
#         # col_j loops from 1..length(dilution_values)
        
#         DIC_p, DIC_up, pCO2_p, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(fp)
#         eff = calc_efficiency(DIC_p, DIC_up, z, additionality_dic)
        
#         # final efficiency
#         final_efficiency[row_i, col_j] = eff[target_efficiency_idx]
#         final_additionality[row_i, col_j] = additionality_dic[target_efficiency_idx] * (dilution_values[col_j] + 1)^(2/3) * pi*(3*V1/(2*pi))^(2/3) * R^(1/3)
#     end
# end

for (row_i, paths_for_layer) in enumerate(all_file_paths)
    # let r = the original hemisphere radius = that row's layer_depth
    r = Float64(layer_depths[row_i])

    for (col_j, fp) in enumerate(paths_for_layer)
        DIC_p, DIC_up, pCO2_p, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(fp)
        eff = calc_efficiency(DIC_p, DIC_up, z, additionality_dic)

        # (1) store your 1D efficiency for reference, 
        #     e.g. final_efficiency[row_i, col_j] = ...
        final_efficiency[row_i, col_j] = eff[target_efficiency_idx]

        # (2) compute the new top area with clamped half‐ellipsoid geometry
        D = Float64(dilution_values[col_j])
        # Suppose you want R = 2.0 for demonstration:
        R_local = 2.0  
        A_new = half_ellipsoid_top_area_min_depth(D, R_local, r)

        # (3) Since additionality_dic[target_efficiency_idx] 
        #     is presumably in [mol / m^2], multiply by area to get total [mol].
        final_additionality[row_i, col_j] = additionality_dic[target_efficiency_idx] * A_new
        # final_efficiency[row_i, col_j] = final_additionality[row_i, col_j] * [....volume stuff....]
    end
end




# ---------------------
# 5) Make the heatmap!
# ---------------------
# final_efficiency has shape (2, 11) if you have 2 layer depths, 11 dilutions
# x-axis: dilution_values
# y-axis: layer_depths
# in Plots.jl, you typically do: heatmap(x, y, z_matrix)
# by default, z_matrix[1,1] corresponds to x[1], y[1]. 
# So let's do:

nlevels = 14
my_palette = cgrad(:viridis, nlevels; categorical=true)

# heatmap(
#     dilution_values .+ 5e-1,         # x
#     layer_depths,                    # y
#     final_efficiency,                # color data
#     xscale = :log10,                 # maybe you want log scale for dilution?
#     xticks = ([5e-1,1.3,2.6,5,10,20,50,100,500,1000],["0","1","2","5","10","20","50","100","500","1000"]),
#     # xlim = (1e-1,1e3),
#     xlabel="Dilution Ratio",
#     ylabel="Effluent Layer Depth (m)",
#     title="100-day Efficiency Heatmap",
#     color = my_palette,        # our discrete gradient
#     clims = (0,0.7),             # clamp or define the data range for the colormap
#     colorbar_ticks = 0:0.05:0.7, # your discrete tick marks on the colorbar
#     colorbar_title = "Efficiency",
#     categorical = true
# )

# ### FOR THE EFFICIENCY HEATMAP:
# levels = 0:5:70  # specify discrete boundaries
# contourf(
#     dilution_values .+ 5e-1,
#     layer_depths,
#     final_efficiency * 100;
#     xscale=:log10,
#     levels=levels,   # here is your discrete “step” definition
#     fill=true,
#     color=:viridis,
#     xlabel="Dilution Ratio",
#     ylabel="Effluent Layer Depth (m)",
#     # title="Efficiencies after 100 days, Bi\$_c\$ = 1",
#     colorbar_title="Efficiency [%] after 100 days, Bi\$_c\$ = 1",
#     xticks = ([5e-1,1,2,5,10,20,50,100,1000],["0","1","2","5","10","20","50","100","1000"]),
#     yticks = ([1,2,4,6,8,10],["1","2","4","6","8","10"]),
#     size = (1000, 500),
#     linecolor = :black,        # Contour line color
#     linewidth = 2,           # Line thickness

#     # MARGINS
#     left_margin   = 5mm,
#     right_margin  = 5mm,
#     top_margin    = 5mm,
#     bottom_margin = 5mm,

#     # FONTS
#     guidefont  = font(14),  # Axis label font
#     tickfont   = font(12),  # Tick label font
#     titlefont  = font(16),  # Title font
#     colorbar_font = font(14),
#     colorbar_titlepadding = 10,
#     legendfont = font(12)   # Colorbar ticks/legend
# )


### FOR THE ADDITIONALITY HEATMAP:
# levels = 0:5:70  # specify discrete boundaries
contourf(
    dilution_values .+ 5e-1,
    layer_depths,
    final_additionality;
    xscale=:log10,
    # levels=levels,   # here is your discrete “step” definition
    fill=true,
    color=:viridis,
    xlabel="Dilution Ratio",
    ylabel="Effluent Layer Depth (m)",
    # title="Efficiencies after 100 days, Bi\$_c\$ = 1",
    colorbar_title="Additionality [mol] after 100 days, Bi\$_c\$ = 1",
    xticks = ([5e-1,1,2,5,10,20,50,100,1000],["0","1","2","5","10","20","50","100","1000"]),
    # xticks = ([0,1,2,3,4,5,10],["0","1","2","3","4","5","10"]),
    # yticks = ([1,2,4,6,8,10],["1","2","4","6","8","10"]),
    # xlim = (0,10),
    size = (1000, 500),
    linecolor = :black,        # Contour line color
    linewidth = 2,           # Line thickness

    # MARGINS
    left_margin   = 5mm,
    right_margin  = 5mm,
    top_margin    = 5mm,
    bottom_margin = 5mm,

    # FONTS
    guidefont  = font(14),  # Axis label font
    tickfont   = font(12),  # Tick label font
    titlefont  = font(16),  # Title font
    colorbar_font = font(14),
    colorbar_titlepadding = 10,
    legendfont = font(12)   # Colorbar ticks/legend
)



savefig("additionality_heatmap.png")
println("Heatmap saved to efficiency_heatmap.png")