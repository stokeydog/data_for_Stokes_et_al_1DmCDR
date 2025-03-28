"""
This is supposed to give real-time updates of simulation progress....
but it doesn't really work. Something about how the parallel workers share the space
on a single terminal does not allow real-time progress reports.
The timer-aspect is still a useful feature though, so keeping it. 

Could use this space to add more simulation metrics for the workers
to report back as outputs following completion of their job.
"""

using ProgressMeter
using Dates  # For more flexible time tracking

function run_with_progress(diffusivity::Float64, dilution::Float64, H_mixed::Float64, alpha::Float64, config_file_path::String, adaptive_Bic::Dict{String, Any}, progress_channel::Channel{Int})
    start_time = now()  # Record the start time

    result = PoseidonMRV.ParProc.run_CN_1D_parallel(diffusivity, dilution, H_mixed, alpha, config_file_path, adaptive_Bic)

    elapsed_time = now() - start_time  # Calculate the elapsed time
    println("Worker $(myid()): Task for diffusivity $diffusivity took $(elapsed_time) seconds.")
    
    # Update the progress bar and return both result and elapsed time
    put!(progress_channel, 1)
    return result, elapsed_time
end
