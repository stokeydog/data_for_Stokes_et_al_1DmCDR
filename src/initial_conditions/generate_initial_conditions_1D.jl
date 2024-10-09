# generate_initial_conditions.jl
"""
generate_initial_conditions(pert_props::Dict, nz::Int) -> (Vector{Float64}, Vector{Float64})

Generates initial Alkalinity (`ALK0`) and DIC (`DIC0`) profiles.
"""

### DEPENDENT ON generate_1D_grid RIGHT NOW!!!!! NOT GOOD!
function generate_initial_conditions_1D(pert_props::Dict{Any, Any}, nz::Int)::InitialConditions1D
    alk0 = fill(pert_props["alk0"], nz)
    dic0 = fill(pert_props["dic0"], nz)
    return InitialConditions1D(alk0, dic0)
end