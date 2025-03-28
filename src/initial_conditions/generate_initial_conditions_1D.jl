# generate_ICs_perturbed_1D.jl
"""
generate_initial_conditions(pert_props::Dict, nz::Int) -> (Vector{Float64}, Vector{Float64})

Generates initial Alkalinity (`ALK0`) and DIC (`DIC0`) profiles.
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

    if case == "unperturbed"
        # Return unperturbed initial conditions
        return InitialConditions1D(alk0, dic0)

    elseif case == "surface_step"
        # Surface step perturbation
        indices = findall((z .<= pert_props["perturbed_layer_thickness"]) .& (z .>= 0))
        alk0[indices] .= pert_props["alk_pert"]
        dic0[indices] .= pert_props["dic_pert"]

    elseif case == "depth_step"
        # Step perturbation at specified depth
        depth_start = pert_props["perturbation_depth_start"]
        depth_end = depth_start + pert_props["perturbed_layer_thickness"]
        indices = findall((z .>= depth_start) .& (z .<= depth_end))
        alk0[indices] .= pert_props["alk_pert"]
        dic0[indices] .= pert_props["dic_pert"]

    elseif case == "gaussian"
        # Gaussian perturbation centered at specified depth
        depth_center = pert_props["perturbation_depth_center"]
        width = pert_props["perturbation_width"]
        # Create Gaussian profile
        gaussian_profile = exp.(-((z .- depth_center) .^ 2) / (2 * width ^ 2))
        # Scale perturbation amplitude
        alk0 .= alk0 .+ pert_props["alk_pert"] * gaussian_profile
        dic0 .= dic0 .+ pert_props["dic_pert"] * gaussian_profile

    else
        error("Invalid case provided: $case")

    end

    return InitialConditions1D(alk0, dic0)
end
