using JSON

function save_results_as_json(data::Dict, filename::String)
    JSON.print(filename, data)
end