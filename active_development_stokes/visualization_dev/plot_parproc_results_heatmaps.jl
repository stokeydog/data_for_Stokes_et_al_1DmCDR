using JLD2
using Plots
using PoseidonMRV
using LaTeXStrings
using ColorSchemes

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

# use this for infinite ELD, kg25mps
file_paths = [
    "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus03/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus04/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus05/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus06/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus07/results_dilution_100.jld2",
    "./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus08/results_dilution_100.jld2",
]

# Define a color palette with ordered, distinct colors
color_palette = Plots.palette(:viridis, length(file_paths))  # Choose a palette with enough colors

# Define caxis range and neutral value
cmin = 2040
cmax = 2075
neutral_value = 2050

# Normalize data range to [0, 1]
normalize(value, min, max) = (value - min) / (max - min)

# Find normalized positions of cmin, neutral_value, and cmax
neutral_pos = normalize(neutral_value, cmin, cmax)
nlevels = 9

# Create a diverging colormap centered at the neutral value
custom_palette = cgrad(
    [RGB(0.804/1.5, 0.322/2, 0.000),  # Burnt Orange for low values
     RGB(0.865, 0.865, 0.865),  # White/Gray for neutral
     RGB(0.000, 0.424/2, 0.769/1.5)], # Grayish Blue for high values
    [0.0, neutral_pos, 1.0],      # Positions for the colors
    # nlevels,
)
discrete_palette = custom_palette[range(0, stop=1, length=nlevels)]

Bi_c = [0.01, 0.1, 1, 10, 100, 1000]
t_target = [1.0, 20.0, 50.0, 100.0]  # days

# Initialize the figure with a two-panel layout
plt = plot(layout=(3, 1),  # Two rows, one column
    size=(800, 600),        # Adjust size for better visibility
    link=:both,
    # caxis=(2040, 2080),
    # legend=:topleft,  # Set legend position once here
    # linewidth=2,        # Optional: Increase line width for better visibility
)

# Top panel: DIC heatmap, low Bi_c
DIC_p, DIC_up, pCO2_p, ΔpCO2_p, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data("./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus03/results_dilution_100.jld2") # load data for heatmap
# Reverse `z` if it's in descending order and sort `DIC_p` rows accordingly
isdescending(v) = all(x -> x[1] >= x[2], zip(v, v[2:end]))
# if isdescending(z)
    z_ascending = reverse(z)                # Sort `z` in ascending order
    DIC_reversed = reverse(DIC_p, dims=1)  # Reverse rows of `DIC_p` to match `z`
# else
#     z_ascending = z
#     DIC_reversed = DIC
# end
heatmap!(plt[1], TI / 86400, z_ascending, DIC_reversed, 
    # xlabel="Time (days)", 
    ylabel="Depth (m)", 
    # title="DIC Concentration Over Time and Depth, Bi\$_c\$ = 0.01", 
    ylim=[25,30],
    clims=(cmin, cmax),
    # color=:viridis,
    color=discrete_palette,
    yflip=true,
    yticks=(25:30,["0","1","2","3","4","5"]),
    # ylims=(95, 101) # Set the desired depth range
)

# Middle panel: DIC heatmap, Bi_c ~ 1
DIC_p, DIC_up, pCO2_p, ΔpCO2_p, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data("./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus06/results_dilution_100.jld2") # load data for heatmap
# Reverse `z` if it's in descending order and sort `DIC_p` rows accordingly
isdescending(v) = all(x -> x[1] >= x[2], zip(v, v[2:end]))
# if isdescending(z)
    z_ascending = reverse(z)                # Sort `z` in ascending order
    DIC_reversed = reverse(DIC_p, dims=1)  # Reverse rows of `DIC_p` to match `z`
# else
#     z_ascending = z
#     DIC_reversed = DIC
# end
heatmap!(plt[2], TI / 86400, z_ascending, DIC_reversed, 
    # xlabel="Time (days)", 
    ylabel="Depth (m)", 
    # title="DIC Concentration Over Time and Depth, Bi\$_c\$ = 1.0",
    ylim=[25,30], 
    color=discrete_palette,
    yflip=true,
    yticks=(25:30,["0","1","2","3","4","5"]),
    # ylims=(95, 101) # Set the desired depth range
    clims=(cmin, cmax),
)

# Bottom panel: DIC heatmap, Bi_c ~ 1000
DIC_p, DIC_up, pCO2_p, ΔpCO2_p, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data("./results/inf_MLD_Bic_range_u6p63_10mEffLayer_doc/diffusivity_3eminus06/results_dilution_100.jld2") # load data for heatmap
# Reverse `z` if it's in descending order and sort `DIC_p` rows accordingly
isdescending(v) = all(x -> x[1] >= x[2], zip(v, v[2:end]))
# if isdescending(z)
    z_ascending = reverse(z)                # Sort `z` in ascending order
    DIC_reversed = reverse(DIC_p, dims=1)  # Reverse rows of `DIC_p` to match `z`
# else
#     z_ascending = z
#     DIC_reversed = DIC
# end
heatmap!(plt[3], TI / 86400, z_ascending, DIC_reversed, 
    xlabel="Time (days)", 
    ylabel="Depth (m)", 
    # ylim=[25,30],
    clims=(cmin, cmax),
    # title="DIC Concentration Over Time and Depth, Bi\$_c\$ = 100", 
    color=discrete_palette,
    yflip=true,
    # yticks=(25:30,["0","1","2","3","4","5"]),
    # ylims=(95, 101) # Set the desired depth range
)




# # Heatmap of DIC_p over time and depth

# Display the final two-panel plot
display(plt)

# # Optionally, save the plot to a file
# savefig(plt, "additionality_over_time_inf_ELD_kg6mps.png")

