using Plots

function plot_additionality(
    TI::StepRange{Int64, Int64}, 
    additionality_dic::Vector{Float64}, 
    additionality_flux::Vector{Float64}
)

    # Plot cumulative uptake from both methods
    Plots.plot(
        TI ./ 86400, additionality_dic,
        label = "Additionality Calculated from DIC Profiles",
        xlabel = "Time [days]",
        ylabel = "Cumulative Additionality [mol m⁻²]",
        title = "Additionality Over Time",
        legend = :bottomright
    )
    Plots.plot!(
        TI ./ 86400, additionality_flux,
        label = "Additionality Calculated from Flux",
        linestyle = :dash
    )

end