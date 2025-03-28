"""
The drawdown should be the same whether calculated from flux or from dic.
This code serves as a sort of convergence test to make sure that is the case.
If this fails, check resolution etc to figure out why the inconsistency.
"""

include(joinpath(@__DIR__, "calc_drawdown_from_flux_1D.jl"))
include(joinpath(@__DIR__, "calc_drawdown_from_dic_1D.jl"))
include(joinpath(@__DIR__, "../utils/interp_time_series.jl"))

function compare_drawdown_flux_vs_dic_1D(
    F::Vector{Float64},
    tiF::Vector{Float64},
    dt::Int64,
    DIC::Matrix{Float64},
    rho_matrix::Matrix{Float64},
    TI::StepRange{Int64, Int64},
    grid::AbstractGrid
)
    # Calculate drawdown from flux over time
    drawdown_flux = calc_drawdown_from_flux_1D(F, dt)  # mol m⁻²

    # Interpolate drawdown_flux to the times of DIC outputs
    drawdown_flux_interp = interp_time_series(drawdown_flux, tiF, TI)
    drawdown_flux_interp .-= drawdown_flux_interp[1]

    # Calculate drawdown from DIC over time
    drawdown_dic = calc_drawdown_from_dic_1D(DIC, rho_matrix, grid)  # mol m⁻²

    # Compute difference over time
    drawdown_difference = drawdown_dic .- drawdown_flux_interp
    drawdown_relative_difference = drawdown_difference ./ drawdown_dic * 100  # Percentage

    # Print summary statistics (Commented out for parallel runs)
    # println("Final carbon drawdown from flux: ", drawdown_flux_interp[end], " mol m⁻²")
    # println("Final carbon drawdown from DIC: ", drawdown_dic[end], " mol m⁻²")
    # println("Final absolute difference: ", drawdown_difference[end], " mol m⁻²")
    # println("Final relative difference: ", drawdown_relative_difference[end], " %")

    return drawdown_flux_interp, drawdown_dic, drawdown_difference, drawdown_relative_difference
end
