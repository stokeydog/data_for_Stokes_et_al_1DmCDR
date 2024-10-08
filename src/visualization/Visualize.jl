# src/visualization/Visualize.jl
module Visualize

export plot_results

using Makie
using ..Utils

"""
    plot_results(ALK::Matrix{Float64}, DIC::Matrix{Float64}, pH::Matrix{Float64}, pCO2::Matrix{Float64}, ΔpCO2::Vector{Float64}, F::Vector{Float64}, tiF::Vector{Float64}, z::Vector{Float64}, ti::Vector{Float64})

Plots the results of the Crank-Nicolson simulation using Makie.jl, including Alkalinity, DIC, pH, pCO2 profiles over time, and CO₂ flux.

# Arguments
- `ALK::Matrix{Float64}`: Alkalinity matrix [nz × NT+1].
- `DIC::Matrix{Float64}`: DIC matrix [nz × NT+1].
- `pH::Matrix{Float64}`: pH matrix [nz × NT+1].
- `pCO2::Matrix{Float64}`: pCO₂ matrix [nz × NT+1].
- `ΔpCO2::Vector{Float64}`: Change in pCO₂ over time [NT+1].
- `F::Vector{Float64}`: CO₂ flux over time [nt-1].
- `tiF::Vector{Float64}`: Time grid for flux [nt-1].
- `z::Vector{Float64}`: Depth grid [nz].
- `ti::Vector{Float64}`: Time grid [nt].
"""
function plot_results(
    ALK::Matrix{Float64},
    DIC::Matrix{Float64},
    pH::Matrix{Float64},
    pCO2::Matrix{Float64},
    ΔpCO2::Vector{Float64},
    F::Vector{Float64},
    tiF::Vector{Float64},
    z::Vector{Float64},
    ti::Vector{Float64}
)
    # Define the number of profiles to plot to avoid clutter
    max_profiles = 10
    step = max(1, div(size(ALK, 2), max_profiles))  # Plot up to 10 profiles

    # Alkalinity Profiles Over Time
    fig1 = Figure(resolution = (1200, 800))
    ax1 = Axis(fig1[1, 1], xlabel = "Alkalinity [µmol/kgSW]", ylabel = "Depth [m]", title = "Alkalinity Profiles Over Time", yreverse=true)
    for i in 1:step:size(ALK, 2)
        lines!(ax1, ALK[:, i], z, label = "t = $(round(ti[i]/86400, digits=2)) days")
    end
    AxisLegend(fig1[1, 2], ax1, orientation = :vertical, title = "Time Steps")

    # DIC Profiles Over Time
    ax2 = Axis(fig1[2, 1], xlabel = "DIC [µmol/kgSW]", ylabel = "Depth [m]", title = "DIC Profiles Over Time", yreverse=true)
    for i in 1:step:size(DIC, 2)
        lines!(ax2, DIC[:, i], z, label = "t = $(round(ti[i]/86400, digits=2)) days")
    end
    AxisLegend(fig1[2, 2], ax2, orientation = :vertical, title = "Time Steps")

    # pH Profiles Over Time
    fig2 = Figure(resolution = (1200, 800))
    ax3 = Axis(fig2[1, 1], xlabel = "pH", ylabel = "Depth [m]", title = "pH Profiles Over Time", yreverse=true)
    for i in 1:step:size(pH, 2)
        lines!(ax3, pH[:, i], z, label = "t = $(round(ti[i]/86400, digits=2)) days")
    end
    AxisLegend(fig2[1, 2], ax3, orientation = :vertical, title = "Time Steps")

    # pCO2 Profiles Over Time
    ax4 = Axis(fig2[2, 1], xlabel = "pCO2 [µatm]", ylabel = "Depth [m]", title = "pCO2 Profiles Over Time", yreverse=true)
    for i in 1:step:size(pCO2, 2)
        lines!(ax4, pCO2[:, i], z, label = "t = $(round(ti[i]/86400, digits=2)) days")
    end
    AxisLegend(fig2[2, 2], ax4, orientation = :vertical, title = "Time Steps")

    # ΔpCO2 Over Time
    fig3 = Figure(resolution = (1200, 800))
    ax5 = Axis(fig3[1, 1], xlabel = "Time [days]", ylabel = "ΔpCO2 [µatm]", title = "ΔpCO2 Over Time")
    lines!(ax5, tiF ./ 86400, ΔpCO2, label = "ΔpCO2", color = :red)
    Legend(fig3[1, 2], ax5, orientation = :horizontal)

    # CO2 Flux Over Time
    ax6 = Axis(fig3[2, 1], xlabel = "Time [days]", ylabel = "CO₂ Flux [mol m⁻² s⁻¹]", title = "CO₂ Flux Over Time")
    lines!(ax6, tiF ./ 86400, F, label = "F", color = :blue)
    Legend(fig3[2, 2], ax6, orientation = :horizontal)

    # Display Figures
    display(fig1)
    display(fig2)
    display(fig3)
end

end # module
