using JLD2
using Plots

# Define a function to load data and extract variables
function load_simulation_data(file_path)
    data = JLD2.jldopen(file_path) do file
        read(file, "simulation_results")
    end
    # Extract relevant data
    DIC = data["output"]["DIC_p"]
    pCO2_p = data["output"]["pCO2_p"]
    ΔpCO2 = data["output"]["ΔpCO2_p"]
    TI = data["output"]["TI"]
    z = data["output"]["z"]
    additionality = data["output"]["additionality"]
    additionality_flux = data["output"]["additionality_flux"]
    additionality_dic = data["output"]["additionality_dic"]
    return DIC, pCO2_p, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic
end

# Function to extract diffusivity from the file path
function extract_diffusivity(file_path)
    match_result = match(r"diffusivity_(\d+eminus\d+)", file_path)
    return match_result !== nothing ? match_result.captures[1] : "unknown"
end

# Vector of file paths for different diffusivities

# # use this for infinite ELD test files
# file_paths = [
#     "./results/inf_ELD_test_doc/diffusivity_1eminus04/results_dilution_0.jld2",
#     "./results/inf_ELD_test_doc/diffusivity_1eminus05/results_dilution_0.jld2",
#     "./results/inf_ELD_test_doc/diffusivity_1eminus06/results_dilution_0.jld2",
#     "./results/inf_ELD_test_doc/diffusivity_1eminus07/results_dilution_0.jld2",
#     "./results/inf_ELD_test_doc/diffusivity_1eminus08/results_dilution_0.jld2",
#     "./results/inf_ELD_test_doc/diffusivity_1eminus09/results_dilution_0.jld2",
#     # Add more paths as needed
# ]

# # use this for infinite ELD
# T = 15.0
# u10 = 6.63
# file_paths = [
#     "./results/inf_ELD_doc/diffusivity_1eminus04/results_dilution_0.jld2",
#     "./results/inf_ELD_doc/diffusivity_1eminus05/results_dilution_0.jld2",
#     "./results/inf_ELD_doc/diffusivity_1eminus06/results_dilution_0.jld2",
#     "./results/inf_ELD_doc/diffusivity_1eminus07/results_dilution_0.jld2",
#     "./results/inf_ELD_doc/diffusivity_1eminus08/results_dilution_0.jld2",
#     "./results/inf_ELD_doc/diffusivity_1eminus09/results_dilution_0.jld2",
#     # Add more paths as needed
# ]

# # use this for infinite ELD, kg10mps
# T = 15.0
# u10 = 10.0
# file_paths = [
#     "./results/inf_ELD_kg10mps_doc/diffusivity_1eminus04/results_dilution_0.jld2",
#     "./results/inf_ELD_kg10mps_doc/diffusivity_1eminus05/results_dilution_0.jld2",
#     "./results/inf_ELD_kg10mps_doc/diffusivity_1eminus06/results_dilution_0.jld2",
#     "./results/inf_ELD_kg10mps_doc/diffusivity_1eminus07/results_dilution_0.jld2",
#     "./results/inf_ELD_kg10mps_doc/diffusivity_1eminus08/results_dilution_0.jld2",
#     "./results/inf_ELD_kg10mps_doc/diffusivity_1eminus09/results_dilution_0.jld2",
#     # Add more paths as needed
# ]

# # use this for infinite ELD, kg25mps
# T = 15.0
# u10 = 25.0
# # file_paths = [
# #     # "./results/inf_ELD_kg25mps_noBuffering_doc/diffusivity_1eminus04/results_dilution_0.jld2",
# #     "./results/inf_ELD_kg25mps_noBuffering_doc/diffusivity_1eminus05/results_dilution_0.jld2",
# #     "./results/inf_ELD_kg25mps_noBuffering_doc/diffusivity_1eminus06/results_dilution_0.jld2",
# #     "./results/inf_ELD_kg25mps_noBuffering_doc/diffusivity_1eminus07/results_dilution_0.jld2",
# #     "./results/inf_ELD_kg25mps_noBuffering_doc/diffusivity_1eminus08/results_dilution_0.jld2",
# #     "./results/inf_ELD_kg25mps_noBuffering_doc/diffusivity_1eminus09/results_dilution_0.jld2",
# # ]
# file_paths = [
#     # "./results/inf_ELD_kg25mps_doc/diffusivity_1eminus04/results_dilution_0.jld2",
#     "./results/inf_ELD_kg25mps_doc/diffusivity_1eminus05/results_dilution_0.jld2",
#     "./results/inf_ELD_kg25mps_doc/diffusivity_1eminus06/results_dilution_0.jld2",
#     "./results/inf_ELD_kg25mps_doc/diffusivity_1eminus07/results_dilution_0.jld2",
#     "./results/inf_ELD_kg25mps_doc/diffusivity_1eminus08/results_dilution_0.jld2",
#     "./results/inf_ELD_kg25mps_doc/diffusivity_1eminus09/results_dilution_0.jld2",
# ]

