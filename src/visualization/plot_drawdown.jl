using Plots

function plot_drawdown(
    TI::StepRange{Int64, Int64}, 
    drawdown_dic::Vector{Float64}, 
    drawdown_flux_interp::Vector{Float64}, 
    drawdown_difference::Vector{Float64}, 
    drawdown_relative_difference::Vector{Float64}
)

    # Plot cumulative uptake from both methods
    Plots.plot(
        TI ./ 86400, drawdown_dic,
        label = "Drawdown Calculated from DIC Profiles",
        xlabel = "Time [days]",
        ylabel = "Cumulative Carbon Drawdown [mol m⁻²]",
        title = "Carbon Drawdown Over Time",
        legend = :bottomright
    )
    Plots.plot!(
        TI ./ 86400, drawdown_flux_interp,
        label = "Drawdown Calculated from Flux",
        linestyle = :dash
    )

    # Plot absolute difference over time
    Plots.plot(
        TI ./ 86400, drawdown_difference,
        label = "Absolute Difference",
        xlabel = "Time [days]",
        ylabel = "Difference [mol m⁻²]",
        title = "Difference in Carbon Drawdown Over Time"
    )

    # Plot relative difference over time
    Plots.plot(
        TI ./ 86400, drawdown_relative_difference,
        label = "Relative Difference",
        xlabel = "Time [days]",
        ylabel = "Relative Difference [%]",
        title = "Relative Difference in Carbon Drawdown Over Time"
    )

end