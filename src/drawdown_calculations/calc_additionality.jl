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
        # right now this just uses the DIC calculation.
        # we could implement an additionality calculation using flux 
        # and validate that the results are the same
        # or choose the more conservative value.
    additionality = calc_drawdown_from_dic_1D(DIC, rho_matrix, grid)  # mol m⁻²
    
    return DIC, additionality

end