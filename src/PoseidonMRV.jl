# src/PoseidonMRV.jl
module PoseidonMRV

### ~ HIERARCHY MATTERS ~ ###
println("Starting submodule uploads...")

# Base-level modules:
include("utils/Utils.jl")
println("Utils.jl include statement success")
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

end # module

