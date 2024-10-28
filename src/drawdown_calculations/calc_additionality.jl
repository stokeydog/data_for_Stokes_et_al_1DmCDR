include(joinpath(@__DIR__, "calc_drawdown_from_dic_1D.jl"))

function calc_additionality(
    DIC_up::Matrix{Float64},
    DIC_p::Matrix{Float64},
    rho_matrix::Matrix{Float64},
    grid::AbstractGrid
)

    # Set up additionality matrix
    DIC = DIC_p - DIC_up

    # calculate additionality
    additionality = calc_drawdown_from_dic_1D(DIC, rho_matrix, grid)  # mol m⁻²

    return DIC, additionality

end