"""
This module calls PyCO2SYS and is what I use for the carbonate system calculations
Future development could use OceanBioME or other comparable carbonate solver written in Julia
It is likely using a native Julia carbonate solver would speed up the code.
"""

module CO2SYS

using PyCall

# Declare co2sys_module as a global constant reference
const co2sys_module = Ref{PyObject}()

function __init__()
    # Initialize co2sys_module at runtime
    co2sys_module[] = pyimport("julia_wrappers.co2sys_wrapper")
end

# Define a Julia wrapper function for the Python 'run_calculations' function
function run_calculations(kwargs::Dict{Any, Any})::Dict{Any, Any}
    result = co2sys_module[].run_calculations(kwargs)
    return Dict{Any, Any}(result)
end

export run_calculations

end # module
