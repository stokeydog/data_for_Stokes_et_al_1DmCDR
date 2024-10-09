# src/atmospheric_properties/AtmosphericProperties.jl
module AtmProperties
struct AtmProperties1D
    pCO2_air::Float64    # [µatm]
    u_10::Float64         # [m/s]
end

include(joinpath(@__DIR__, "generate_atm_properties_1D.jl"))

export AtmProperties1D, generate_atm_properties_1D

end # module
