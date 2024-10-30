using Revise
using Distributed
using ProgressMeter
using Dates  # For more flexible time tracking

# Define diffusivity values
diffusivity_values = [1e-4, 1e-5]
    # 1e-6 -> timestep = 3600
    # 1e-5 -> timestep = 450
    # 1e-4 -> timestep = 50
    # 1e-3 -> timestep = 5
    # 1e-2 -> timestep < 1 --- this is not currently supported

# Initialize parallel processing and ensure correct number of workers are active
desired_workers = length(diffusivity_values) # current_workers = nworkers()

# Adjust the number of workers
if nworkers() < desired_workers
    addprocs(desired_workers - nworkers())
elseif nworkers() > desired_workers
    rmprocs(workers()[desired_workers+1:end])
end

# Load necessary modules on all workers
@everywhere begin
    ENV["PYTHON"] = joinpath(@__DIR__, "../../python/pyseidon/Scripts/python.exe")
    using PoseidonMRV
end

# Initialize a single progress bar for all tasks
n_tasks = length(diffusivity_values)
p = Progress(n_tasks, 1)
progress_channel = Channel{Int}(n_tasks)

# wrap the run function to pass to workers
@everywhere function run_with_progress_wrapper(diffusivity::Float64)
    PoseidonMRV.ParProc.run_with_progress(diffusivity, $progress_channel)
end

# Use `pmap` to run tasks in parallel, collecting both result and timing data
simulation_results = pmap(run_with_progress_wrapper, diffusivity_values)
