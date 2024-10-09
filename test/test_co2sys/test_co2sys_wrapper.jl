using PyCall

# Import the Python CO2SYS wrapper by module name
try
    co2sys_module = pyimport("julia_wrappers.co2sys_wrapper")
    println("co2sys_wrapper successfully imported.")
catch e
    println("Error importing co2sys_wrapper: ", e)
end

# Show the co2sys_module variable to verify it's defined
co2sys_module = pyimport("julia_wrappers.co2sys_wrapper")

# Check the Python executable being used
@pyimport sys
println("Python executable: ", sys.executable)

# List Python's sys.path to ensure site-packages is included
println("\nPython sys.path:")
for p in sys.path
    println(p)
end

# Check the available attributes in the co2sys_module
if co2sys_module !== nothing
    println("\nco2sys_module is defined. Listing available attributes:")
    println(keys(PyObject(co2sys_module)))  # List all attributes in the Python module
else
    println("\nco2sys_module is not defined; skipping attribute listing.")
end

# Define sample parameters
kwargs = Dict(
    :par1_type => 1,
    :par1 => 2400,
    :par2_type => 3,
    :par2 => 7.8,
    :salinity => 35,
    :temperature => 25,
    :temperature_out => 2,
    :pressure => 0,
    :pressure_out => 4000,
    :total_silicate => 50,
    :total_phosphate => 2,
    :opt_pH_scale => 1,
    :opt_k_carbonic => 4,
    :opt_k_bisulfate => 1,
    :opt_total_borate => 1
)

# Call the Python CO2SYS function
if co2sys_module !== nothing
    co2sys_result = co2sys_module.run_calculations(kwargs)
    println("\nCO2SYS Result: ", co2sys_result)
else
    println("co2sys_module is not available; cannot call co2sys function.")
end

# Minimal test call with fewer parameters
println("\nPerforming minimal test call:")
test_kwargs = Dict(
    :par1_type => 1,
    :par1 => 2400,
    :par2_type => 3,
    :par2 => 7.8
)

if co2sys_module !== nothing
    test_result = co2sys_module.run_calculations(test_kwargs)
    println("Test CO2SYS Result: ", test_result)
else
    println("co2sys_module or 'co2sys' function is not available; cannot perform test call.")
end

