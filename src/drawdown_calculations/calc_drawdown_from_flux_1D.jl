function calc_drawdown_from_flux_1D(
    F::Vector{Float64}, 
    dt::Int64
)::Vector{Float64}
    # Total uptake is the sum over F * dt
    # F is in mol m⁻² s⁻¹, dt in seconds
    drawdown_flux = .- cumsum(F) .* dt  # mol m⁻²
    return drawdown_flux
end