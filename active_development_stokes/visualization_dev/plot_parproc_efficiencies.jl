using JLD2
using Plots
using PoseidonMRV
using Makie

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

# Function to extract diffusivity from the file path
function extract_diffusivity(file_path)
    match_result = match(r"diffusivity_(\d+eminus\d+)", file_path)
    return match_result !== nothing ? match_result.captures[1] : "unknown"
end

# Vector of file paths for different diffusivities

# # use this for infinite MLD, 10 cm ELD
# file_paths = [
# #     "./results/inf_MLD_Bic_range_u6p63_10cmEffLayer_doc/diffusivity_3eminus04/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u6p63_10cmEffLayer_doc/diffusivity_3eminus05/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u6p63_10cmEffLayer_doc/diffusivity_3eminus06/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u6p63_10cmEffLayer_doc/diffusivity_3eminus07/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u6p63_10cmEffLayer_doc/diffusivity_3eminus08/results_dilution_100.jld2",
# #     # Add more paths as needed
# ]

# # use this for infinite MLD, 1 m ELD
# file_paths = [
#     "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_doc/diffusivity_3eminus04/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_doc/diffusivity_3eminus05/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_doc/diffusivity_3eminus06/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_doc/diffusivity_3eminus07/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_doc/diffusivity_3eminus08/results_dilution_100.jld2",
#     # Add more paths as needed
# ]

# # use this for infinite MLD, 10m ELD
# file_paths = [
#     "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus04/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus05/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus06/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus07/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus08/results_dilution_100.jld2",
#     # Add more paths as needed
# ]

# # use this for infinite MLD, 1m ELD
# file_paths = [
#     "./results/inf_MLD_Bic_range_u15p0_1mEffLayer_doc/diffusivity_1eminus03/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u15p0_1mEffLayer_doc/diffusivity_1eminus04/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u15p0_1mEffLayer_doc/diffusivity_1eminus05/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u15p0_1mEffLayer_doc/diffusivity_1eminus06/results_dilution_100.jld2",
#     "./results/inf_MLD_Bic_range_u15p0_1mEffLayer_doc/diffusivity_1eminus07/results_dilution_100.jld2",
#     # Add more paths as needed
# ]

# use this for infinite MLD, 10m ELD
file_paths = [
    "./results/inf_ELD_dilute_doc/diffusivity_1eminus04/results_dilution_100.jld2",
    "./results/inf_ELD_dilute_doc/diffusivity_1eminus05/results_dilution_100.jld2",
    "./results/inf_ELD_dilute_doc/diffusivity_1eminus06/results_dilution_100.jld2",
    "./results/inf_ELD_dilute_doc/diffusivity_1eminus07/results_dilution_100.jld2",
    "./results/inf_ELD_dilute_doc/diffusivity_1eminus08/results_dilution_100.jld2",
    # Add more paths as needed
]

kap = ["\$10^{-4}\$", "\$10^{-5}\$", "\$10^{-6}\$", "\$10^{-7}\$", "\$10^{-8}\$"]

# Define a color palette with ordered, distinct colors
color_palette = reverse(Plots.palette(:viridis, length(file_paths)))  # Choose a palette with enough colors

# Initialize the figure with a two-panel layout
plt = plot(layout=(2, 1),  # Two rows, one column
    size=(800, 600),        # Adjust size for better visibility
    padding=(10, 10, 10, 10),
    # xlabel="Time (days)",
    # ylabel="Efficiency (%)",
    # title="Additionality Over Time",
    # legend=:topleft,  # Set legend position once here
    linewidth=2,        # Optional: Increase line width for better visibility
)

# # Top panel: Plot additionality_flux over time
# for (i, file_path) in enumerate(file_paths)
#     local DIC, pCO2, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(file_path)
#     # diffusivity_label = extract_diffusivity(file_path)
#     label_text = "\$\\kappa\$ = $(kap[i])" # LaTeX-style label

#     # Plot additionality in the top panel
  
# end


# eff_values = Array{Float64}(undef, length(kap), length(t_target)) # preallocate array for efficiency values
for (i, file_path) in enumerate(file_paths)
    local DIC_p, DIC_up, pCO2_p, ΔpCO2_p, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(file_path)
    label_text = "\$\\kappa\$ = $(kap[i])" # LaTeX-style label

    rho = 1025
    DIC_up_0 = sum(DIC_up[:,1])*(z[1]-z[2]) * rho * 1e-6 # total DIC in the water column at time zero, unperturbed. [mol/m^2]
    DIC_p_0 = sum(DIC_p[:,1])*(z[1]-z[2]) * rho * 1e-6 # total DIC in the water column at time zero, unperturbed. [mol/m^2]
    initial_deficit = DIC_up_0 - DIC_p_0
    efficiency = additionality_dic / initial_deficit

    plot!(plt[1], TI / 86400, additionality_dic, 
    label=label_text, 
    color=color_palette[i],
    xlabel="Time (days)", 
    ylabel="Additionality (mol m⁻²)", title="Additionality Over Time",
    linewidth=2, 
    # padding=(10, 10, 10, 10),
    legend=:topleft)  

    # for j in 1:length(t_target)
    #     idx = nearest_time_index(TI, t_target[j])  # get closest time index
    #     eff_values[i,j] = efficiency[idx]
    # end
end

display(plt)