"""
    calculate_transfer_velocity(T::Float64, u::Float64) -> Float64

Calculates the transfer velocity (`K`) for CO₂ absorption in the ocean based on wind speed and temperature.

# Arguments
- `T` [Float64]: Temperature in degrees Celsius (°C).
- `u` [Float64]: Wind speed at 10 meters height in meters per second (m/s).

# Returns
- `K` [Float64]: Transfer velocity in m/s.
"""
function calculate_kg_wanninkhof(T::Float64, u::Float64)
    Sc = calculate_schmidt_number(T)
    if u <= 6
        kg_cm_per_hr = 0.31 * u^2 * (Sc / 660)^(-0.5)
    else
        kg_cm_per_hr = 0.39 * u^2 * (Sc / 660)^(-0.5)
    end
    kg_m_per_s = kg_cm_per_hr * (0.01 / 3600)  # Convert from cm/hr to m/s
    return kg_cm_per_hr, kg_m_per_s
end
