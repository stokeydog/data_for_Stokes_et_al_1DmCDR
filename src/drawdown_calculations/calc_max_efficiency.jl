"""
Max efficiency in OAE is not 100 %, because of some carbonate chemistry nuances.
This code calculates the theoretical max efficiency (if DOC, max EF is 100%)
"""

using PoseidonMRV.OcnProperties
using PoseidonMRV.CO2SYS

function calc_max_efficiency(
    ALK_up::Matrix{Float64},
    ALK_p::Matrix{Float64},
    DIC_p::Matrix{Float64},
    rho_matrix::Matrix{Float64},
    grid::AbstractGrid,
    ocn_props::OcnProperties.OcnProperties1D,
    co2sys_params::Dict{Any, Any};
    case::String = "doc"
)
    if case == "doc"
        return max_efficiency = 1
    elseif case == "oae"
        # unpack ocean properties
        T = ocn_props.T
        S = ocn_props.S
        P = ocn_props.P

        # Extract dz for depth integration
        dz = grid.dz  # Depth interval in meters
        nz = grid.nz  # Number of grid points

        # Calculate total DIC in water column in perturbed initial condition
        dic0_molm3 = DIC_p[:, 1] .* rho_matrix[:, 1] * 1e-6  # mol m⁻³ (Convert DIC to mol m⁻³ at time t0)
        total_dic0_molm2 = sum(dic0_molm3) * dz  # mol m⁻² (Integrate over depth)

        # Calculate total change in alkalinity in water column
        dALK_molm2 = ((sum(ALK_p[:,1]) - sum(ALK_up[:,1])) * dz) * (rho_matrix[:, 1] * 1e-6) # mol m⁻²

        # Calculate the pCO2 associated with the unmodified TA profile with modified DIC profile
        local_inputs = Dict(
            :par1_type => 1,
            :par1 => ALK_up[:,1],
            :par2_type => 2,
            :par2 => DIC_p[:,1],
            :salinity => S[:,1],
            :temperature => T[:,1],
            :temperature_out => T[:,1],
            :pressure => zeros(nz),
            :pressure_out => P
        )
        kwargs = merge(local_inputs, co2sys_params)
        co2sys_unmodified_alk = CO2SYS.run_calculations(kwargs)
        pCO2_unmodified_alk = co2sys_unmodified_alk["pCO2_out"] 

        # what must the DIC profile be in order to have baseline pCO2 profile with a modified alkalinity profile?
        local_inputs = Dict(
            :par1_type => 1,
            :par1 => ALK_p[:,1],
            :par2_type => 4,
            :par2 => pCO2_unmodified_alk,
            :salinity => S[:,1],
            :temperature => T[:,1],
            :temperature_out => T[:,1],
            :pressure => zeros(nz),
            :pressure_out => P
        )
        kwargs = merge(local_inputs, co2sys_params)
        co2sys_modified_alk = CO2SYS.run_calculations(kwargs)
        DIC_modified_alk = co2sys_modified_alk["dic"] 

        # Calculate the max DIC uptake from perturbation
        max_DIC_uptake = sum(DIC_modified_alk) .* rho_matrix[:, 1] * 1e-6 * dz .- total_dic0_molm2 # mol m⁻²

        # Calculate the max efficiency
        max_efficiency = max_DIC_uptake / dALK_molm2
    elseif case == "mixed"
        error("Mixed case not yet implemented")
    end

end
