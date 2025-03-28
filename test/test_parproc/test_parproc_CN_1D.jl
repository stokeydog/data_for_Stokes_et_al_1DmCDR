using Revise
using Distributed
using ProgressMeter
using Dates  # For more flexible time tracking
using PoseidonMRV

# Load configuration
config_file_path = "test/test_parproc/test_config_CN_1D_parproc.yaml"
config = PoseidonMRV.Utils.load_config(config_file_path)

# set buffering: true is for buffering on, false is for buffering off.
buffering_flag = config["buffering_flag"]

# set the range of diffusivity values desired
diffusivity_values = [1e-5, 1e-6, 1e-7, 1e-8, 1e-9]
# # note that kg_m_per_s = 4.17376195675682e-5 at u_10 = 6.63 m/s

# Initialize parallel processing and ensure correct number of workers are active
desired_workers = length(diffusivity_values) + 1 # current_workers = nworkers()

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
    const BUFFERING_FLAG = $buffering_flag  # Make it a constant on all workers
end

# Initialize a single progress bar for all tasks
n_tasks = length(diffusivity_values)
p = Progress(n_tasks, 1)
progress_channel = Channel{Int}(n_tasks)

# wrap the run function to pass to workers
@everywhere function run_with_progress_wrapper(diffusivity::Float64)
    PoseidonMRV.ParProc.run_with_progress(diffusivity, $progress_channel, BUFFERING_FLAG)
end

# Use `pmap` to run tasks in parallel, collecting both result and timing data
simulation_results = pmap(run_with_progress_wrapper, diffusivity_values)