# # use this for infinite MLD, 1m ELD, test files
# file_paths = [
#     "./results/inf_MLD_1m_ELD_test_doc/diffusivity_1eminus04/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_test_doc/diffusivity_1eminus05/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_test_doc/diffusivity_1eminus06/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_test_doc/diffusivity_1eminus07/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_test_doc/diffusivity_1eminus08/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_test_doc/diffusivity_1eminus09/results_dilution_0.jld2",
#     # Add more paths as needed
# ]

# # use this for infinite MLD, 1m ELD
# file_paths = [
#     "./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus04/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus05/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus06/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus07/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus08/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus09/results_dilution_0.jld2",
#     # Add more paths as needed
# ]



# Define a color palette with ordered, distinct colors
color_palette = Plots.palette(:viridis, length(file_paths))  # Choose a palette with enough colors

# Initialize the figure with a two-panel layout
plt = plot(layout=(3, 1),  # Two rows, one column
    size=(800, 800),        # Adjust size for better visibility
    xlabel="Time (days)",
    ylabel="Additionality (mol m⁻²)",
    title="Additionality Over Time",
    # legend=:topleft,  # Set legend position once here
    linewidth=2,        # Optional: Increase line width for better visibility
)

# Top panel: Plot additionality_flux over time
for (i, file_path) in enumerate(file_paths)
    local DIC, pCO2, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(file_path)
    diffusivity_label = extract_diffusivity(file_path)
    label_text = "\\(\\kappa = $diffusivity_label\\)" # LaTeX-style label

    # Plot additionality in the top panel
    plot!(plt[1], TI / 86400, additionality_dic, label=label_text, color=color_palette[i],
        xlabel="Time (days)", ylabel="Additionality (mol m⁻²)", title="Additionality Over Time",
        linewidth=2, legend=:topleft)    
end

# # Middle panel: Plot slopes (rate of change of additionality_flux)
# for (i, file_path) in enumerate(file_paths)
#     local DIC, pCO2, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(file_path)
#     diffusivity_label = extract_diffusivity(file_path)
#     label_text = "\\(\\kappa = $diffusivity_label\\)" # LaTeX-style label

#     # Calculate time in days and slope (gradient)
#     time_days = TI / 86400
#     slopes = diff(additionality) ./ diff(time_days)
    
#     # Adjust time array to match slope array length
#     midpoints = time_days[1:end-1] .+ diff(time_days) / 2
    
#     # Plot the slope in the mid-top panel
#     plot!(plt[2], midpoints, slopes, label="Slope of \\(\\kappa = $diffusivity_label\\)", color=color_palette[i],
#         xlabel="Time (days)", ylabel="Slope (mol m⁻² day⁻¹)", title="Rate of Change of Additionality",
#         linewidth=2, legend=:topright)
# end

