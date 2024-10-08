# src/grids/Grids.jl

module Grids

# Define the GridCN1D struct 
struct GridCN1D
    z::Vector{Float64}
    dz::Float64
    nz::Int
    max_depth::Float64
end

# Include each function from the grids directory relative to Grids.jl's directory
include(joinpath(@__DIR__, "generate_grid_1D.jl"))

# Export each function for easy use in other modules
export GridCN1D, generate_grid_1D

end # module Grids
