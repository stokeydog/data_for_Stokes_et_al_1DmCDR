module ParProc

include(joinpath(@__DIR__, "run_CN_1D_parallel.jl"))
include(joinpath(@__DIR__, "run_CN_1D_parallel_no_buffering.jl"))
include(joinpath(@__DIR__, "run_with_progress.jl"))

export run_CN_1D_parallel
export run_CN_1D_parallel_no_buffering
export run_with_progress

end
