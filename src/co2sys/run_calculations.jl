# Define a Julia wrapper function for the Python 'co2sys' function
function run_calculations(kwargs::Dict{Any,Any})::Dict{Any, Any}
    try
        result = co2sys_module.run_calculations(kwargs)
        return Dict{Any, Any}(result)  # Convert Python dict to Julia Dict
    catch e
        error("Error calling 'co2sys' function: ", e)
    end
end