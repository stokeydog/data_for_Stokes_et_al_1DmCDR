function generate_timestepping_parallel(sim_duration_days::Float64, save_interval_hours::Int64, dz::Float64, diffusivity::Float64; min_dt = nothing)::TimeStepInfo
    # Calculate maximum allowable timestep
    dt_max = dz^2 / (2 * diffusivity)

    # Define save interval in seconds
    save_interval_seconds = save_interval_hours * 3600

    # Initial assignment of dt based on dt_max
    if dt_max > 3600
        dt = 3600  # Limit to 1 hour if dt_max exceeds 1 hour
    else
        dt = Int(floor(dt_max))  # Use a safe integer approximation of dt_max
    end

    # apply a minimum timestep
    if min_dt !== nothing
        if dt_max < min_dt
            dt = min_dt
        end
    end

    # Adjust dt to ensure save_interval_seconds / dt is an integer
    # Iterate downwards until dt divides save_interval_seconds evenly
    while save_interval_seconds % dt != 0
        dt -= 1
    end

    # Now, `dt` is the largest integer ≤ dt_max that evenly divides the save interval
    println("Adjusted timestep (dt): ", dt)
    
    # Calculate total simulation time in seconds
    Tend = sim_duration_days * 24 * 3600  # Total run time in seconds

    # Calculate number of time steps
    nt = ceil(Int, Tend / dt) + 1

    # Generate time array
    ti = collect(0:dt:Tend)

    return TimeStepInfo(dt, Tend, nt, ti, sim_duration_days)
end