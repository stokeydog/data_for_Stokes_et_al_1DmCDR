# src/utils/Utils.jl

module Utils

# Include each function from the utils directory relative to Utils.jl's directory
include(joinpath(@__DIR__, "calculate_kg_wanninkhof.jl"))
include(joinpath(@__DIR__, "calculate_CO2_flux.jl"))
include(joinpath(@__DIR__, "calculate_schmidt_number.jl"))
include(joinpath(@__DIR__, "calculate_solubility.jl"))
include(joinpath(@__DIR__, "construct_CN_matricies.jl"))
include(joinpath(@__DIR__, "create_output_directory.jl"))
include(joinpath(@__DIR__, "load_config.jl"))
include(joinpath(@__DIR__, "save_results_as_csv.jl"))
include(joinpath(@__DIR__, "save_results_as_json.jl"))
include(joinpath(@__DIR__, "setup_logging.jl"))

# Export each function for easy use in other modules
export calculate_kg_wanninkhof
export calculate_CO2_flux
export calculate_schmidt_number
export calculate_solubility
export construct_CN_matricies
export create_output_directory
export load_config
export save_results_as_csv
export save_results_as_json
export setup_logging

end # module Utils
