# for development purposes only:
using Revise 

# Script begins here:
# using .Utils  # Importing Utilities module

module CrankNicholson1D

export timestep!

# global dependencies
using DataFrames
using Statistics
using Distributed
using PyCall
using GibbsSeaWater
using YAML
using ProgressMeter

# local dependencies (relative paths)
using .Utils # NEED TO ACCESS .Utils DIRECTLY
# using ..grids.Grids
# using ..timestepping.TimeStepping
# using ..initial_conditions.InitialConditions
# using ..output_config.OutputConfig
# using ..ocn_properties.OcnProperties
# using ..atm_properties.AtmProperties

# Import the Python CO2SYS wrapper
co2sys_module = pyimport("julia_wrappers.co2sys_wrapper")

function timestep!(
    initial_conditions::InitialConditions,
    grid::Grids.Grid,
    time_steps::TimeStepping.TimeStepping,
    output_config::OutputConfig.OutputConfig,
    ocn_props::OcnProperties.OcnProperties1D,
    atm_props::AtmProperties.AtmProperties1D,
    pert_props::Dict{String, Any},
    co2sys_params::Dict{String, Any}
)::Tuple{
    Matrix{Float64}, Matrix{Float64}, Matrix{Float64},
    Matrix{Float64}, Vector{Float64}, Vector{Float64},
    Vector{Float64}
}

    # unpack grid, timestepping, and output configuration
    nz      = grid.nz
    dz      = grid.dz
    nt      = time_steps.nt
    dt      = time_steps.dt
    Tend    = time_steps.Tend
    ti      = time_steps.ti
    NT      = output_config.NT
    TI      = output_config.TI

    # unpack ocean and atmospheric properties
    T = ocn_props.T
    S = ocn_props.S
    kap = ocn_props.vertical_diffusivity
    pCO2_air = atmospheric_props.pCO2_air
    u_10 = atmospheric_props.u_10

    # Preallocate output matrices
    ALK = fill(NaN, nz, NT+1)
    DIC = fill(NaN, nz, NT+1)
    pH = fill(NaN, nz, NT+1)
    pCO2 = fill(NaN, nz, NT+1)
    ΔpCO2 = fill(NaN, NT+1)
    F = fill(NaN, nt - 1)
    tiF = (ti[2:end] .+ ti[1:end-1]) ./ 2  # Time grid for flux

    # Initialize ALK and DIC
    ALK[:, 1] .= initial_conditions.alk0
    DIC[:, 1] .= initial_conditions.dic0

    # Perform carbonate system calculation of the IC from alk0 and dic0
    local_inputs = Dict(
        :par1_type => 1,
        :par1 => initial_conditions.alk0,
        :par2_type => 2,
        :par2 => initial_conditions.dic0,
        :salinity => S[:,1],
        :temperature => T[:,1],
        :temperature_out => T[:,1],
        :pressure => zeros(nz),
        :pressure_out => P
    )
    kwargs = merge(local_inputs, co2sys_params)
    co2sys_save = co2sys_module.co2sys(kwargs)

    # save output data of the IC
    pCO2[:, 1] = co2sys_save["pCO2_out"]  # Adjust index for Julia (1-based)
    pH[:, 1] = co2sys_save["pH_out"]      # Adjust index as needed
    ΔpCO2[1] = co2sys_save["pCO2_out"] - pCO2_air

    # Parameters for Crank-Nicholson
    alp = dt / (2 * dz^2)
    inc = 2

    # Calculate the saving interval in timesteps
    ind_save = ceil(Int, output_config.save_interval_seconds / dt)

    @showprogress for ii in 2:nt
        # Calculate density using GSW package
        rho = GibbsSeaWater.gsw_rho(S[end,ii], T[end,ii], 0)  # mol/kg to mol/m³

        # Current diffusivity profile 
        # kap_current = kap[:, ii] # (assuming kap depends on time)
        kap_current = kap # time dependent kap not yet implemented

        # Calculate diffusivity at half grid points
        kap_half = zeros(nz + 1) 
        kap_half[2:end-1] .= 0.5 .* (kap_current[2:end] .+ kap_current[1:end-1])
        kap_half[1] = kap_current[1]
        kap_half[end] = kap_current[end]

        # Construct RHS and LHS matrices
        RHS, LHS = Utils.construct_CN_matrices(alp, kap_half, nz)

        # Get pCO2 at surface to calculate flux
        local_inputs = Dict(
            :par1_type => 1,
            :par1 => alk1[end],
            :par2_type => 2,
            :par2 => dic1[end],
            :salinity => S[end,ii],
            :temperature => T[end,ii],
            :temperature_out => T[end,ii],
            :pressure => 0.0,
            :pressure_out => 0.0
        )
        kwargs = merge(local_inputs, co2sys_params)
        co2sys_results = co2sys_module.co2sys(kwargs)
        pco2 = co2sys_results["pCO2_out"]  # can use fCO2_out if preferred

        # Calculate CO₂ flux [mol m⁻² s⁻¹]
        F[ii - 1], dpCO2 = Utils.calculate_CO2_flux(pco2, pCO2_air, T[end,ii], S[end,ii], u_10)

        # Calculate d(DIC)/dz to apply DIC flux 
        # recall F_DIC = kappa * d(DIC)/dz; F_DIC = F_pCO2 / rho; 1e6 for atm to μatm
        dDICdz = F[ii - 1] * 1e6 / (kap_current[end] * rho)

        # Update RHS of matricies and apply DIC flux
        RHS_alk = RHS * alk0
        RHS_dic = RHS * dic0
        RHS_dic[end] -= 2 * alp * kap_current[end] * dDICdz * dz

        # Solve for ALK and DIC at the next timestep
        alk1 = LHS \ RHS_alk
        dic1 = LHS \ RHS_dic

        # Update ALK and DIC matrices
        alk0 = alk1
        dic0 = dic1

        # Save data every DT timesteps
        if (ii-1) % ind_save == 0 && inc <= NT

            # First save the new TA and DIC
            ALK[:, inc] = alk1
            DIC[:, inc] = dic1

            # Recalculate carbonate system with updated ALK and DIC
            local_inputs = Dict(
                :par1_type => 1,
                :par1 => alk1,
                :par2_type => 2,
                :par2 => dic1,
                :salinity => S[:,ii],
                :temperature => T[:,ii],
                :temperature_out => T[:,ii],
                :pressure => zeros(nz),
                :pressure_out => P
            )
            kwargs = merge(local_inputs, co2sys_params)
            co2sys_save = co2sys_module.co2sys(kwargs)

            # save data for output
            pCO2[:, inc] = co2sys_save["pCO2_out"]  # Adjust index for Julia (1-based)
            pH[:, inc] = co2sys_save["pH_out"]      # Adjust index as needed
            ΔpCO2[inc] = dpCO2

            # Increment 'inc' only after saving data
            inc += 1

        end

    end

    return ALK, DIC, pH, pCO2, ΔpCO2, F, tiF
end

end # module