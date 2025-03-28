using JLD2
using Plots
using PoseidonMRV
using LaTeXStrings

# Define a function to load data and extract variables
function load_simulation_data(file_path)
    data = JLD2.jldopen(file_path) do file
        read(file, "simulation_results")
    end
    # Extract relevant data
    DIC_p = data["output"]["DIC_p"]
    DIC_up = data["output"]["DIC_up"]
    pCO2_p = data["output"]["pCO2_p"]
    ΔpCO2_p = data["output"]["ΔpCO2_p"]
    TI = data["output"]["TI"]
    z = data["output"]["z"]
    additionality = data["output"]["additionality"]
    additionality_flux = data["output"]["additionality_flux"]
    additionality_dic = data["output"]["additionality_dic"]
    return DIC_p, DIC_up, pCO2_p, ΔpCO2_p, TI, z, additionality, additionality_flux, additionality_dic
end

# Function to extract diffusivity from the file path
function extract_diffusivity(file_path)
    match_result = match(r"diffusivity_(\d+eminus\d+)", file_path)
    return match_result !== nothing ? match_result.captures[1] : "unknown"
end

# Given a vector of times `TI` in **seconds** and a scalar `day` in **days**, 
# return the index of `TI` whose value is closest to `day` days.

function nearest_time_index(TI::AbstractVector{<:Real}, day::Real)
    t_days = TI ./ 86400 # Convert TI from seconds to days
    idx = argmin(abs.(t_days .- day))
    return idx
end

file_paths = [
    "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus04/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus05/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus06/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus07/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus08/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus09/results_dilution_100.jld2",   
    ]
Bi_c = [0.001, 0.01, 0.1, 1, 10, 100]

file_paths_1 = [
    "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus04/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus05/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus06/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus07/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus08/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus09/results_dilution_100.jld2",   
    ]
Bi_c_1 = [0.001, 0.01, 0.1, 1, 10, 100]

file_paths_2 = [
    "./results/inf_MLD_5m_ELD_doc/diffusivity_1eminus03/results_dilution_100.jld2",
    "./results/inf_MLD_5m_ELD_doc/diffusivity_1eminus04/results_dilution_100.jld2",
    "./results/inf_MLD_5m_ELD_doc/diffusivity_1eminus05/results_dilution_100.jld2",
    "./results/inf_MLD_5m_ELD_doc/diffusivity_1eminus06/results_dilution_100.jld2",
    "./results/inf_MLD_5m_ELD_doc/diffusivity_1eminus07/results_dilution_100.jld2",
    "./results/inf_MLD_5m_ELD_doc/diffusivity_1eminus08/results_dilution_100.jld2",
]
Bi_c_2 = [0.001, 0.01, 0.1, 1, 10, 100]

file_paths_3 = [
    # "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus03/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus04/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus05/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus06/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus07/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus08/results_dilution_100.jld2",
]
Bi_c_3 = [0.01, 0.1, 1, 10, 100]

# Define a color palette with ordered, distinct colors
color_palette = Plots.palette(:viridis, length(file_paths))  # Choose a palette with enough colors
# color_palette_short = Plots.palette(:viridis, length(file_paths_short))  # Choose a palette with enough colors


# Bi_c_short = [0.01, 0.1, 1, 10, 100, 1000]
# Bi_c = [0.01, 0.1, 1, 10, 100, 1000]
# Bi_c = [1, 10, 100, 1000]

t_target = [100.0]  # days

# Initialize the figure with a two-panel layout
plt = plot(layout=(2, 1),  # Two rows, one column
    size=(800, 600),        # Adjust size for better visibility
    # legend=:topleft,  # Set legend position once here
    linewidth=2,        # Optional: Increase line width for better visibility
)

# Top panel: Plot additionality_flux over time
for (i, file_path) in enumerate(file_paths)
    local DIC_p, DIC_up, pCO2_p, ΔpCO2_p, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(file_path)
    label_text = "Bi\$_c\$ = $(Bi_c[i])" # LaTeX-style label

    rho = 1025
    DIC_up_0 = sum(DIC_up[:,1])*(z[1]-z[2]) * rho * 1e-6 # total DIC in the water column at time zero, unperturbed. [mol/m^2]
    DIC_p_0 = sum(DIC_p[:,1])*(z[1]-z[2]) * rho * 1e-6 # total DIC in the water column at time zero, unperturbed. [mol/m^2]
    initial_deficit = DIC_up_0 - DIC_p_0
    efficiency = additionality_dic / initial_deficit

    # Plot efficiency in the top panel
    plot!(plt[1], TI / 86400, efficiency*100, 
        label=label_text, 
        color=color_palette[i],
        xlabel="Time (days)", 
        ylabel="Efficiency [%], H\$_{\\mathrm{eff}}=1\$ m", 
        # title="Efficiency Over Time for Various Bi\$_c\$",
        linewidth=2, 
        legend=:bottomright)    
end
# vline!(plt[1], [(1^2/(sqrt(2)*2.67e-6))/86400], linestyle=:dash, color=:black, linewidth=2, label="t = \$T_{\\mathrm{erosion}}(\\mathrm{Bi}_c=1)\$")

