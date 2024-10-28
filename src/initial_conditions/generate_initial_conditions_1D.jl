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
    # Obtain the total number of elements
    # nz = Int(depth_grid_config["max_depth"] / depth_grid_config["dz"] + 1)
    # z = range(0, depth_grid_config["max_depth"], length = nz)
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
        # n_perturbed = Int(pert_props["perturbed_layer_thickness"] / depth_grid_config["dz"])
        # alk0[(end - n_perturbed + 1):end] .= pert_props["alk_pert"]
        # dic0[(end - n_perturbed + 1):end] .= pert_props["dic_pert"]
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

### Function v2
# function generate_initial_conditions_1D(
#     pert_props::Dict{String, Any},
#     depth_grid_config::Dict{String, Any},
#     ocn_props_config::Dict{String, Any};
#     case::String
# )::InitialConditions1D
#     # Obtain the total number of elements
#     nz = Int(depth_grid_config["max_depth"] / depth_grid_config["dz"] + 1)
#     z = range(0, depth_grid_config["max_depth"], length = nz)

#     # Initialize alk and dic profiles to pure seawater
#     alk0 = fill(ocn_props_config["alk_sw"], nz)
#     dic0 = fill(ocn_props_config["dic_sw"], nz)

#     if case == "unperturbed"
#         # Return unperturbed initial conditions
#         return InitialConditions1D(alk0, dic0)
#     elseif case == "surface_step"
#         # Surface step perturbation
#         # n_perturbed = Int(pert_props["perturbed_layer_thickness"] / depth_grid_config["dz"])
#         # alk0[(end - n_perturbed + 1):end] .= pert_props["alk_pert"]
#         # dic0[(end - n_perturbed + 1):end] .= pert_props["dic_pert"]
#         indicies = findall(z .>= pert_props["perturbed_layer_thickness"], z .<= 0)
#         alk0[indices] .= pert_props["alk_pert"]
#         dic0[indices] .= pert_props["dic_pert"]
#     elseif case == "depth_step"
#         # Step perturbation at specified depth
#         depth_start = pert_props["perturbation_depth_start"]
#         depth_end = depth_start + pert_props["perturbed_layer_thickness"]
#         indices = findall(z .>= depth_start, z .<= depth_end)
#         alk0[indices] .= pert_props["alk_pert"]
#         dic0[indices] .= pert_props["dic_pert"]
#     elseif case == "gaussian"
#         # Gaussian perturbation centered at specified depth
#         depth_center = pert_props["perturbation_depth_center"]
#         width = pert_props["perturbation_width"]
#         # Create Gaussian profile
#         gaussian_profile = exp.(-((z .- depth_center) .^ 2) / (2 * width ^ 2))
#         # Scale perturbation amplitude
#         alk0 .= alk0 .+ pert_props["alk_pert"] * gaussian_profile
#         dic0 .= dic0 .+ pert_props["dic_pert"] * gaussian_profile
#     else
#         error("Invalid case provided: $case")
#     end

#     return InitialConditions1D(alk0, dic0)
# end


### Original function:
# function generate_initial_conditions_1D(pert_props::Dict{Any, Any}, depth_grid_config::Dict{Any, Any}, ocn_props_config::Dict{Any, Any})::InitialConditions1D
#     # Obtain the total number of elements, and the number of perturbed elements
#     nz = Int(depth_grid_config["max_depth"]/depth_grid_config["dz"] + 1)
#     n_perturbed = Int(pert_props["perturbed_layer_thickness"]/depth_grid_config["dz"])

#     # First, set the initial alk and dic profiles to pure seawater
#     alk0 = fill(ocn_props_config["alk_sw"], nz)
#     dic0 = fill(ocn_props_config["dic_sw"], nz)

#     # Now set the surface layer (0 -> perturbed_layer_thickness) = alk_pert and dic_pert, respectively
#     alk0[(end - n_perturbed):end] .= pert_props["alk_pert"]
#     dic0[(end - n_perturbed):end] .= pert_props["dic_pert"]
#     return InitialConditions1D(alk0, dic0)
# end