

using PoseidonMRV.CO2SYS

# Define kwargs
kwargs = Dict(
    "par1_type" => 1,
    "par1" => 2300.0,
    "par2_type" => 2,
    "par2" => 2050.0,
    "salinity" => 35.0,
    "temperature" => 25.0,
    "temperature_out" => 25.0,
    "pressure" => 0.0,
    "pressure_out" => 0.0,
    "total_silicate" => 5,
    "total_phosphate" => 0.5,
    "opt_pH_scale" => 1,
    "opt_k_carbonic" => 10,
    "opt_k_bisulfate" => 1,
    "opt_k_fluoride" => 2,
    "opt_total_borate" => 2
)

try
    result = PoseidonMRV.CO2SYS.run_calculations(kwargs)
    println("CO2SYS Result: ", result)
catch e
    println("Error during CO2SYS call: ", e)
end
