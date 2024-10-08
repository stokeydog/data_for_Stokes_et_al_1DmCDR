using PoseidonMRV.Modeling

# Define simulation parameters
params = PoseidonMRV.Modeling.Params(
    dt = 60.0,           # Integration timestep [s]
    DT = 3600.0,         # Output timestep [s]
    SI = 0.0,            # Example value, set appropriately
    PO4 = 0.0,           # Example value, set appropriately
    NH4 = 0.0,           # Example value, set appropriately
    H2S = 0.0,           # Example value, set appropriately
    pHSC = 0.0,          # Example value, set appropriately
    K1K2 = 0.0,          # Example value, set appropriately
    KSO4 = 0.0,          # Example value, set appropriately
    KF = 0.0,            # Example value, set appropriately
    BOR = 0.0,           # Example value, set appropriately
    pCO2atm = 400.0      # Atmospheric pCO2 [uatm]
)

# Define initial conditions and inputs
alk0 = [2300.0]        # Initial alkalinity [umol/kgSW]
dic0 = [2000.0]        # Initial DIC [umol/kgSW]
nz = 100               # Number of vertical layers
nt = 1000              # Number of time steps
z = LinRange(0, 100, nz)  # Vertical grid [m]
ti = LinRange(0, 86400, nt)  # Time grid [s]

# Example diffusivity matrix (nz x nt)
kap = rand(nz, nt) * 1e-5  # [m²/s], adjust as needed

# Example environmental parameters
u = rand(nt) * 10.0    # Wind speed [m/s]
T = 15 .+ rand(nt) * 10.0  # Temperature [°C]
S = 35 .+ rand(nt) * 0.5   # Salinity [psu]

# Call the diff1d_doc function
ALK, DIC, pH, pCO2, delta_pCO2, F, TI, tiF = diff1d_doc(
    alk0, dic0, kap, u, T, S, ti, z, params
)

# Visualize results (example: Alkalinity at the surface over time)
using Plots

plot(TI, ALK[end, :], label="Alkalinity", xlabel="Time [s]", ylabel="Alkalinity [umol/kgSW]", title="Surface Alkalinity Over Time")
