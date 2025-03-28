# src/grids/Grids.jl
"""
The idea here is to have a module with all the grid codes.
Right now, its only a linear z-grid.
"""
module Grids

# Define the GridCN1D struct 
abstract type AbstractGrid end
struct GridCN1D <: AbstractGrid 
    z::Vector{Float64}
    dz::Float64
    nz::Int64
    max_depth::Float64
end

# Include each function from the grids directory relative to Grids.jl's directory
include(joinpath(@__DIR__, "generate_grid_1D.jl"))

# Export each function for easy use in other modules
export AbstractGrid, GridCN1D, generate_grid_1D

end # module Grids
