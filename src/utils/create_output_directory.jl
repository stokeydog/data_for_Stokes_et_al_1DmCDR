function create_output_directory(diname::String)
    output_dir = "data/output/$diname"
    if !isdir(output_dir)
        mkpath(output_dir)
    end
    return output_dir
end