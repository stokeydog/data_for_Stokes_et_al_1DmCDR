using JLD2
using Plots
using PlotUtils
using PoseidonMRV
using Interpolations
using Measures

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

# load data from any path for the configuration in question
path_for_config = "results/block_model/inf_MLD_variable_dilution_doc_alpha_1.0_fixed_Bic/results_dilution_0.0.jld2"
data = JLD2.jldopen(path_for_config) do file
    read(file, "simulation_results")
end

# This is for DOC, need to adapt code to accept both DOC and OAE, also this uses fixed/assumed rho
# Actual initial deficit
V0 = data["input"]["config"]["pert_props"]["perturbation_volume"]
A0 = 1.0

initial_deficit_actual = (
    ( data["input"]["config"]["ocn_props"]["dic_sw"]
    - data["input"]["config"]["pert_props"]["dic_pert"]) 
    * 1025 * V0 * 1e-6
    ) # mol

# Calculated initial deficit
initial_deficit_calculated = (
    sum(data["output"]["DIC_up"][:,1] .- data["output"]["DIC_p"][:,1])
    * data["input"]["config"]["depth_grid"]["dz"]
    * 1025 * V0 * 1e-6
    ) # mol

# for debugging
final_deficit_calculated = (
    sum(data["output"]["DIC_up"][:,end] .- data["output"]["DIC_p"][:,end], dims=1)
    * data["input"]["config"]["depth_grid"]["dz"]
    * 1025 * V0 * 1e-6
    ) # mol

# results paths
path_to_alpha_0p0 = "results/block_model/inf_MLD_variable_dilution_doc_alpha_0.0_fixed_Bic"
path_to_alpha_0p2 = "results/block_model/inf_MLD_variable_dilution_doc_alpha_0.2_fixed_Bic"
path_to_alpha_0p4 = "results/block_model/inf_MLD_variable_dilution_doc_alpha_0.4_fixed_Bic"
path_to_alpha_0p6 = "results/block_model/inf_MLD_variable_dilution_doc_alpha_0.6_fixed_Bic"
path_to_alpha_0p8 = "results/block_model/inf_MLD_variable_dilution_doc_alpha_0.8_fixed_Bic"
path_to_alpha_1p0 = "results/block_model/inf_MLD_variable_dilution_doc_alpha_1.0_fixed_Bic"

file_paths_alpha_0p0 = readdir(path_to_alpha_0p0)
file_paths_alpha_0p2 = readdir(path_to_alpha_0p2)
file_paths_alpha_0p4 = readdir(path_to_alpha_0p4)
file_paths_alpha_0p6 = readdir(path_to_alpha_0p6)
file_paths_alpha_0p8 = readdir(path_to_alpha_0p8)
file_paths_alpha_1p0 = readdir(path_to_alpha_1p0)

# Dilution and anisotropy to be analyzed
dilution_values = [0.0, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0, 200.0, 500.0, 1000.0]
alpha_values = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]

# Time to calculate additionality/efficiency
target_time_days = 10.0

# Prepare data storage
n_alpha     = length(alpha_values)
n_dilutions = length(dilution_values)

final_additionality = Matrix{Float64}(undef, n_alpha, n_dilutions)
final_efficiency    = Matrix{Float64}(undef, n_alpha, n_dilutions)

# Put file lists into an array in the same order as the alpha values
file_paths_list = [
    file_paths_alpha_0p0, 
    file_paths_alpha_0p2, 
    file_paths_alpha_0p4, 
    file_paths_alpha_0p6, 
    file_paths_alpha_0p8, 
    file_paths_alpha_1p0
    ]

function parse_dilution_from_filename(filename::String)
    m = match(r"results_dilution_(\d+\.?\d*)", filename) # regex patterns make no sense to me, but this one works
    if m === nothing
        error("Could not parse dilution from filename: $filename")
    end
    return parse(Float64, m.captures[1])
end

sorted_paths = Vector{Vector{String}}()
for i in 1:length(file_paths_list)
    sorted_paths_tmp = sort(file_paths_list[i], by=parse_dilution_from_filename)
    push!(sorted_paths, sorted_paths_tmp)
end

final_additionality = Matrix{Float64}(undef, length(alpha_values), length(dilution_values))
final_efficiency   = Matrix{Float64}(undef, length(alpha_values), length(dilution_values))

