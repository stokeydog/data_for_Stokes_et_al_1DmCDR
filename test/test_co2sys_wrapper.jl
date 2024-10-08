using PyCall

# Import the Python CO2SYS wrapper by module name
try
    co2sys_module = pyimport("julia_wrappers.co2sys_wrapper")
    println("co2sys_wrapper successfully imported.")
catch e
    println("Error importing co2sys_wrapper: ", e)
    co2sys_module = nothing
end

# Show the co2sys_module variable to verify it's defined
@show co2sys_module

# Check the Python executable being used
@pyimport sys
println("Python executable: ", sys.executable)

# List Python's sys.path to ensure site-packages is included
println("\nPython sys.path:")
for p in sys.path
    println(p)
end

# List available attributes in the co2sys_module
if co2sys_module !== nothing
    println("co2sys_module is defined, proceeding with computation")
else
    println("co2sys_module is not defined; skipping attribute listing.")
end

# Define sample parameters using symbol keys (recommended)
kwargs = Dict(
    :par1_type => 1,          # The first parameter is of type "1" (alkalinity)
    :par1 => 2400,             # Value of the first parameter (umol/kg)
    :par2_type => 3,           # The second parameter is of type "3" (pH)
    :par2 => 7.8,               # Value of the second parameter
    :salinity => 35,            # Salinity of the sample (psu)
    :temperature => 25,         # Temperature at input conditions (°C)
    :temperature_out => 2,      # Temperature at output conditions (°C)
    :pressure => 0,             # Pressure at input conditions (dbar)
    :pressure_out => 4000,      # Pressure at output conditions (dbar)
    :total_silicate => 50,      # Concentration of silicate in the sample (umol/kg)
    :total_phosphate => 2,      # Concentration of phosphate in the sample (umol/kg)
    :opt_pH_scale => 1,         # pH scale ("1" means "Total Scale")
    :opt_k_carbonic => 4,       # Dissociation constants ("4" means "Mehrbach refit")
    :opt_k_bisulfate => 1,      # Dissociation constant ("1" means "Dickson")
    :opt_total_borate => 1      # Boron:salinity ratio ("1" means "Uppstrom")
)

# Call the Python CO2SYS function
try
    if co2sys_module !== nothing
        co2sys_result = co2sys_module.co2sys(kwargs)
        println("\nCO2SYS Result: ", co2sys_result)
    else
        println("co2sys_module is not available; cannot call co2sys function.")
    end
catch e
    println("\nError calling CO2SYS: ", e)
end

### ----------------------------------- ###

# Minimal test call with fewer parameters
println("\nPerforming minimal test call:")
test_kwargs = Dict(
    :par1_type => 1,
    :par1 => 2400,
    :par2_type => 3,
    :par2 => 7.8
)

try
    if co2sys_module !== nothing 
        test_result = co2sys_module.co2sys(test_kwargs)
        println("Test CO2SYS Result: ", test_result)
    else
        println("co2sys_module or 'co2sys' function is not available; cannot perform test call.")
    end
catch e
    println("Error during test call: ", e)
end