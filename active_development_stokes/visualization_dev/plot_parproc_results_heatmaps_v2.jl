using JLD2
using Plots
using ColorSchemes  # For cgrad and color utilities

# 1) LOAD DATA: same as your existing function
function load_simulation_data(file_path)
    data = JLD2.jldopen(file_path) do file
        read(file, "simulation_results")
    end
    return (
        data["output"]["DIC_p"],
        data["output"]["DIC_up"],
        data["output"]["pCO2_p"],
        data["output"]["ΔpCO2_p"],
        data["output"]["TI"],
        data["output"]["z"],
        data["output"]["additionality"],
        data["output"]["additionality_flux"],
        data["output"]["additionality_dic"]
    )
end

# 2) CREATE A DISCRETE DIVERGING COLORMAP
function make_discrete_diverging_cmap(
    cmin::Real, cmax::Real, neutral_value::Real;
    nlevels::Int = 9
)
    # Convert the neutral_value to a fraction between 0 and 1
    neutral_pos = (neutral_value - cmin) / (cmax - cmin)

    # (a) Define a continuous gradient with custom positions
    continuous_grad = cgrad(
        [
            # Low color (burnt orange)
            RGB(0.536, 0.161, 0.000),
            # Neutral color (white/gray)
            RGB(1.000,     1.000,    1.000),
            # High color (grayish blue)
            RGB(0.000,     0.212,  0.513)
        ],
        [0.0, neutral_pos, 1.0]  # positions: [cmin -> neutral -> cmax]
    )

    # (b) Sample the continuous gradient at nlevels evenly spaced points
    sample_points = range(0, stop=1, length=nlevels)
    discrete_colors = [continuous_grad[x] for x in sample_points]

    # (c) Mark it as categorical to prevent interpolation between the sampled colors
    return cgrad(discrete_colors, categorical=true)
end

# 3) BUILD THE DISCRETE PALETTE
cmin, cmax = 2040, 2075
neutral_value = 2050
nlevels = 29
discrete_palette = make_discrete_diverging_cmap(cmin, cmax, neutral_value; nlevels=nlevels)

# 4) PREPARE A MULTI-PANEL PLOT
plt = plot(layout=(3, 1), size=(800, 600))  # 3 rows, 1 column

# Helper to reverse depth if needed
isdescending(v) = all(x -> x[1] >= x[2], zip(v, v[2:end]))

##############################
#  PLOT 1
##############################
DIC_p, _, _, _, TI, z, _, _, _ =
    load_simulation_data("./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus03/results_dilution_100.jld2")

z_ascending = isdescending(z) ? reverse(z) : z
DIC_reversed = isdescending(z) ? reverse(DIC_p, dims=1) : DIC_p

heatmap!(
    plt[1], TI ./ 86400, z_ascending, DIC_reversed;
    clims=(cmin, cmax),
    color=discrete_palette,
    yflip=true,
    ylim=(25, 30),
    ylabel="Depth (m)"
)

##############################
#  PLOT 2
##############################
DIC_p, _, _, _, TI, z, _, _, _ =
    load_simulation_data("./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus06/results_dilution_100.jld2")

z_ascending = isdescending(z) ? reverse(z) : z
DIC_reversed = isdescending(z) ? reverse(DIC_p, dims=1) : DIC_p

heatmap!(
    plt[2], TI ./ 86400, z_ascending, DIC_reversed;
    clims=(cmin, cmax),
    color=discrete_palette,
    yflip=true,
    ylim=(25, 30),
    ylabel="Depth (m)"
)

##############################
#  PLOT 3
##############################
DIC_p, _, _, _, TI, z, _, _, _ =
    load_simulation_data("./results/inf_MLD_Bic_range_u6p63_1mEffLayer_RESOLVED_doc/diffusivity_3eminus08/results_dilution_100.jld2")

z_ascending = isdescending(z) ? reverse(z) : z
DIC_reversed = isdescending(z) ? reverse(DIC_p, dims=1) : DIC_p

heatmap!(
    plt[3], TI ./ 86400, z_ascending, DIC_reversed;
    clims=(cmin, cmax),
    color=discrete_palette,
    yflip=true,
    ylim=(25, 30),
    xlabel="Time (days)",
    ylabel="Depth (m)"
)

##############################
#  SHOW / SAVE PLOT
##############################
display(plt)
# savefig(plt, "discrete_cmap_heatmaps.png")
