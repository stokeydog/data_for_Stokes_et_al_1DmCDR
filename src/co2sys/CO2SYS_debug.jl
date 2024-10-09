# module CO2SYS

# using PyCall

# # Add the directory containing 'julia_wrappers' to Python's sys.path
# try
#     py_sys = pyimport("sys")
#     push!(py_sys["path"], "C:/Users/istok/Programming/Julia/PoseidonMRV/python/pyseidon/Lib/site-packages")
#     println("Added 'julia_wrappers' to Python's sys.path successfully.")
# catch e
#     error("Failed to modify Python sys.path: ", e)
# end

# # Import the Python CO2SYS wrapper as a constant to ensure it's accessible throughout the module
# const co2sys_module = try
#     pyimport("julia_wrappers.co2sys_wrapper")
# catch e
#     @error "Failed to import 'julia_wrappers.co2sys_wrapper': $e"
# end

# # Check if the module was successfully imported
# if co2sys_module !== nothing
#     println("co2sys_wrapper imported successfully.")
#     println("Available attributes in co2sys_module: ", keys(PyObject(co2sys_module)))  # List attributes
# else
#     error("co2sys_module is not available.")
# end

# # Define a Julia wrapper function for the Python 'run_calculations' function
# function run_calculations(kwargs::Dict{Any, Any})::Dict{Any, Any}
#     if co2sys_module === nothing
#         error("Python module 'co2sys_module' is not available.")
#     else
#         # Double-check if 'run_calculations' exists in the module
#         if !hasproperty(co2sys_module, :run_calculations)
#             error("'run_calculations' function does not exist in the Python module.")
#         else
#             result = co2sys_module.run_calculations(kwargs)
#             return Dict{Any, Any}(result)
#         end
#     end
# end

# end # module
