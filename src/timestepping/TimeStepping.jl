# src/timestepping/TimeStepping.jl

module TimeStepping

struct TimeStepInfo
    dt::Int64
    Tend::Int64
    nt::Int64
    ti::Vector{Float64}
    sim_duration_days::Float64
end

# Include each function from the grids directory relative to Grids.jl's directory
include(joinpath(@__DIR__, "check_timestep_stability_CN.jl"))
include(joinpath(@__DIR__, "generate_timestepping.jl"))
include(joinpath(@__DIR__, "generate_timestepping_parallel.jl"))

# Export each function for easy use in other modules
export check_timestep_stability_CN
export generate_timestepping
export generate_timestepping_parallel
export TimeStepInfo

end # module TimeStepping
