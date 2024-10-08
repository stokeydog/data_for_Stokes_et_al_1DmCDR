"""
    generate_timestepping(sim_duration_days::Float64, timestep::Float64) -> Tuple{Float64, Int, Vector{Float64}}

Generates the total simulation time, number of time steps, and the time array for a given simulation duration and timestep.

# Arguments
- `sim_duration_days` [Float64]: Simulation duration in days.
- `timestep` [Float64]: Timestep in seconds.

# Returns
- `Tend` [Float64]: Total simulation time in seconds.
- `nt` [Int]: Number of time steps.
- `ti` [Vector{Float64}]: Time array for the simulation.
"""
function generate_timestepping(sim_duration_days::Float64, dt::Int64)::TimeStepInfo
    # Calculate total simulation time in seconds
    Tend = sim_duration_days * 24 * 3600  # Total run time in seconds

    # Calculate number of time steps (ceiling to ensure complete coverage)
    nt = ceil(Int, Tend / dt) + 1

    # Generate time array from 0 to Tend with steps of `timestep`
    # ti = 0:timestep:(nt - 1) * timestep
    ti = collect(0:dt:Tend)

    return TimeStepInfo(dt, Tend, nt, ti, sim_duration_days)
end
