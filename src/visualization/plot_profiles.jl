# using Makie
using CairoMakie

function plot_profiles(
    ALK::Matrix{Float64},
    DIC::Matrix{Float64},
    pH::Matrix{Float64},
    pCO2::Matrix{Float64},
    ΔpCO2::Vector{Float64},
    F::Vector{Float64},
    tiF::Vector{Float64},
    z::Vector{Float64},
    TI::StepRange{Int64, Int64}
)
    # Define the number of profiles to plot to avoid clutter
    max_profiles = 10
    step = max(1, div(size(ALK, 2), max_profiles))  # Plot up to 10 profiles

    # Alkalinity Profiles Over Time
    fig1 = Figure(size = (1200, 800))
    ax1 = Axis(fig1[1, 1], xlabel = "Alkalinity [µmol/kgSW]", ylabel = "Depth [m]", title = "Alkalinity Profiles Over Time", yreversed = true)
    for i in 1:step:size(ALK, 2)
        lines!(ax1, ALK[:, i], z, label = "t = $(round(TI[i]/86400, digits=2)) days")
    end
    legend1 = Legend(fig1, ax1, orientation = :vertical)
    fig1[1, 2] = legend1

    # DIC Profiles Over Time
    ax2 = Axis(fig1[2, 1], xlabel = "DIC [µmol/kgSW]", ylabel = "Depth [m]", title = "DIC Profiles Over Time", yreversed = true)
    for i in 1:step:size(DIC, 2)
        lines!(ax2, DIC[:, i], z, label = "t = $(round(TI[i]/86400, digits=2)) days")
    end
    legend2 = Legend(fig1, ax2, orientation = :vertical)
    fig1[2, 2] = legend2

    # pH Profiles Over Time
    fig2 = Figure(size = (1200, 800))
    ax3 = Axis(fig2[1, 1], xlabel = "pH", ylabel = "Depth [m]", title = "pH Profiles Over Time", yreversed = true)
    for i in 1:step:size(pH, 2)
        lines!(ax3, pH[:, i], z, label = "t = $(round(TI[i]/86400, digits=2)) days")
    end
    legend3 = Legend(fig2, ax3, orientation = :vertical)
    fig2[1, 2] = legend3

    # pCO2 Profiles Over Time
    ax4 = Axis(fig2[2, 1], xlabel = "pCO2 [µatm]", ylabel = "Depth [m]", title = "pCO2 Profiles Over Time", yreversed = true)
    for i in 1:step:size(pCO2, 2)
        lines!(ax4, pCO2[:, i], z, label = "t = $(round(TI[i]/86400, digits=2)) days")
    end
    legend4 = Legend(fig2, ax4, orientation = :vertical)
    fig2[2, 2] = legend4

    # ΔpCO2 Over Time
    fig3 = Figure(size = (1200, 800))
    ax5 = Axis(fig3[1, 1], xlabel = "Time [days]", ylabel = "ΔpCO2 [µatm]", title = "ΔpCO2 Over Time")
    lines!(ax5, TI ./ 86400, ΔpCO2, label = "ΔpCO2", color = :red)
    legend5 = Legend(fig3, ax5, orientation = :horizontal)
    fig3[1, 2] = legend5

    # CO2 Flux Over Time
    ax6 = Axis(fig3[2, 1], xlabel = "Time [days]", ylabel = "CO₂ Flux [mol m⁻² s⁻¹]", title = "CO₂ Flux Over Time")
    lines!(ax6, tiF ./ 86400, F, label = "F", color = :blue)
    legend6 = Legend(fig3, ax6, orientation = :horizontal)
    fig3[2, 2] = legend6

    # Display Figures
    display(fig1)
    # display(fig2)
    # display(fig3)
end
