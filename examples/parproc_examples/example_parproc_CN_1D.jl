# this example was used to create the data for the block model analysis [ref paper when it comes out]

using Revise
using Distributed
using ProgressMeter
using Dates  # For more flexible time tracking
using PoseidonMRV

# Number of cores on your machine
n_cores = 14 # (14 cores, but 20 processors. IT guys say its better to use n_cores for heavy computational stuff)

# Load configuration
config_file_path = "examples/parproc_examples/example_parproc_config_CN_1D.yaml"
config = PoseidonMRV.Utils.load_config(config_file_path)

# configure adaptive diffusivity to hold Bic constant
adaptive_Bic = Dict(
    "activated" => "yes", # "yes" or "no"
    "value" => 1.0 # set desired Bic value
)

# calculate the gas transfer velocity
_, kg_mps = Utils.calculate_kg_wanninkhof(config["ocn_props"]["temperature"], config["atm_props"]["u_10"])

# set the range of diffusivity values desired
# dilution_values = Vector{Float64}(0:0.5:5.0)
dilution_values = [100.0, 200.0, 500.0, 1000.0, 100.0, 200.0, 500.0, 1000.0]
alpha_vals      = [  0.2,   0.2,   0.2,    0.2,   0.4,   0.4,   0.4,    0.4]

# prescribe an anisotropy for the dilution (alpha in ms), on the range [0, 1]
# alpha = 0.0 # purely vertical dilution
H0 = config["pert_props"]["perturbed_layer_thickness"] # m, initial layer thickness
V0 = config["pert_props"]["perturbation_volume"] # m^3
A0 = V0 / H0 # m^2, initial surface area
A_mixed_vals = A0 .* (1.0 .+ dilution_values) .^ alpha_vals
H_mixed_vals = H0 .* (1.0 .+ dilution_values) .^ (1.0 .- alpha_vals)

initial_ionization_values = Vector{Float64}(undef, length(dilution_values))

# for i in dilution_values
initial_ionization_values = [let
        # Apply dilution ratio
        alk_diluted = (config["pert_props"]["alk_pert"] + config["ocn_props"]["alk_sw"]*d)/(d+1)
        dic_diluted = (config["pert_props"]["dic_pert"] + config["ocn_props"]["dic_sw"]*d)/(d+1)

        # calculate ionization
        co2sys_params = config["co2sys_params"]
        local_inputs = Dict(
            :par1_type => 1,
            :par1 => alk_diluted,
            :par2_type => 2,
            :par2 => dic_diluted,
            :salinity => config["ocn_props"]["salinity"],
            :temperature => config["ocn_props"]["temperature"],
            :temperature_out => config["ocn_props"]["temperature"],
            :pressure => 0,
            :pressure_out => 0
        )
        kwargs = merge(local_inputs, co2sys_params)
        co2sys_results = CO2SYS.run_calculations(kwargs)
    co2sys_results["dic"] / co2sys_results["aqueous_CO2"]
end for d in dilution_values]

initial_Bic = 1.0
initial_diffusivity_values = (kg_mps .* H_mixed_vals) ./ (initial_Bic .* initial_ionization_values)

# Initialize parallel processing and ensure correct number of workers are active
desired_workers = length(initial_diffusivity_values) + 1 # current_workers = nworkers()

# Adjust the number of workers
if nworkers() < desired_workers
    addprocs(desired_workers - nworkers())
elseif nworkers() > desired_workers
    rmprocs(workers()[desired_workers+1:end])
elseif nworkers() == desired_workers
end

if nworkers() > n_cores
    error("Number of workers exceeds number of cores. 
    This will cause computations to run very slowly.
    Adjust parallel computation request.")
end

# Load necessary modules on all workers
@everywhere begin
    ENV["PYTHON"] = joinpath(@__DIR__, "../../python/pyseidon/Scripts/python.exe")
    using PoseidonMRV
    # using Profile
    # using ProfileView
end

# Initialize a single progress bar for all tasks
jobs = dilution_values # define here what we're looping over, in this case it is dilution
n_tasks = length(jobs)

# since we're reusing config_file_path and adaptive_Bic on each worker, use fill
config_paths = fill(config_file_path, n_tasks) # could pass many different configurations
fixed_Bic_vals = fill(adaptive_Bic, n_tasks)

# fiddle with the progress meter which sadly still doesn't give real-time metrics.
p = Progress(n_tasks, 1)
progress_channel = Channel{Int}(n_tasks)

# wrap the run function to pass to workers
@everywhere function run_with_progress_wrapper(diffusivity::Float64, dilution::Float64, H_mixed::Float64, alpha::Float64, config_file_path, adaptive_Bic)
    PoseidonMRV.ParProc.AnisotropicDilutionParProc.run_with_progress(diffusivity, dilution, H_mixed, alpha, config_file_path, adaptive_Bic, $progress_channel)
    
    # uncomment this to use julia's profiler if the code runs slower than expected
    # @profile PoseidonMRV.ParProc.run_with_progress(diffusivity, $progress_channel)
    # ProfileView.view()
end

# Use `pmap` to run tasks in parallel, collecting both result and timing data 
# note, 'Ref' passes the wrapped item to all workers, without 'Ref' it will loop through that item
# if initial_diffusivity_values and dilution_values are the same length, 
# this setup will pass the pair (initial_diffusivity_values[i], dilution_values[i]) to the i'th worker
simulation_results = pmap(run_with_progress_wrapper, initial_diffusivity_values, dilution_values, H_mixed_vals, alpha_vals, config_paths, fixed_Bic_vals)
