using Revise
using Distributed
using ProgressMeter
using Dates  # For more flexible time tracking
using PoseidonMRV


# Define diffusivity values from the Biot number
# config_file_path = "test/test_parproc/test_config_CN_1D_parproc.yaml"
# config = PoseidonMRV.Utils.load_config(config_file_path)
# Heff = config["pert_props"]["perturbed_layer_thickness"]

diffusivity_values = [1e-4, 1e-5, 1e-6, 1e-7, 1e-8, 1e-9]
# diffusivity_values = [1e-4, 4.17376195675682e-5, 1e-5, 1e-6, 1e-7, 1e-8, 1e-9]
# Bi_m = [0.1, 1, 10, 50, 100]
# # kg_m_per_s = 4.17376195675682e-5 at u_10 = 6.63 m/s
# diffusivity_values = 4.17376195675682e-5 * Heff ./ Bi_m # run for a range of Bi_m values
# # diffusivity_values = [1e-8, 1e-9]
    # 1e-6 -> timestep = 3600
    # 1e-5 -> timestep = 450
    # 1e-4 -> timestep = 50
    # 1e-3 -> timestep = 5
    # 1e-2 -> timestep < 1 --- this is not currently supported

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
#     using PyCall
#     # Import the Python module on each worker
#     co2sys_module = pyimport("julia_wrappers.co2sys_wrapper")
#     if co2sys_module === nothing
#         error("Failed to import julia_wrappers.co2sys_wrapper")
#     end
#     if hasproperty(co2sys_module, :co2sys)
#         println("'co2sys' function exists in the module.")
#     else
#         error("'co2sys' function does not exist in julia_wrappers.co2sys_wrapper.")
#     end
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
