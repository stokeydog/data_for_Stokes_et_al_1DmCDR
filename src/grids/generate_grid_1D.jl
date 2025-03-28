function generate_grid_1D(max_depth::Float64, dz::Float64)::GridCN1D
    z = max_depth:-dz:0
    nz = length(z)
    return GridCN1D(z, dz, nz, max_depth)
end