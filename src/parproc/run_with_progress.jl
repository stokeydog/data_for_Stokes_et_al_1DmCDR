using ProgressMeter
# using Distributed
using Dates  # For more flexible time tracking

# include(joinpath(@__DIR__, "run_CN_1D_parallel.jl"))

function run_with_progress(diffusivity::Float64, progress_channel::Channel{Int})
    start_time = now()  # Record the start time

    # Run the actual simulation task and get the result
    result = PoseidonMRV.ParProc.run_CN_1D_parallel(diffusivity)
    
    elapsed_time = now() - start_time  # Calculate the elapsed time
    println("Worker $(myid()): Task for diffusivity $diffusivity took $(elapsed_time) seconds.")
    
    # Update the progress bar and return both result and elapsed time
    put!(progress_channel, 1)
    return result, elapsed_time
end