module CalcDrawdown

using ..Grids: AbstractGrid, GridCN1D
using Interpolations

# Include each function from the initial_conditions directory relative to InitialConditions.jl's directory
include(joinpath(@__DIR__, "calc_max_efficiency.jl"))
include(joinpath(@__DIR__, "compare_drawdown_flux_vs_dic_1D.jl"))

# Export each function for easy use in other modules
export CalcDrawdown
export calc_drawdown_from_dic_1D
export calc_drawdown_from_flux_1D
export calc_max_efficiency
export compare_drawdown_flux_vs_dic_1D

end # end module
