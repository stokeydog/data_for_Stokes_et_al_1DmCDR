using JLD2
using Plots

# Load data from .jld2 files
file_path = "results/inf_EL_doc/diffusivity_1eminus06/results_dilution_0.jld2"
data_1eminus06 = JLD2.jldopen(file_path) do file
    read(file, "simulation_results")
end

# Extract relevant data
DIC_p_1eminus06 = data_1eminus06["output"]["DIC_p"]
TI_1eminus06 = data_1eminus06["output"]["TI"]
z_1eminus06 = data_1eminus06["output"]["z"]
additionality_1eminus06 = data_1eminus06["output"]["additionality"]

# Check range and ensure no NaNs
println("DIC_p min and max values: ", minimum(DIC_p_1eminus06), " ", maximum(DIC_p_1eminus06))

# Replace NaNs with zeros (or any other suitable value)
DIC_p_1eminus06_cleaned = replace!(DIC_p_1eminus06, NaN => 0.0)

# Plot output
# Depth profile of DIC_p at final time step
plot(DIC_p_1eminus06[:, end], z_1eminus06, xlabel="DIC_p", ylabel="Depth (m)", title="DIC Profile at Final Time Step", legend=false)

# Additionality over time
plot(TI_1eminus06, additionality_1eminus06, xlabel="Time (days)", ylabel="Additionality", title="Additionality Over Time")

# Heatmap of DIC_p over time and depth
# Reverse `z` if it's in descending order and sort `DIC_p` rows accordingly
isdescending(v) = all(x -> x[1] >= x[2], zip(v, v[2:end]))
if isdescending(z_1eminus06)
    z_1eminus06_ascending = reverse(z_1eminus06)                # Sort `z` in ascending order
    DIC_p_1eminus06_cleaned_reversed = reverse(DIC_p_1eminus06_cleaned, dims=1)  # Reverse rows of `DIC_p` to match `z`
end
heatmap(TI_1eminus06/86400, z_1eminus06_ascending, DIC_p_1eminus06_cleaned_reversed, 
    xlabel="Time (days)", 
    ylabel="Depth (m)", 
    title="DIC Concentration Over Time and Depth", color=:viridis,
    yflip=true
)
