"""
generate_output_config(save_interval_hours::Int, dt::Float64, Tend::Float64) -> OutputConfig

Generates the output configuration for saving simulation results.
"""
function generate_output_config_CN_1D(save_interval_hours::Int64, dt::Int64, sim_duration_days::Float64)::OutputConfigCN1D
    save_interval_seconds = save_interval_hours * 3600
    ind_save = ceil(Int, save_interval_seconds / dt)
    Tend = sim_duration_days * 86400.0  # Convert days to seconds
    TI = 0:save_interval_seconds:ceil(Int, Tend)
    NT = Int(length(TI))
    return OutputConfigCN1D(save_interval_hours, save_interval_seconds, TI, NT)
end