# Middle panel: Plot surface pCO2 gradient over time
for (i, file_path) in enumerate(file_paths)
    local DIC, pCO2, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(file_path)
    diffusivity_label = extract_diffusivity(file_path)
    label_text = "\\(\\kappa = $diffusivity_label\\)"  # LaTeX-style label
    
    # Calculate e-folding timescale
    ΔpCO2_initial = ΔpCO2[1]
    ΔpCO2_threshold = ΔpCO2_initial / exp(1)
    # ΔpCO2_threshold = ΔpCO2_initial / 2
    e_folding_index = findfirst(x -> x >= ΔpCO2_threshold, ΔpCO2)
    if e_folding_index !== nothing
        e_folding_time = TI[e_folding_index] / 86400  # Convert to days
        # Output the e-folding time to the REPL
        println("E-folding time for \\(\\kappa = $diffusivity_label\\): $(round(e_folding_time, digits=2)) days")
    else
        println("E-folding time for \\(\\kappa = $diffusivity_label\\) not found within simulation time.")
    end

    # Calculate halving timescale
    ΔpCO2_initial = ΔpCO2[1]
    ΔpCO2_threshold = ΔpCO2_initial / 2
    # ΔpCO2_threshold = ΔpCO2_initial / 2
    halving_index = findfirst(x -> x >= ΔpCO2_threshold, ΔpCO2)
    if halving_index !== nothing
        halving_time = TI[halving_index] / 86400  # Convert to days
        # Output the e-folding time to the REPL
        println("Halving time for \\(\\kappa = $diffusivity_label\\): $(round(halving_time, digits=2)) days")
    else
        println("Halving time for \\(\\kappa = $diffusivity_label\\) not found within simulation time.")
    end
    
    # Plot ΔpCO2 in the bottom panel
    plot!(plt[2], TI / 86400, ΔpCO2, label=label_text, color=color_palette[i],
        xlabel="Time (days)", ylabel="ΔpCO₂ (μatm)", title="Surface pCO₂ Gradient Over Time",
        linewidth=2, legend=:topright)
end

# Bottom panel: Plot DIC over time
for (i, file_path) in enumerate(file_paths)
    local DIC, pCO2, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(file_path)
    diffusivity_label = extract_diffusivity(file_path)
    label_text = "\\(\\kappa = $diffusivity_label\\)" # LaTeX-style label
    
    # Plot surface DIC in bottom panel
    plot!(plt[3], TI / 86400, DIC[end,:], label=label_text, color=color_palette[i],
        xlabel="Time (days)", ylabel="DIC (μmol/kgSW)", title="Surface DIC Over Time",
        linewidth=2, legend=:topright)
end

# Diagnostic: trying to figure out the e-folding timescale dependence on kg and kappa
kg_m_per_s = PoseidonMRV.Utils.calculate_kg_wanninkhof(T, u10)[2]
println(kg_m_per_s)

# Display the final two-panel plot
display(plt)

# # Optionally, save the plot to a file
savefig(plt, "additionality_over_time_inf_ELD_kg6mps.png")



## DIAGNOSTIC PLOTS 

# # Heatmap of DIC_p over time and depth
# DIC, pCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data("./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus04/results_dilution_0.jld2") # load data for heatmap
# # Reverse `z` if it's in descending order and sort `DIC_p` rows accordingly
# isdescending(v) = all(x -> x[1] >= x[2], zip(v, v[2:end]))
# if isdescending(z)
#     z_ascending = reverse(z)                # Sort `z` in ascending order
#     DIC_reversed = reverse(DIC, dims=1)  # Reverse rows of `DIC_p` to match `z`
# end
# heatmap(TI / 86400, z_ascending, DIC_reversed, 
#     xlabel="Time (days)", 
#     ylabel="Depth (m)", 
#     title="DIC Concentration Over Time and Depth", 
#     color=:viridis,
#     yflip=true,
#     # ylims=(95, 101) # Set the desired depth range
# )


# # Heatmap of pCO2_p over time and depth
# DIC, pCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data("./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus06/results_dilution_0.jld2") # load data for heatmap
# # Reverse `z` if it's in descending order and sort `DIC_p` rows accordingly
# isdescending(v) = all(x -> x[1] >= x[2], zip(v, v[2:end]))
# if isdescending(z)
#     z_ascending = reverse(z)                # Sort `z` in ascending order
#     pCO2_reversed = reverse(pCO2, dims=1)  # Reverse rows of `DIC_p` to match `z`
# end
# heatmap(TI / 86400, z_ascending, pCO2_reversed, 
#     xlabel="Time (days)", 
#     ylabel="Depth (m)", 
#     title="pCO2 over Time and Depth", 
#     color=:viridis,
#     yflip=true,
#     # ylims=(95, 101) # Set the desired depth range
# )
