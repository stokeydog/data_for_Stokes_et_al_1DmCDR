# src/PoseidonMRV.jl
module PoseidonMRV
using PyCall

########################
### ~ PYTHON CALLS ~ ###
# First, set the Python environment to the pyseidon virtual environment
ENV["PYTHON"] = joinpath(@__DIR__, "../python/pyseidon/Scripts/python.exe")

# Check if PyCall needs to rebuild after changing the Python environment
if !isfile(ENV["PYTHON"])
    error("The specified Python executable does not exist: $(ENV["PYTHON"])")
end

# Force a rebuild of PyCall if the Python environment changes
if PyCall.python != ENV["PYTHON"]
    println("Rebuilding PyCall to use the specified Python environment...")
    using Pkg
    Pkg.build("PyCall")
end

# Now you can safely use PyCall
using PyCall
println("Using Python executable: ", PyCall.python)

#############################
### ~ HIERARCHY MATTERS ~ ###
println("Starting submodule uploads...")

# Base-level modules:
include("co2sys/CO2SYS.jl")
using .CO2SYS
println("CO2SYS uploaded successfully")

include("utils/Utils.jl")
using .Utils
println("Utils uploaded successfully")

include("grids/Grids.jl")
using .Grids
println("Grids uploaded successfully")

include("timestepping/TimeStepping.jl")
using .TimeStepping
println("TimeStepping uploaded successfully")

include("initial_conditions/InitialConditions.jl")
using .InitialConditions
println("InitialConditions uploaded successfully")

include("output_config/OutputConfig.jl")
using .OutputConfig
println("OutputConfig uploaded successfully")

include("ocn_properties/OcnProperties.jl")
using .OcnProperties
println("OcnProperties uploaded successfully")

include("atm_properties/AtmProperties.jl")
using .AtmProperties
println("AtmProperties uploaded successfully")

# Tier-1 modules: models and visualization
# these depend on base-level modules, so must be included after base-level.
include("models/CrankNicholson1D.jl")
using .CrankNicholson1D
println("CrankNicholson1D uploaded successfully")

include("visualization/Visualize.jl")
using .Visualize
println("Visualize uploaded successfully")

# Tier-2 functions: 
# These would be comparative model runs, etc.

# Export modules for external use
export Grids
export TimeStepping
export InitialConditions
export OutputConfig
export CrankNicholson1D
export Visualize
export Utils
export OcnProperties
export AtmProperties
export CO2SYS

end # module

