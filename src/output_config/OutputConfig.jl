# src/output/OutputConfig.jl
module OutputConfig

struct OutputConfigCN1D
    save_interval_hours::Float64
    save_interval_seconds::Float64
    TI::StepRange{Int64, Int64}
    NT::Int64
end

# Include each function from the grids directory relative to Grids.jl's directory
include(joinpath(@__DIR__, "generate_output_config_CN_1D.jl"))

# Export each function for easy use in other modules
export OutputConfigCN1D, generate_output_configCN1D

end # module
