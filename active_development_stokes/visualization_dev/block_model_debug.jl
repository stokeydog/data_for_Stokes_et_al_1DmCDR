dilution_vals = [0.0, 1.0, 10.0, 20.0, 100.0, 1000.0]
alpha_vals = [0.8, 1.0]

H0 = 1.0 # m, initial layer thickness
V0 = 1.0 # m^3
A0 = V0 / H0 # m^2, initial surface area

for dilution in dilution_vals
    for alpha in alpha_vals
        A_mixed = A0 .* (1.0 .+ dilution) .^ alpha
        H_mixed = H0 .* (1.0 .+ dilution) .^ (1.0 .- alpha)
        path_for_config = "results/inf_MLD_variable_dilution_doc_alpha_$(alpha)_fixed_Bic/results_dilution_$(dilution).jld2"
        data = JLD2.jldopen(path_for_config) do file
            read(file, "simulation_results")
        end
        add_debug = ((sum(data["output"]["DIC_p"][:,:] .- data["output"]["DIC_up"][:,:], dims=1)
            .- sum(data["output"]["DIC_p"][:,1] .- data["output"]["DIC_up"][:,1], dims=1))
            .* data["input"]["config"]["depth_grid"]["dz"]
            .* A_mixed .* 1025 .* 1e-6
            )# [umol]
        add_orig  = data["output"]["additionality_dic"] .* A_mixed
        println("alpha = $(alpha), dilution = $(dilution), add_debug = $(add_debug[end]), add_orig = $(add_orig[end])")
    end
end