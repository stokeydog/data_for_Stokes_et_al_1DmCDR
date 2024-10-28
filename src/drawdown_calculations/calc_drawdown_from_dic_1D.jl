function calc_drawdown_from_dic_1D(
    DIC::Matrix{Float64},
    rho_matrix::Matrix{Float64},
    grid::AbstractGrid
)::Vector{Float64}
    # DIC is in μmol kg⁻¹
    # rho is in kg m⁻³
    dz = grid.dz  # Depth interval in meters
    NT = size(DIC, 2)  # Number of saved time steps

    # Preallocate vector for total DIC content at each time
    total_dic = zeros(NT)  # mol m⁻²

    # Loop over saved time steps to compute total DIC content
    for i in 1:NT
        # Convert DIC to mol m⁻³ at time i
        dic_molm3 = DIC[:, i] .* rho_matrix[:, i] * 1e-6  # mol m⁻³
        # Integrate over depth
        total_dic[i] = sum(dic_molm3) * dz  # mol m⁻²
    end

    # Calculate cumulative uptake as change from initial total DIC content
    drawdown_dic = total_dic .- total_dic[1]  # mol m⁻²

    return drawdown_dic
end
