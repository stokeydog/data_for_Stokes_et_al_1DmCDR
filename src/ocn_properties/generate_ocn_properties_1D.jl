
"""
    generate_oceanographic_properties(ocn_props::Dict{String, Any}, z::Vector{Float64}, nt::Int) -> OceanographicProperties

Generates the oceanographic properties required for the simulation.

# Arguments
- `ocn_props::Dict{String, Any}`: Dictionary containing oceanographic parameters.
- `z::Vector{Float64}`: Depth grid vector.
- `nt::Int`: Number of time steps.

# Returns
- `OceanographicProperties`: Struct containing temperature, salinity, vertical diffusivity, and pressure profiles.
"""
function generate_ocn_properties_1D(ocn_props::Dict{Any, Any}, z::Vector{Float64}, nt::Int)::OcnProperties1D
    temperature = ocn_props["temperature"]
    salinity = ocn_props["salinity"]
    
    # vectorize temperature and salinity (depth-constant and time-independent for now)
    T = fill(temperature, length(z), nt)
    S = fill(salinity, length(z), nt)

    # Vertical diffusivity (depth-constant and time-independent for now)
    vertical_diffusivity = fill(ocn_props["vertical_diffusivity_ML"], length(z))
    # If diffusivity is time-dependent in the future, modify accordingly
    
    # Pressure estimation: P = depth [m] / 10 [dbar/m]
    P = z ./ 10.0
    
    return OcnProperties1D(T, S, temperature, salinity, vertical_diffusivity, P)
end