# This script does the following:
# 1. Run two "sweeps" of CO2SYS:
#    a) TA sweep: TA varied, DIC fixed
#    b) DIC sweep: DIC varied, TA fixed
# 2. Calculate "ionization" = dic / aqueous_CO2.
# 3. Plot the results on the same graph:
#    ionization vs. "magnitude of perturbation" from the baseline.
# 4. (Optionally) save results to CSV for each sweep.

using Revise
using PoseidonMRV.CO2SYS   # or your CO2SYS module location
using DataFrames
using CSV
using Plots               # for plotting
using Measures

gr() # this was a debugging thing, fine to leave it. Calls GR backend for plotting

# Define baseline values
baseline_TA  = 2300
baseline_DIC = 2050
dic_perturbed = 1050

# Define sweep ranges for TA and DIC
ta_values  = 2300:10:2800   # TA sweep range, step by 10 as example
dic_values = 1550:10:2050   # DIC sweep range, step by 10 as example

dilution = (dic_perturbed .- dic_values) ./ (dic_values .- baseline_DIC) 

# Prepare DataFrames to store results
ta_sweep_df = DataFrame(
    TA_perturbation = Float64[],
    ionization      = Float64[],
    aragonite_sat   = Float64[],
    revelle_factor  = Float64[]
)

dic_sweep_df = DataFrame(
    DIC_perturbation = Float64[],
    ionization       = Float64[],
    aragonite_sat    = Float64[],
    revelle_factor   = Float64[]
)

# TA sweep (vary TA, keep DIC constant)
for TA in ta_values
    
    # "Magnitude of perturbation": how far we are from baseline_TA (TA - baseline_TA)
    ta_perturbation = TA - baseline_TA

    # Build a Dict of input parameters:
    kwargs = Dict{Any, Any}(
        :par1_type        => 1,         # ALK
        :par1             => TA,
        :par2_type        => 2,         # DIC
        :par2             => baseline_DIC,
        :salinity         => 35,
        :temperature      => 15,
        :temperature_out  => 15,
        :pressure         => 0,
        :pressure_out     => 0,
        :total_silicate   => 5,
        :total_phosphate  => 0.5,
        :opt_pH_scale     => 1,
        :opt_k_carbonic   => 10,
        :opt_k_bisulfate  => 1,
        :opt_k_fluoride   => 2,
        :opt_total_borate => 2
    )

    # Call CO2SYS
    co2sys_result = CO2SYS.run_calculations(kwargs)

    # Compute ionization: dic / aqueous_CO2
    ionization_value = co2sys_result["dic"] / co2sys_result["aqueous_CO2"]
    aragonite_sat = co2sys_result["saturation_aragonite"]
    revelle_factor = co2sys_result["revelle_factor"]

    # Add to TA sweep DataFrame
    push!(ta_sweep_df, (ta_perturbation, ionization_value, aragonite_sat, revelle_factor))
end

# DIC sweep (vary DIC, keep TA constant)
for DIC in dic_values
    
    # "Magnitude of perturbation": how far we are from baseline_DIC
    dic_perturbation = DIC - baseline_DIC

    kwargs = Dict{Any, Any}(
        :par1_type        => 1,        # ALK
        :par1             => baseline_TA,
        :par2_type        => 2,        # DIC
        :par2             => DIC,
        :salinity         => 35,
        :temperature      => 15,
        :temperature_out  => 15,
        :pressure         => 0,
        :pressure_out     => 0,
        :total_silicate   => 5,
        :total_phosphate  => 0.5,
        :opt_pH_scale     => 1,
        :opt_k_carbonic   => 10,
        :opt_k_bisulfate  => 1,
        :opt_k_fluoride   => 2,
        :opt_total_borate => 2
    )

    co2sys_result = CO2SYS.run_calculations(kwargs)

    ionization_value = co2sys_result["dic"] / co2sys_result["aqueous_CO2"]
    aragonite_sat = co2sys_result["saturation_aragonite"]
    revelle_factor = co2sys_result["revelle_factor"]

    push!(dic_sweep_df, (dic_perturbation, ionization_value, aragonite_sat, revelle_factor))
end

# Define output directory
output_dir = "results/data/examples/example_chemistry_calculations/"
mkpath(output_dir)  # Create the directory structure if it doesn't exist

# Save results to CSV
CSV.write("results/data/examples/example_chemistry_calculations/ta_sweep_results.csv", ta_sweep_df)
CSV.write("results/data/examples/example_chemistry_calculations/dic_sweep_results.csv", dic_sweep_df)
println("Saved sweep results to CSV files.")


# Visualize Ionization Fraction
p = plot(size = (1000,500),
left_margin   = 15mm,
right_margin  = 15mm,
top_margin    = 15mm,
bottom_margin = 15mm,
)

# Create a twin axis for the Revelle Factor
ptwin = twinx(p)

# Plot Ionization Fraction on the left axis
plot!(
    p,
    dilution,
    dic_sweep_df.ionization;
    label  = "Ionization Fraction",
    lw     = 2,
    color = RGBA(0.3, 0.5, 0.9, 1.0),

    # Make the x-axis black
    xlabel = "Dilution Ratio",
    xguidefont = font(12, color=:black),   # x-axis label in black
    xtickfont  = font(10, color=:black),   # x-axis ticks in black
    xforeground_color_axis   = :black,     # x-axis line & tick marks in black
    xforeground_color_border = :black,     # left border & box edges for x-axis in black

    # Make the left y-axis a softer blue
    ylabel = "Ionization Fraction",
    yguidefont = font(12, color= RGBA(0.3, 0.5, 0.9, 1.0)),
    ytickfont  = font(10, color= RGBA(0.3, 0.5, 0.9, 1.0)),
    yforeground_color_axis   =  RGBA(0.3, 0.5, 0.9, 1.0),
    yforeground_color_border =  RGBA(0.3, 0.5, 0.9, 1.0),

    # turn off legend
    legend = false
)

# Plot Revelle Factor on the right axis
plot!(
    ptwin,
    dilution,
    dic_sweep_df.revelle_factor;
    label  = "Revelle Factor",
    lw     = 2,

    # Hide the second x-axis so we only see the black one
    xlabel = "",      # or `xlabel=false`
    xaxis  = false,   # hide axis line & ticks for the twin x-axis

    # Right y-axis is a soft red, dashed line
    ylabel = "Revelle Factor",
    yguidefont = font(12, color=RGBA(1.0,0.4,0.2,1.0)),
    ytickfont  = font(10, color=RGBA(1.0,0.4,0.2,1.0)),
    yforeground_color_axis   = RGBA(1.0,0.4,0.2,1.0),
    yforeground_color_border = RGBA(1.0,0.4,0.2,1.0),
    linestyle = :dash,
    color = RGBA(1.0,0.4,0.2,1.0),

    ylim = (6,11),
    legend = false
)

display(p)

# Define output directory
output_dir = "results/figures/examples/example_chemistry_calculations/"
mkpath(output_dir)  # Create the directory structure if it doesn't exist

# Save or display the plot
savefig(p, "results/figures/examples/example_chemistry_calculations/ionization_sweep_dilution.png")
println("Plot saved to 'results/figures/examples/example_chemistry_calculations/ionization_sweep_dilution.png'.")

# display(plt)
