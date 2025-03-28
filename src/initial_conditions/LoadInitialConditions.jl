# src/LoadInitialConditions.jl

# NOT YET ACTIVE, EXAMPLE FOR FUTURE DEVELOPMENT 

module LoadInitialConditions

using JSON, YAML, TOML, CSV, DataFrames, Utils

"""
load_initial_conditions(file::String)

Load initial conditions from observations.
Supports CSV, JSON, YAML, and TOML formats based on file extension.
"""
function load_initial_conditions(file::String)
    extension = splitext(file)[2]
    if extension == ".json"
        return JSON.parsefile(file)
    elseif extension == ".yaml" || extension == ".yml"
        return YAML.loadfile(file)
    elseif extension == ".toml"
        return TOML.parsefile(file)
    elseif extension == ".csv"
        return CSV.read(file, DataFrame)
    else
        error("Unsupported file format: $extension")
    end
end


end # module LoadInitialConditions
