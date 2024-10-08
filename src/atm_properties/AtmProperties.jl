# src/atmospheric_properties/AtmosphericProperties.jl
module AtmProperties

export AtmProperties1D, generate_atmospheric_properties_1D

struct AtmProperties1D
    pCO2_air::Float64    # [µatm]
    u_10::Float64         # [m/s]
end

end # module
