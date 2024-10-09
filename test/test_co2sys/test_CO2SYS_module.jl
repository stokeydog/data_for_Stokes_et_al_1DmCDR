using PoseidonMRV.CO2SYS

# Define test kwargs (ensure these match what your Python function expects)
kwargs = Dict(
    "par1_type" => 1,
    "par1" => 1000.0,
    "par2_type" => 2,
    "par2" => 2000.0,
    "salinity" => 35.0,
    "temperature" => 25.0,
    "temperature_out" => 25.0,
    "pressure" => 0.0,
    "pressure_out" => 0.0
)

try
    result = PoseidonMRV.CO2SYS.run_calculations(kwargs)
    println("CO2SYS Result: ", result)
catch e
    println("Error during CO2SYS call: ", e)
end
