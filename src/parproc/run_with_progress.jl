using ProgressMeter
using Dates  # For more flexible time tracking

function run_with_progress(diffusivity::Float64, progress_channel::Channel{Int}, buffering_flag::Bool)
    start_time = now()  # Record the start time

    # Select the appropriate simulation function based on buffering_flag
    if buffering_flag
        result = PoseidonMRV.ParProc.run_CN_1D_parallel(diffusivity)  # With buffering
    else
        result = PoseidonMRV.ParProc.run_CN_1D_parallel_no_buffering(diffusivity)  # Without buffering
    end

    elapsed_time = now() - start_time  # Calculate the elapsed time
    println("Worker $(myid()): Task for diffusivity $diffusivity took $(elapsed_time) seconds.")
    
    # Update the progress bar and return both result and elapsed time
    put!(progress_channel, 1)
    return result, elapsed_time
end
