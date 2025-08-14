using JLD2
using Plots
using PlotUtils
using PoseidonMRV
using Interpolations
using Measures

# Define a function to load data and extract variables
function load_simulation_data(file_path)
    data = JLD2.jldopen(file_path) do file
        read(file, "simulation_results")
    end
    # Extract relevant data
    ALK_p = data["output"]["ALK_p"]
    DIC_p = data["output"]["DIC_p"]
    DIC_up = data["output"]["DIC_up"]
    pCO2_p = data["output"]["pCO2_p"]
    pH_p = data["output"]["pH_p"]
    ΔpCO2 = data["output"]["ΔpCO2_p"]
    TI = data["output"]["TI"]
    z = data["output"]["z"]
    additionality = data["output"]["additionality"]
    additionality_flux = data["output"]["additionality_flux"]
    additionality_dic = data["output"]["additionality_dic"]
    return ALK_p, DIC_p, DIC_up, pCO2_p, pH_p, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic
end

# load data from any path for the configuration in question

# uncomment for an infinite ELD example
path_for_config_low_mixing = "results/data/examples/CN_1D_examples/infinite_ELD_low_mixing_test_doc/diffusivity_1eminus08/results_dilution_100.jld2"
path_for_config_med_mixing = "results/data/examples/CN_1D_examples/infinite_ELD_med_mixing_test_doc/diffusivity_1eminus05/results_dilution_100.jld2"
path_for_config_high_mixing = "results/data/examples/CN_1D_examples/infinite_ELD_high_mixing_test_doc/diffusivity_1eminus02/results_dilution_100.jld2"

# uncomment for a finite ELD example (second should give a carbon lid)
# path_for_config_high_mixing = "results/data/examples/CN_1D_examples/finite_ELD_1m_med_mixing_test_doc/diffusivity_1eminus05/results_dilution_100.jld2"
# path_for_config_low_mixing = "results/data/examples/CN_1D_examples/finite_ELD_1m_low_mixing_test_doc/diffusivity_1eminus08/results_dilution_100.jld2"

# PoseidonMRV.Visualize.plot_profiles(ALK_p, DIC_p, pH_p, pCO2_p, ΔpCO2_p, F_p, tiF_p, grid.z, output_config.TI)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# Plot the flux for each case

# ALK_p, DIC_p, DIC_up, pCO2_p, pH_p, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(path_for_config_high_mixing)
# Plots.plot(
#     TI ./ 86400, additionality_dic,
#     label = "\$\\kappa = 10^{-2}\$",
#     xlabel = "Time [days]",
#     ylabel = "Cumulative Additionality [mol m⁻²]",
#     # title = "Additionality Over Time",
#     legend = :topleft
# )
# ALK_p, DIC_p, DIC_up, pCO2_p, pH_p, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(path_for_config_med_mixing)
# Plots.plot!(
#     TI ./ 86400, additionality_dic,
#     label = "\$\\kappa = 10^{-5}\$",
# )
# ALK_p, DIC_p, DIC_up, pCO2_p, pH_p, ΔpCO2, TI, z, additionality, additionality_flux, additionality_dic = load_simulation_data(path_for_config_low_mixing)
# Plots.plot!(
#     TI ./ 86400, additionality_dic,
#     label = "\$\\kappa = 10^{-8}\$",
# )

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

data = JLD2.jldopen(path_for_config_low_mixing) do file
    read(file, "simulation_results")
end

K0 = 0.042 # Henry's law, co2 in SW @ 15 C. units mol/kgSW/atm
# need to grab this from CO2SYS output

# flux_surf =
#     ( 2 .* data["output"]["kg_m_per_s"] .* K0 ) ./                
#     sqrt.( data["input"]["config"]["ocn_props"]["vertical_diffusivity_ML"] .* data["output"]["TI"] ) .*   
#     ( data["input"]["config"]["atm_props"]["pCO2_air"] .-
#       data["output"]["pCO2_p"][end, :] ) .* 1e-6 
      
# flux_surf =
#     ( data["output"]["kg_m_per_s"] .* K0 ) .*   
#     ( data["input"]["config"]["atm_props"]["pCO2_air"] .-
#     data["output"]["pCO2_p"][end, :] ) .* 1e-6         

# flux_int = 2 ./ data["output"]["TI"] .*             
#     ( data["output"]["DIC_p"][end,:] .-          
#     data["output"]["DIC_p"][end,1] ) .* 1e-6

flux_surf = (( data["output"]["kg_m_per_s"] .* K0 ) .*   
    ( data["input"]["config"]["atm_props"]["pCO2_air"] .-
    data["output"]["pCO2_p"][end, :] ) .* 1e-6 )

