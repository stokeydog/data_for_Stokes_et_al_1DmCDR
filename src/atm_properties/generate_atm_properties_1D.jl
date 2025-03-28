
"""
generate_atmospheric_properties(atm_props::Dict{String, Any}) -> AtmosphericProperties

Generates the atmospheric properties required for the simulation.

# Arguments
- `atm_props::Dict{String, Any}`: Dictionary containing atmospheric parameters.

# Returns
- `AtmosphericProperties`: Struct containing atmospheric pCO₂ and wind speed.
"""
function generate_atm_properties_1D(atm_props::Dict{Any, Any})::AtmProperties1D
    pCO2_air = atm_props["pCO2_air"]
    u_10 = atm_props["u_10"] # Future: Make time-dependent
    
    return AtmProperties1D(pCO2_air, u_10)
end