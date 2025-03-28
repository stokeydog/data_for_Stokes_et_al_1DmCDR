# generate_ICs_perturbed_1D.jl
"""
generate_initial_conditions(pert_props::Dict, nz::Int) -> (Vector{Float64}, Vector{Float64})

Generates initial Alkalinity (`ALK0`) and DIC (`DIC0`) profiles.
I'm setting this up so that many different cases can be supplied. 
Currently implemented options are: 
(1) unperturbed
(2) step-wise surface layer
(3) square-plug between two depths
(4) gaussian distribution centered about some depth
"""

function generate_initial_conditions_1D(
    pert_props::Dict{Any, Any},
    grid::AbstractGrid,
    ocn_props_config::Dict{Any, Any};
    case::String = "unperturbed"
)::InitialConditions1D

    # Extract grid properties
    z = grid.z
    nz = grid.nz

    # Initialize alk and dic profiles to pure seawater
    alk0 = fill(ocn_props_config["alk_sw"], nz)
    dic0 = fill(ocn_props_config["dic_sw"], nz)

    # Apply dilution ratio
    alk_diluted = (pert_props["alk_pert"] + ocn_props_config["alk_sw"]*pert_props["dilution"])/(pert_props["dilution"]+1)
    dic_diluted = (pert_props["dic_pert"] + ocn_props_config["dic_sw"]*pert_props["dilution"])/(pert_props["dilution"]+1)

    if case == "unperturbed"
        # Return unperturbed initial conditions
        return InitialConditions1D(alk0, dic0)

    elseif case == "surface_step"
        # Surface step perturbation
        indices = findall((z .<= pert_props["perturbed_layer_thickness"]) .& (z .>= 0))
        alk0[indices] .= alk_diluted
        dic0[indices] .= dic_diluted

    elseif case == "depth_step"
        # Step perturbation at specified depth
        depth_start = pert_props["perturbation_depth_start"]
        depth_end = depth_start + pert_props["perturbed_layer_thickness"]
        indices = findall((z .>= depth_start) .& (z .<= depth_end))
        alk0[indices] .= alk_diluted
        dic0[indices] .= dic_diluted

    elseif case == "gaussian"
        # Gaussian perturbation centered at specified depth
        depth_center = pert_props["perturbation_depth_center"]
        width = pert_props["perturbation_width"]
        # Create Gaussian profile
        gaussian_profile = exp.(-((z .- depth_center) .^ 2) / (2 * width ^ 2))
        # Scale perturbation amplitude
        alk0 .= alk0 .+ alk_diluted * gaussian_profile
        dic0 .= dic0 .+ dic_diluted * gaussian_profile

    else
        error("Invalid case provided: $case")

    end

    return InitialConditions1D(alk0, dic0)
end