flux_int = (sqrt.( data["input"]["config"]["ocn_props"]["vertical_diffusivity_ML"] ./ data["output"]["TI"] ) .*
    ( data["output"]["DIC_p"][end,:] .-          
    data["output"]["DIC_p"][end,1] ) .* 1e-6)
     
flux_int[1] = 1e-10
flux_int[1] = 0



using Plots
# gr()                          # make sure we're on the GR backend
# default(yscale = :identity)   # reset any “sticky” log scale
# Plots.reset_defaults()   # wipes all sticky attributes

p = plot( data["output"]["TI"] ./ 86400, (flux_surf); 
        size = (1500,500),
        label = "surface flux",
        xlabel = "time (days)", 
        ylabel = "DIC Flux  (mol kg⁻¹ s⁻¹)",
        left_margin = 10mm,
        right_margin = 10mm,
        top_margin = 10mm,
        bottom_margin = 10mm,
        # ylims = (-1, 1).*1e-10,
        guidefontsize     = 16,     
        tickfontsize      = 12,     
        legendfontsize    = 14,     
        # yscale = :log10
    )
plot!(p, data["output"]["TI"] ./ 86400, -(flux_int);  
        label = "interior flux" 
    )
plot!(p, data["output"]["TI"] ./ 86400, (flux_surf - flux_int); 
        label = "\$d\\bar{C}/dt\$"
    )
display(p)





# # ~~~~~~~~~~~~~~~~~~~~~ #
# # Plot Biot number

# data = JLD2.jldopen(path_for_config_high_mixing) do file
#     read(file, "simulation_results")
# end

# flux_surf = (( data["output"]["kg_m_per_s"] .* K0 ) .*   
#     ( data["input"]["config"]["atm_props"]["pCO2_air"] .-
#     data["output"]["pCO2_p"][end, :] ) .* 1e-6 )

# flux_int = (sqrt.( data["input"]["config"]["ocn_props"]["vertical_diffusivity_ML"] ./ data["output"]["TI"] ) .*
#     ( data["output"]["DIC_p"][end,:] .-          
#     data["output"]["DIC_p"][end,1] ) .* 1e-6)
     
# flux_int[1] = 1e-10
# flux_int[1] = 0

# p2 = plot( data["output"]["TI"] ./ 86400, flux_surf./flux_int; 
#         size = (800,500),
#         label = "\$\\kappa = 10^{-2}\$",
#         xlabel = "time (days)", 
#         ylabel = "Biot number",
#         left_margin = 10mm,
#         right_margin = 10mm,
#         top_margin = 10mm,
#         bottom_margin = 10mm,
#         yscale = :log10
#         # ylims = (-100,100)
#     )

# # 

# data = JLD2.jldopen(path_for_config_med_mixing) do file
#     read(file, "simulation_results")
# end

# flux_surf = (( data["output"]["kg_m_per_s"] .* K0 ) .*   
#     ( data["input"]["config"]["atm_props"]["pCO2_air"] .-
#     data["output"]["pCO2_p"][end, :] ) .* 1e-6 )

# flux_int = (sqrt.( data["input"]["config"]["ocn_props"]["vertical_diffusivity_ML"] ./ data["output"]["TI"] ) .*
#     ( data["output"]["DIC_p"][end,:] .-          
#     data["output"]["DIC_p"][end,1] ) .* 1e-6)
     
# flux_int[1] = 1e-10
# flux_int[1] = 0

# p2 = plot!( data["output"]["TI"] ./ 86400, flux_surf./flux_int; 
#         label = "\$\\kappa = 10^{-5}\$",
#     )

# #

# data = JLD2.jldopen(path_for_config_low_mixing) do file
#     read(file, "simulation_results")
# end

# flux_surf = (( data["output"]["kg_m_per_s"] .* K0 ) .*   
#     ( data["input"]["config"]["atm_props"]["pCO2_air"] .-
#     data["output"]["pCO2_p"][end, :] ) .* 1e-6 )

# flux_int = (sqrt.( data["input"]["config"]["ocn_props"]["vertical_diffusivity_ML"] ./ data["output"]["TI"] ) .*
#     ( data["output"]["DIC_p"][end,:] .-          
#     data["output"]["DIC_p"][end,1] ) .* 1e-6)
     
# flux_int[1] = 1e-10
# flux_int[1] = 0

# p2 = plot!( data["output"]["TI"] ./ 86400, flux_surf./flux_int; 
#         label = "\$\\kappa = 10^{-8}\$",
#     )



# display(p2)

# # # flux_surf[end]./flux_int[end]