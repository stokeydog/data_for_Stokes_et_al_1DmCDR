using YAML

# Function to load configuration
function load_config(file_path::String)
    config = YAML.load_file(file_path)
    return config
end