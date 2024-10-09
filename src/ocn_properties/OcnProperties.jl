# src/oceanographic_properties/OceanographicProperties.jl
module OcnProperties

struct OcnProperties1D
    T::Matrix{Float64}          # [°C]
    S::Matrix{Float64}          # [psu]
    temperature::Float64        # [°C]
    salinity::Float64           # [psu]
    vertical_diffusivity::Vector{Float64} # [m²/s]
    P::Vector{Float64}          # [dbar]
end

include(joinpath(@__DIR__, "generate_ocn_properties_1D.jl"))

export OcnProperties1D, generate_oceanographic_properties

end # module
