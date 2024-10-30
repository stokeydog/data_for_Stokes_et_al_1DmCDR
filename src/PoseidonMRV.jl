# src/PoseidonMRV.jl
module PoseidonMRV

# using YAML
# using Plots
using PyCall
# using Statistics
# using Distributed

function __init__()
    # Set the Python environment to the pyseidon virtual environment
    # Set the Python environment if not already set
    if !haskey(ENV, "PYTHON")
        ENV["PYTHON"] = joinpath(@__DIR__, "../python/pyseidon/Scripts/python.exe")
    end
    
    # Check if the specified Python executable exists
    if !isfile(ENV["PYTHON"])
        error("The specified Python executable does not exist: $(ENV["PYTHON"])")
    end

    # Check if PyCall is using the correct Python executable
    if PyCall.python != ENV["PYTHON"]
        @warn """
        PyCall is currently configured to use $(PyCall.python).
        The desired Python executable is $(ENV["PYTHON"]).
        If you encounter errors with python calls, please rebuild PyCall with the desired Python environment by running: using Pkg; Pkg.build("PyCall")
        If running parallel computations it's okay to ignore this message so long as the path $(PyCall.python) leads to $(ENV["PYTHON"])
        """
    else
        println("Using Python executable: ", PyCall.python)
    end

    # _initialize_submodules()
end
# using PyCall

# ########################
# ### ~ PYTHON CALLS ~ ###
# # First, set the Python environment to the pyseidon virtual environment
# ENV["PYTHON"] = joinpath(@__DIR__, "../python/pyseidon/Scripts/python.exe")

# # Check if PyCall needs to rebuild after changing the Python environment
# if !isfile(ENV["PYTHON"])
#     error("The specified Python executable does not exist: $(ENV["PYTHON"])")
# end

# # Force a rebuild of PyCall if the Python environment changes
# if PyCall.python != ENV["PYTHON"]
#     println("Rebuilding PyCall to use the specified Python environment...")
#     using Pkg
#     Pkg.build("PyCall")
# end

# # Now you can safely use PyCall
# using PyCall
# println("Using Python executable: ", PyCall.python)

#############################
### ~ HIERARCHY MATTERS ~ ###

# function _initialize_submodules()
println("Starting submodule uploads...")

# Base-level modules:
include("co2sys/CO2SYS.jl")
using .CO2SYS
println("CO2SYS uploaded successfully")

include("utils/Utils.jl")
using .Utils
println("Utils uploaded successfully")

include("grids/Grids.jl")
using .Grids: AbstractGrid
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

include("drawdown_calculations/CalcDrawdown.jl")
using .CalcDrawdown
println("CalcDrawdown uploaded successfully")

include("models/CrankNicholson1D.jl")
using .CrankNicholson1D
println("CrankNicholson1D uploaded successfully")

include("visualization/Visualize.jl")
using .Visualize
println("Visualize uploaded successfully")

# Tier-2 functions: 
# These would be comparative model runs, etc.

include("parproc/ParProc.jl")
using .ParProc
println("ParProc uploaded successfully")

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
export ParProc
# end

end # module

