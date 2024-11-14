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
    TI = data["output"]["TI"]
    z = data["output"]["z"]
    additionality = data["output"]["additionality"]
    additionality_flux = data["output"]["additionality_flux"]
    additionality_dic = data["output"]["additionality_dic"]
    return DIC, pCO2_p, TI, z, additionality, additionality_flux, additionality_dic
end

# Function to extract diffusivity from the file path
function extract_diffusivity(file_path)
    match_result = match(r"diffusivity_(\d+eminus\d+)", file_path)
    return match_result !== nothing ? match_result.captures[1] : "unknown"
end

# Vector of file paths for different diffusivities

# # use this for infinite ELD
# file_paths = [
#     "./results/inf_ELD_doc/diffusivity_1eminus04/results_dilution_0.jld2",
#     "./results/inf_ELD_doc/diffusivity_1eminus05/results_dilution_0.jld2",
#     "./results/inf_ELD_doc/diffusivity_1eminus06/results_dilution_0.jld2",
#     "./results/inf_ELD_doc/diffusivity_1eminus07/results_dilution_0.jld2",
#     "./results/inf_ELD_doc/diffusivity_1eminus08/results_dilution_0.jld2",
#     "./results/inf_ELD_doc/diffusivity_1eminus09/results_dilution_0.jld2",
#     # Add more paths as needed
# ]

# use this for infinite MLD, 1m ELD
file_paths = [
    "./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus04/results_dilution_0.jld2",
    "./results/inf_MLD_1m_ELD_doc/diffusivity_4eminus05/results_dilution_0.jld2",
    "./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus05/results_dilution_0.jld2",
    "./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus06/results_dilution_0.jld2",
    "./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus07/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus08/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus09/results_dilution_0.jld2",
    # Add more paths as needed
]

# use this for infinite MLD, 10m ELD
# file_paths = [
#     "./results/inf_MLD_1m_ELD_Biot_analysis_doc/diffusivity_4eminus04/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_Biot_analysis_doc/diffusivity_4eminus05/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_Biot_analysis_doc/diffusivity_4eminus06/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_Biot_analysis_doc/diffusivity_4eminus07/results_dilution_0.jld2",
#     "./results/inf_MLD_1m_ELD_Biot_analysis_doc/diffusivity_8eminus07/results_dilution_0.jld2",
# #     "./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus08/results_dilution_0.jld2",
# #     "./results/inf_MLD_1m_ELD_doc/diffusivity_1eminus09/results_dilution_0.jld2",
#     # Add more paths as needed
# ]

# Define a color palette with ordered, distinct colors
color_palette = Plots.palette(:viridis, length(file_paths))  # Choose a palette with enough colors

# Initialize the plot and assign it to a variable
plt = plot(
    xlabel="Time (days)",
    ylabel="Additionality (mol m⁻²)",
    title="Additionality Over Time",
    legend=:topleft,  # Set legend position once here
    # size=(800, 600),   # Optional: Adjust size as needed
    linewidth=2        # Optional: Increase line width for better visibility
)

# Loop over file paths to load data and plot each line with a legend label
for (i, file_path) in enumerate(file_paths)
    DIC, pCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(file_path)
    diffusivity_label = extract_diffusivity(file_path)  # Extract diffusivity
    
    # Create a LaTeX-style label
    label_text = "\\(\\kappa = $diffusivity_label\\)"
    
    # Assign the color from the palette
    color_i = color_palette[i]
    
    # Plot each line with the assigned color
    plot!(plt, TI/86400, additionality_flux, label=label_text, color=color_i)
end

# Display the final plot
display(plt)

# # Optionally, save the plot to a file
savefig(plt, "additionality_over_time_inf_ELD.png")

# # Heatmap of DIC_p over time and depth
# DIC, TI, z, additionality = load_simulation_data("./results/inf_ELD_doc/diffusivity_1eminus07/results_dilution_0.jld2") # load data for heatmap
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
#     ylims=(95, 101) # Set the desired depth range
# )


# # Heatmap of pCO2_p over time and depth
# DIC, pCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data("./results/inf_ELD_doc/diffusivity_1eminus05/results_dilution_0.jld2") # load data for heatmap
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
#     ylims=(95, 101) # Set the desired depth range
# )
