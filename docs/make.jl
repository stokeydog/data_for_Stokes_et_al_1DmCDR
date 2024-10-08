using Documenter, PoseidonMRV

makedocs(
    sitename = "PoseidonMRV Documentation",
    modules = [PoseidonMRV],
    format = :html,
    output_path = "build"
)