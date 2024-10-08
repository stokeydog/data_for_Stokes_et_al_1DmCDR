# Example runtests.jl

using PoseidonMRV
using Test

@testset "Initial Conditions" begin
    config = PoseidonMRV.InitialConditions.load_initial_conditions("config.yaml")
    @test haskey(config, "CO2SYS_params")
    @test typeof(config["CO2SYS_params"]) == Dict{String, Any}
end

@testset "Model Execution" begin
    # Mock or use real parameters
    kwargs = Dict(
        "par1_type" => 1,
        "par1" => 2400,
        "par2_type" => 3,
        "par2" => 7.8,
        # ... other parameters ...
    )
    result = PoseidonMRV.Models.run_co2sys(kwargs)
    @test !isnothing(result)
end

# Add more tests as needed
