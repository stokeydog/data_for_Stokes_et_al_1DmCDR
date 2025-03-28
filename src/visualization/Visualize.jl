"""
The idea here was to write a module with production-ready codes for visualizing output.
This space has kind of morphed into a testing area for random visualization codes.
"""

module Visualize

include(joinpath(@__DIR__, "plot_additionality.jl"))
include(joinpath(@__DIR__, "plot_drawdown.jl"))
include(joinpath(@__DIR__, "plot_profiles.jl"))

export plot_additionality
export plot_drawdown
export plot_profiles

end
