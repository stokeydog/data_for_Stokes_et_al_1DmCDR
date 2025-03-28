# PoseidonMRV
## Welcome to the PoseidonMRV documentation!

### Overview
PoseidonMRV is a Julia-based tool designed to estimate carbon drawdown associated with marine Carbon Dioxide Removal (mCDR) interventions. This document walks you through setup and installation.

The package is organized to be modular and leverage Julia's native parallel processing capabilities.
At the time of writing this README file, the folder structure is

PoseidonMRV (but we'll be changing the name on Tom's request)

|---active_development

|---config

|---examples

|---python

|---results

|---src
    | PoseidonMRV.jl
    |---atm_properties
    |       The AtmProperties module sets the atmospheric forcing 
    |       At present, this is pCO2_air and U_10
    |
    |---co2sys
    |       The CO2SYS module invokes PyCall to run PyCO2SYS
    |
    |---drawdown_calculations
    |       The CalcDrawdown module calculates additionality
    |       At present, this runs the calculation using (1) depth-integrated DIC and (2) time-integrated flux
    |       There's also a function to verify that these two methods are consistent.
    |       In the example scripts, this function triggers a warning if consistency does not meet specified thresholds
    |
    |---grids
    |       The Grids module builds vertical grids
    |       At present, its just a vertical z-grid with linear spacing
    |       Future developments should include surface-enhanced grids, 2D grids, etc.
    |
    |---initial_conditions
    |       Two modules live here, InitialConditions and LoadInitialConditions.
    |       The idea of InitialConditions is set up vertical vectors based on user-defined inputs
    |       Supported initializations are given in the function "generate_initial_conditions_1D.jl
    |       The idea of LoadInitialConditions is to 
    |---models
    |---ocn_properties
    |---output_config
    |---parproc
    |---timestepping
    |---utils
    |---visualization
    
### Package Dependencies
Prior to installation, make sure you have all the necessary packages. In order to avoid dependency hell, first delete the files "Project.toml" and "Manifest.toml". This ensures that your PyCall will access the virtual environment within PoseidonMRV. Run this command:

rm("Project.toml")
rm("Manifest.toml")

## Now begin your build.

"""
Note here: I think this step can be skipped with the current setup of the Package.
I'm pretty sure building the package by issuing 
using Pkg; Pkg.activate("."); Pkg.instantiate();
Should add all the necessary packages.
However, it is critical to build PyCall in your venv first!

This is the command, but let's try not issuing it at this point.
Leaving it here for archive purposes.
"""

using Pkg
Pkg.add([
    "GibbsSeaWater",    # Gibbs SeaWater Oceanographic Toolbox
    "SparseArrays",     # for numerical calculations
    "LinearAlgebra",    # for numerical calculations
    "CSV",              # for data I/O
    "DataFrames",       # for data I/O
    "Makie",            # for visualization
    "CairoMakie"        # for visualization
    "JSON",             # Manage configuration files.
    "TOML",             # Manage configuration files.
    "YAML",             # Manage configuration files.
    "JLD2",             # Advanced data storage.
    "FileIO",           # Advanced data storage.
    "Logging",          # Track simulation progress and errors.
    "ArgParse",         # Handle command-line arguments.
    "Test",             # Implement testing suites.
    "ProgressMeter",    # Show the sim progress.
    "Interpolations",   # Interpolate stuff
    "Statistics",       # Statistical stuff
    "Printf",           # Print output
    "Dates"             # Time individual runs
    ])
    # there might be more... but skip this step for now


## SETTING UP JULIA TO ACCESS PyCO2SYS

### 1. CREATE A VIRTUAL ENVIRONMENT
In the directory PoseidonMRV/python, create a virtual environment called "pyseidon". First, kill julia by issuing Ctrl + D (press control and D simultaneously), or just open a new terminal. Now change directory and create venv:

cd "C:/Users/istok/Programming/Julia/PoseidonMRV/python" 
python -m venv pyseidon

activate your virtual environment:

on windows: .\pyseidon\Scripts\activate 

install the pyco2sys package using:

pip install pyco2sys

after installation, deactivate the pyseidon environment and change back to base directory: 

deactivate
cd .. 

### 2. Set up PyCall:
If you've previously built PyCall with the Conda Python, you'll need to remove its existing build to force a rebuild with the new Python interpreter. Use the following command to ensure PyCall will be built with the correct path, then repeat the build and ensure your virtual environment is called:

using Pkg
Pkg.rm("PyCall")

Check your local path, mine is:
C:/Users/istok/Programming/Julia/PoseidonMRV/python/pyseidon/Scripts/python.exe

Now run the following
(on mac): 
ENV["PYTHON"] = "PoseidonMRV/python/pyseidon/bin/python.exe" 
using Pkg
Pkg.add("PyCall")
Pkg.build("PyCall") 

(on windows): 
ENV["PYTHON"] = "C:/Users/istok/Programming/Julia/PoseidonMRV/python/pyseidon/Scripts/python.exe"
using Pkg
Pkg.add("PyCall")
Pkg.build("PyCall")

verify that PyCall is configured to your virtual environment with the following command

using PyCall
println(PyCall.python)

If this successfully returns something like ~/PoseidonMRV/python/pyseidon/Scripts/python.exe, then use the following command and check for a success message:

using PyCall
try
    pyimport("PyCO2SYS")
    println("PyCO2SYS successfully imported.")
catch e
    println("Error importing pyco2sys: ", e)
end

If this fails, check that all your paths and whatnots are solid. 

### Test PyCO2SYS
Now, run navigate to ~/PoseidonMRV/python/pyseidon/test/ and run test_co2sys_wrapper.py. The script we are testing, co2sys_wrapper.py, is a python script which writes co2sys to a Julia function and is essential for the proper functioning of the larger code. 

After test_co2sys_wrapper.py, navigate to examples/co2sys_examples and run co2sys_wrapper_example.jl -- If this runs, your virtual environment and PyCO2SYS installation can be accessed by Julia (since there is no julia_CO2SYS)



### For Development purposes:
Run the following to refresh the REPL
using Pkg
Pkg.add("Revise")

then add this to the script under revision
using Revise



## Using the package
Run the following code from the REPL 

using Pkg; Pkg.activate("."); Pkg.instantiate()

this should open a PoseidonMRV environment and you should be good to go.


### Parallel Computing Troubleshooting:
If things get all weird, run these bash scripts to empty cache (if on windows use git bash)
This shouldn't be a problem anymore, but I had an issue with this when I was setting up parproc

rm -rf ~/.julia/compiled
rm -rf ~/.julia/packages/PyCall




