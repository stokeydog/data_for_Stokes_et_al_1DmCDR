using Interpolations

function interp_time_series(
    data::Vector{Float64},
    t_data::Vector{Float64},
    t_interp::StepRange{Int64, Int64}
)::Vector{Float64}
    # Create a linear interpolation object
    itp = LinearInterpolation(t_data, data, extrapolation_bc = Line())
    # Evaluate at desired time points
    return itp(t_interp)
end