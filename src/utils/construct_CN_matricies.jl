using SparseArrays

"""
    construct_matrices(alp::Float64, kap_half::Vector{Float64}, nz::Int) -> Tuple{SparseMatrixCSC, SparseMatrixCSC}

Constructs the LHS and RHS matrices for Crank-Nicholson method.

# Arguments
- `alp`: Alpha parameter for Crank-Nicholson.
- `kap_half`: Diffusivity values at half-grid points.
- `nz`: Number of vertical grid points.

# Returns
- `RHS`, `LHS`: Sparse matrices for the Crank-Nicholson solver.
"""
function construct_CN_matrices(alp::Float64, kap_half::Vector{Float64}, nz::Int)
    # Main diagonal
    a = 1 .- alp .* (kap_half[2:end] .+ kap_half[1:end-1])

    # Construct the RHS matrix with corrected diagonal lengths
    RHS = spdiagm(
        (-1 => alp .* kap_half[2:end-1]),  # Length should be nz - 1
        (0 => a),                          # Length should be nz
        (1 => alp .* kap_half[2:end-1])    # Length should be nz - 1
    )

    # Adjust boundary conditions
    RHS[1, 1] = 1 - alp * kap_half[2]
    RHS[end, end] = 1 - alp * kap_half[end-1]

    # Main diagonal for LHS
    b = 1 .+ alp .* (kap_half[2:end] .+ kap_half[1:end-1])

    # Construct the LHS matrix with corrected diagonal lengths
    LHS = spdiagm(
        (-1 => -alp .* kap_half[2:end-1]), # Length should be nz - 1
        (0 => b),                          # Length should be nz
        (1 => -alp .* kap_half[2:end-1])   # Length should be nz - 1
    )

    # Adjust boundary conditions
    LHS[1, 1] = 1 + alp * kap_half[2]
    LHS[end, end] = 1 + alp * kap_half[end-1]

    return RHS, LHS
end
