using CSV
using DataFrames

function save_results_as_csv(data::DataFrame, filename::String)
    CSV.write(filename, data)
end