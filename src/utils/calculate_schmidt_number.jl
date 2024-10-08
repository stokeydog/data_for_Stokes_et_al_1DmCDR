"""
    calculate_schmidt_number(T::Float64) -> Float64

Calculates the Schmidt number for CO₂ in seawater based on temperature.

# Arguments
- `T` [Float64]: Temperature in degrees Celsius (°C).

# Returns
- `Sc` [Float64]: Schmidt number.
"""
function calculate_schmidt_number(T::Float64)
    A, B, C, D = 2073.1, 125.62, 3.6276, 0.043219
    Sc = A - B*T + C*T^2 - D*T^3
    return Sc
end
