# src/InitialConditions.jl

module InitialConditions

struct InitialConditions1D
    alk0::Vector{Float64}
    dic0::Vector{Float64}
end

# Include each function from the initial_conditions directory relative to InitialConditions.jl's directory
include(joinpath(@__DIR__, "generate_initial_conditions_1D.jl"))

# Export each function for easy use in other modules
export generate_initial_conditions_1D

end # end module