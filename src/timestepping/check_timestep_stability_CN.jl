function check_timestep_stability(dz::Float64, D::Float64, dt::Float64)
    # Calculate the stability criterion for Crank-Nicholson (for accuracy purposes)
    dt_max = dz^2 / (2 * D)
    if dt > dt_max
        println("Warning: Chosen timestep (dt = $dt s) may reduce accuracy. Suggested maximum timestep for accuracy is $dt_max s.")
    end
end