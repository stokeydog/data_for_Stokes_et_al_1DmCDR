# for development purposes only:
using Revise 

# Script begins here:
# using .Utils  # Importing Utilities module

module CrankNicholsonNoBuffering1D

export timestep!

# global dependencies
using DataFrames
using Statistics
using Distributed
using PyCall
using GibbsSeaWater
using YAML
using ProgressMeter

# local dependencies
using PoseidonMRV.Utils 
using PoseidonMRV.Grids
using PoseidonMRV.TimeStepping
using PoseidonMRV.InitialConditions
using PoseidonMRV.OutputConfig
using PoseidonMRV.OcnProperties
using PoseidonMRV.AtmProperties
using PoseidonMRV.CO2SYS

function timestep!(
    initial_conditions::InitialConditions.InitialConditions1D,
    grid::Grids.GridCN1D,
    time_steps::TimeStepping.TimeStepInfo,
    output_config::OutputConfig.OutputConfigCN1D,
    ocn_props::OcnProperties.OcnProperties1D,
    atm_props::AtmProperties.AtmProperties1D,
    pert_props::Dict{Any, Any},
    co2sys_params::Dict{Any, Any}
)::Tuple{
    Matrix{Float64}, Matrix{Float64}, Matrix{Float64},
    Matrix{Float64}, Vector{Float64}, Vector{Float64},
    Vector{Float64}, Matrix{Float64}, Float64
}

    # set carbonic acid dissociation coefficient
    K1 = 1e-8

    # Set Revelle factor:
    # R = 5

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
    P = ocn_props.P
    pCO2_air = atm_props.pCO2_air
    u_10 = atm_props.u_10

    # Preallocate output
    ALK = fill(NaN, nz, NT)
    DIC = fill(NaN, nz, NT)
    pH = fill(NaN, nz, NT)
    pCO2 = fill(NaN, nz, NT)
    ΔpCO2 = fill(NaN, NT)
    F = fill(NaN, nt - 1)
    tiF = (ti[2:end] .+ ti[1:end-1]) ./ 2  # Time grid for flux
    rho_matrix = fill(NaN, nz, NT)  # Matrix to store density profiles
    kg_m_per_s = NaN

    # Calculate density using GSW package at initial time
    rho = GibbsSeaWater.gsw_rho.(S[:,1], T[:,1], 0)  # kg/m³
    rho_matrix[:, 1] = rho

    # Initialize ALK and DIC
    ALK[:, 1] .= initial_conditions.alk0
    alk0 = initial_conditions.alk0
    DIC[:, 1] .= initial_conditions.dic0
    dic0 = initial_conditions.dic0

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
        :pressure_out => P,
        # :k_carbonic_1 => K1,
        :k_carbonic_1_out => K1 # typical K1 is ~ 4e-7, set to 1e-10 to suppress carbonate formation
        # :revelle_factor => R,
        # :revelle_factor_out => R
    )
    kwargs = merge(local_inputs, co2sys_params)
    co2sys_save = CO2SYS.run_calculations(kwargs)

    # save output data of the IC
    pCO2[:, 1] = co2sys_save["pCO2_out"]  
    pH[:, 1] = co2sys_save["pH_out"]      
    ΔpCO2[1] = pCO2[end, 1] - pCO2_air

    # Parameters for Crank-Nicholson
    alp = dt / (2 * dz^2)
    inc = 2

    # Calculate the saving interval in timesteps
    ind_save = ceil(Int, output_config.save_interval_seconds / dt)

    # @showprogress for ii in 2:nt
    for ii in 2:nt
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
        # setting k_carbonic_1 = 0 neglects buffering
        local_inputs = Dict(
            :par1_type => 1,
            :par1 => alk0[end],
            :par2_type => 2,
            :par2 => dic0[end],
            :salinity => S[end,ii],
            :temperature => T[end,ii],
            :temperature_out => T[end,ii],
            :pressure => 0.0,
            :pressure_out => 0.0,
            # :k_carbonic_1 => K1,
            # :k_carbonic_1_out => K1 # typical K1 is ~ 4e-7, set to 1e-10 to suppress carbonate formation
            # :revelle_factor => R,
            # :revelle_factor_out => R
        )
        kwargs = merge(local_inputs, co2sys_params)
        co2sys_results = CO2SYS.run_calculations(kwargs)
        pco2 = co2sys_results["pCO2_out"]  # can use fCO2_out if preferred
        println("initial pCO2 is $pco2")

        # Calculate CO₂ flux [mol m⁻² s⁻¹]
        F[ii - 1], dpCO2, kg_m_per_s = Utils.calculate_CO2_flux(pco2, pCO2_air, T[end,ii], S[end,ii], u_10)
        
        # Calculate d(DIC)/dz to apply DIC flux 
        # recall F_DIC = kappa * d(DIC)/dz; F_DIC = F_pCO2 / rho; 
        dDICdz = F[ii - 1] / (kap_current[end] * rho) * 1e6 # multiply by 1e6 to convert atm to μatm

        # Update RHS of matricies and apply DIC flux
        RHS_alk = RHS * alk0
        RHS_dic = RHS * dic0
        RHS_dic[end] -= 2 * alp * kap_current[end] * dDICdz * dz

        # Solve for ALK and DIC at the next timestep
        alk1 = LHS \ RHS_alk
        dic1 = LHS \ RHS_dic

        # Update ALK and DIC matrices
        alk0 .= alk1
        dic0 .= dic1

        # Save data every DT timesteps
        if (ii-1) % ind_save == 0 && inc <= NT

            # Store rho at current time
            rho = GibbsSeaWater.gsw_rho.(S[:,ii], T[:,ii], 0)  # kg/m³
            rho_matrix[:, inc] .= rho

            # First save the new TA and DIC
            ALK[:, inc] = alk1
            DIC[:, inc] = dic1

            # Recalculate carbonate system with updated ALK and DIC
            # setting k_carbonic_1 = 0 neglects buffering
            local_inputs = Dict(
                :par1_type => 1,
                :par1 => alk1,
                :par2_type => 2,
                :par2 => dic1,
                :salinity => S[:,ii],
                :temperature => T[:,ii],
                :temperature_out => T[:,ii],
                :pressure => zeros(nz),
                :pressure_out => P,
                :k_carbonic_1 => K1,
                :k_carbonic_1_out => K1 # typical K1 is ~ 4e-7, set to 1e-10 to suppress carbonate formation
                # :revelle_factor => R,
                # :revelle_factor_out => R
            )
            kwargs = merge(local_inputs, co2sys_params)
            co2sys_save = CO2SYS.run_calculations(kwargs)

            # save data for output
            pCO2[:, inc] = co2sys_save["pCO2_out"]  # Adjust index for Julia (1-based)
            pH[:, inc] = co2sys_save["pH_out"]      # Adjust index as needed
            ΔpCO2[inc] = dpCO2

            # Increment 'inc' only after saving data
            inc += 1

        end

    end

    return ALK, DIC, pH, pCO2, ΔpCO2, F, tiF, rho_matrix, kg_m_per_s
end

 end # module