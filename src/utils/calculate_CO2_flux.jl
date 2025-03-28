using GibbsSeaWater

"""
calculate_flux(pCO2_sea::Float64, pCO2_atm::Float64, T::Float64, S::Float64, u::Float64) -> Tuple{Float64, Float64}

Calculates the air-sea flux for CO₂ absorption in the ocean.

# Arguments
- `pCO2_sea` [Float64]: Seawater pCO₂ (µatm).
- `pCO2_atm` [Float64]: Atmospheric pCO₂ (µatm).
- `T` [Float64]: Temperature in degrees Celsius (°C).
- `S` [Float64]: Salinity in Practical Salinity Units (PSU).
- `u` [Float64]: Wind speed at 10 meters height in meters per second (m/s).

# Returns
- `F_CO2` [Float64]: CO₂ flux in mol/m²/s.
- `dpCO2` [Float64]: Difference between seawater and atmospheric pCO₂ (µatm).
"""
function calculate_CO2_flux(pCO2_sea::Float64, pCO2_air::Float64, T::Float64, S::Float64, u_10::Float64)
    # Calculate ΔpCO₂ (in atm)
    dpCO2 = pCO2_sea - pCO2_air
    dpCO2_atm = dpCO2 / 1e6  # Convert µatm to atm

    # Calculate solubility (K₀ in mol/(kg·atm))
    K0 = calculate_solubility(T, S)

    # Calculate density (ρ in kg/m³) using GSW
    rho = GibbsSeaWater.gsw_rho(S, T, 0)

    # Adjust solubility to mol/(m³·atm)
    K0_adjusted = K0 * rho

    # Calculate transfer velocity (K in m/s)
    kg_m_per_s = calculate_kg_wanninkhof(T, u_10)[2]

    # Calculate air-sea CO₂ flux (F_CO2 in mol/m²/s)
    F_CO2 = 0.24 * kg_m_per_s * K0_adjusted * dpCO2_atm

    return F_CO2, dpCO2, kg_m_per_s
end