for (i, alpha) in enumerate(alpha_values)
    # This subarray is a sorted list of file paths for alpha[i]
    file_list_for_this_alpha = sorted_paths[i]

    # Create a results_map from dilution => total_add_3D
    results_map = Dict{Float64, Float64}()

    # Loop over each file path in file_list_for_this_alpha
    for fp in file_list_for_this_alpha
        S_parsed = parse_dilution_from_filename(fp)

        A_mixed = A0 .* (1.0 .+ S_parsed) .^ alpha
        # H_mixed = H0 .* (1.0 .+ S_parsed) .^ (1.0 .- alpha)
        local path_for_config = "results/block_model/inf_MLD_variable_dilution_doc_alpha_$(alpha)_fixed_Bic/results_dilution_$(S_parsed).jld2"
        local data = JLD2.jldopen(path_for_config) do file
            read(file, "simulation_results")
        end
        add_debug = ((sum(data["output"]["DIC_p"][:,:] .- data["output"]["DIC_up"][:,:], dims=1)
            .- sum(data["output"]["DIC_p"][:,1] .- data["output"]["DIC_up"][:,1], dims=1))
            .* data["input"]["config"]["depth_grid"]["dz"]
            .* A_mixed .* 1025 .* 1e-6
            )# [umol]
        add_orig  = data["output"]["additionality_dic"] .* A_mixed

        local _, target_time_idx = findmin(abs.(Vector(data["output"]["TI"]./86400) .- target_time_days))
        results_map[S_parsed] = add_orig[target_time_idx]

        if (alpha == 0.0) && (S_parsed == 0.0)
            global add_ref = results_map[S_parsed]
        end
    end 

    # Now fill in final_additionality and final_efficiency for this alpha
    for (j, S) in enumerate(dilution_values)
        val = get(results_map, S, NaN)  # if S not in results_map => NaN
        final_additionality[i, j] = val
        final_efficiency[i, j] = val / initial_deficit_calculated
    end
end

# Plot the results
p = Plots.palette(:viridis, 6)
p2 = Plots.palette(:viridis, 7)

dilution_values_plot = dilution_values
dilution_values_plot[1] = 0.5

# Top panel, plot "relative additionality" (how much the dilution effects the additionality)
plt1 = plot(
    xscale = :log10,
    # xticks = (dilution_values_plot,
    # ["0","1","2","5","10","20","50","100", "200", "500","1000"]),
    xticks = ([0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
                20, 30, 40, 50, 60, 70, 80, 90, 100,
                200, 300, 400, 500, 600, 700, 800, 900, 1000],
            ["0","1","2","","","5","","","","","10",
            "20","","","50","","","","","100",
            "200","","","500","","","","","1000"]),
    xlabel = "Dilution Ratio",
    ylabel = "Relative Additionality: \$A(S)\\,/\\, A(S=0)\$",
    title  = "$(Int(target_time_days))-day Relative Additionality vs. Anisotropic Dilution",
    # left_margin = 10mm,
    # right_margin = 10mm,
    # top_margin = 10mm,
    # bottom_margin = 10mm,
    xminorgrid = true,
)

for (i, α) in enumerate(alpha_values)
    # Y-values = final_additionality for this alpha, all dilutions
    yvals = final_additionality[i, :] ./ add_ref
    plot!(
        dilution_values_plot,
        yvals;
        label = "\$\\alpha\$ = $(α)",
        lw = 2,
        marker = :o,
        palette = p
    )
end
plot!([0.45,1400.0],[1,1];
    lw = 3,
    style = :dot,
    color = :black,
    label = nothing,
    ylims = (0,3),
    legend = :topleft
)

# Extract the curves for α = 0.4 and α = 0.6.
i_low = findfirst(==(0.4), alpha_values)
i_high = findfirst(==(0.6), alpha_values)

if i_low !== nothing && i_high !== nothing
    y_low = final_additionality[i_low, :] ./ add_ref
    y_high = final_additionality[i_high, :] ./ add_ref

    # Add shading between the two curves using fillrange.
    plot!(dilution_values_plot, y_low,
          fillrange = y_high,
          fillalpha = 0.3,   # adjust transparency as needed
          fillcolor = p2[4], # choose a color halfway between alpha 0.4 and 0.6
          linecolor = :transparent,  
          label = "")
end

# Panel 2: Efficiency vs. Dilution 
plt2 = plot(
    xscale = :log10,
    xticks = (dilution_values_plot,
    ["0","1","2","5","10","20","50","100","200","500","1000"]),
    xlabel = "Dilution Ratio",
    ylabel = "Efficiency [–]",
    title  = "Block Model Efficiency vs. Dilution"
)

for (i, α) in enumerate(alpha_values)
    yvals = final_efficiency[i, :]
    plot!(
        dilution_values_plot,
        yvals;
        label = "\$\\alpha\$ = $(α)",
        lw = 2,
        marker = :diamond,
        palette = p
    )
end

# Combine into a 2-row layout:
plot(plt1, plt2; layout=(2,1), size=(800, 800))

# display(plt1)