color_palette_times = Plots.palette(:viridis, 3)
# Bottom panel: Plot efficiency as f(Bi_c, t)
eff_values = Array{Float64}(undef, length(Bi_c), length(t_target)) # preallocate array for efficiency values
for (i, file_path) in enumerate(file_paths_1)
    local DIC_p, DIC_up, pCO2_p, ΔpCO2_p, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(file_path)
    label_text = "Bi\$_c\$ = $(Bi_c_1[i])" # LaTeX-style label

    rho = 1025
    DIC_up_0 = sum(DIC_up[:,1])*(z[1]-z[2]) * rho * 1e-6 # total DIC in the water column at time zero, unperturbed. [mol/m^2]
    DIC_p_0 = sum(DIC_p[:,1])*(z[1]-z[2]) * rho * 1e-6 # total DIC in the water column at time zero, unperturbed. [mol/m^2]
    initial_deficit = DIC_up_0 - DIC_p_0
    efficiency = additionality_dic / initial_deficit

    for j in 1:length(t_target)
        idx = nearest_time_index(TI, t_target[j])  # get closest time index
        eff_values[i,j] = efficiency[idx]
    end
end
for i in 1:length(t_target)
    plot!(plt[2], Bi_c_1, eff_values[:,i]*100, 
        marker=:o,
        xscale=:log10,
        xticks = (10. .^ (-3:2), ["10^{-3}", "10^{-2}", "10^{-1}", "10^{0}", "10^{1}", "10^{2}"]),
        # label="t=$(t_target[i]) days", 
        label="H\$_{\\mathrm{eff}}\$ = 1 m",
        color=color_palette_times[3],
        xlabel="Carbon Transfer Biot Number (Bi\$_c\$)", 
        ylabel="Efficiency [%]", 
        # title="Efficiency as \$F(\\mathrm{Bi}_c, t)\$",
        linewidth=2, 
        legend=:topright)
end
############
for (i, file_path) in enumerate(file_paths_2)
    local DIC_p, DIC_up, pCO2_p, ΔpCO2_p, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(file_path)
    label_text = "Bi\$_c\$ = $(Bi_c_2[i])" # LaTeX-style label

    rho = 1025
    DIC_up_0 = sum(DIC_up[:,1])*(z[1]-z[2]) * rho * 1e-6 # total DIC in the water column at time zero, unperturbed. [mol/m^2]
    DIC_p_0 = sum(DIC_p[:,1])*(z[1]-z[2]) * rho * 1e-6 # total DIC in the water column at time zero, unperturbed. [mol/m^2]
    initial_deficit = DIC_up_0 - DIC_p_0
    efficiency = additionality_dic / initial_deficit

    for j in 1:length(t_target)
        idx = nearest_time_index(TI, t_target[j])  # get closest time index
        eff_values[i,j] = efficiency[idx]
    end
end
for i in 1:length(t_target)
    plot!(plt[2], Bi_c_2, eff_values[:,i]*100, 
        marker=:o,
        xscale=:log10,
        xticks = (10. .^ (-3:2), ["10^{-3}", "10^{-2}", "10^{-1}", "10^{0}", "10^{1}", "10^{2}"]),
        # label="t=$(t_target[i]) days", 
        label="H\$_{\\mathrm{eff}}\$ = 5 m",
        color=color_palette_times[2],
        xlabel="Carbon Transfer Biot Number (Bi\$_c\$)", 
        ylabel="Efficiency [%]", 
        # title="Efficiency as \$F(\\mathrm{Bi}_c, t)\$",
        linewidth=2, 
        legend=:topright)
end
#############
eff_values_3 = Array{Float64}(undef, length(Bi_c_3), length(t_target)) # preallocate array for efficiency values
for (i, file_path) in enumerate(file_paths_3)
    local DIC_p, DIC_up, pCO2_p, ΔpCO2_p, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(file_path)
    label_text = "Bi\$_c\$ = $(Bi_c_3[i])" # LaTeX-style label

    rho = 1025
    DIC_up_0 = sum(DIC_up[:,1])*(z[1]-z[2]) * rho * 1e-6 # total DIC in the water column at time zero, unperturbed. [mol/m^2]
    DIC_p_0 = sum(DIC_p[:,1])*(z[1]-z[2]) * rho * 1e-6 # total DIC in the water column at time zero, unperturbed. [mol/m^2]
    initial_deficit = DIC_up_0 - DIC_p_0
    efficiency = additionality_dic / initial_deficit

    for j in 1:length(t_target)
        idx = nearest_time_index(TI, t_target[j])  # get closest time index
        eff_values_3[i,j] = efficiency[idx]
    end
end
for i in 1:length(t_target)
    plot!(plt[2], Bi_c_3, eff_values_3[:,i]*100, 
        marker=:o,
        xscale=:log10,
        xticks = (10. .^ (-3:2), ["10^{-3}", "10^{-2}", "10^{-1}", "10^{0}", "10^{1}", "10^{2}"]),
        # label="t=$(t_target[i]) days", 
        label="H\$_{\\mathrm{eff}}\$ = 10 m",
        color=color_palette_times[1],
        xlabel="Carbon Transfer Biot Number (Bi\$_c\$)", 
        ylabel="Efficiency [%]", 
        # title="Efficiency as \$F(\\mathrm{Bi}_c, t)\$",
        linewidth=2, 
        legend=:topright)
end
vline!(plt[2], [1], linestyle=:dot, color=:black, linewidth=2, label="Bi\$_c\$ = 1")




# Display the final two-panel plot
display(plt)

# # Optionally, save the plot to a file
# savefig(plt, "additionality_over_time_inf_ELD_kg6mps.png")

