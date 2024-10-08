"""
    calculate_solubility(T::Float64, S::Float64) -> Float64

Calculates the solubility of CO₂ in seawater based on temperature and salinity using the Weiss (1974) parameterization.

# Arguments
- `T` [Float64]: Temperature in degrees Celsius (°C).
- `S` [Float64]: Salinity in Practical Salinity Units (PSU).

# Returns
- `K0` [Float64]: Solubility of CO₂ in seawater [mol kg⁻¹ atm⁻¹].
"""
function calculate_solubility(T::Float64, S::Float64)
    A = [-60.2409, 93.4517, 23.3585]   # Coefficients for temperature effect
    B = [0.023517, -0.023656, 0.0047036]  # Coefficients for salinity effect
    T_K = T + 273.15  # Convert temperature to Kelvin

    Ln_K0 = A[1] + (A[2] * (100 / T_K)) + (A[3] * log(T_K / 100)) +
            S * (B[1] + (B[2] * (T_K / 100)) + (B[3] * (T_K / 100)^2))

    K0 = exp(Ln_K0)
    return K0
end
