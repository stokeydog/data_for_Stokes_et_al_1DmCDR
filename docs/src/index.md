# PoseidonMRV
# Welcome to the PoseidonMRV documentation!

## Overview
# PoseidonMRV is a Julia-based tool designed to estimate carbon drawdown associated with marine Carbon Dioxide Removal (mCDR) interventions. This document walks you through setup and installation.

## Package Dependencies
# Prior to installation, make sure you have all the necessary packages. In order to avoid dependency hell, first delete the files "Project.toml" and "Manifest.toml". This ensures that your PyCall will access the virtual environment within PoseidonMRV. Run this command:

rm("Project.toml")
rm("Manifest.toml")

# Now begin your build

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

### ----------------------------------- ###
### SETTING UP JULIA TO ACCESS PyCO2SYS ###
### ----------------------------------- ###

# 1. CREATE A VIRTUAL ENVIRONMENT
# In the directory PoseidonMRV/python, create a virtual environment called "pyseidon". First, kill julia by issuing Ctrl + D (press control and D simultaneously), or just open a new terminal. Now change directory and create venv:

cd "C:/Users/istok/Programming/Julia/PoseidonMRV/python" 
python -m venv pyseidon

# activate your virtual environment:

on windows: .\pyseidon\Scripts\activate 

# install the pyco2sys package using

pip install pyco2sys

# after installation, deactivate the pyseidon environment and change back to base directoty 

deactivate
cd .. 

## Set up PyCall:
# If you've previously built PyCall with the Conda Python, you'll need to remove its existing build to force a rebuild with the new Python interpreter. Use the following command to ensure PyCall will be built with the correct path, then repeat the build and ensure your virtual environment is called:

using Pkg
Pkg.rm("PyCall")

# Check your local path, mine is:
# C:/Users/istok/Programming/Julia/PoseidonMRV/python/pyseidon/Scripts/python.exe

# Now run the following
# on mac: 
ENV["PYTHON"] = "PoseidonMRV/python/pyseidon/bin/python.exe" 
using Pkg
Pkg.add("PyCall")
Pkg.build("PyCall") 

# on windows: 
ENV["PYTHON"] = "C:/Users/istok/Programming/Julia/PoseidonMRV/python/pyseidon/Scripts/python.exe"
using Pkg
Pkg.add("PyCall")
Pkg.build("PyCall")

# verify that PyCall is configured to your virtual environment with the following command

using PyCall
println(PyCall.python)

# If this successfully returns something like ~/PoseidonMRV/python/pyseidon/Scripts/python.exe, then use the following command and check for a success message:

using PyCall
try
    pyimport("PyCO2SYS")
    println("PyCO2SYS successfully imported.")
catch e
    println("Error importing pyco2sys: ", e)
end

# If this fails, check that all your paths and whatnots are solid. Now, run navigate to ~/PoseidonMRV/python/pyseidon/test/ and run test_co2sys_wrapper.py. The script we are testing, co2sys_wrapper.py, is a python script which writes co2sys to a Julia function and is essential for the proper functioning of the larger code. 

# After test_co2sys_wrapper.py, run test_co2sys_wrapper.jl -- this ensures that your virtual environment and PyCO2SYS installation can be accessed by Julia (since there is no julia_CO2SYS)


### ----------------------------------- ###
### For Development purposes........... ###
### ----------------------------------- ###

# Run the following script to refresh the REPL
using Pkg
Pkg.add("Revise")

# then add this to the script under revision
using Revise



## Installation
# Run the following code from the command line 

using Pkg
Pkg.add("PoseidonMRV")


## Parallel Computing:
If things get all weird, run these bash scripts to empty cache (if on windows use git bash)

rm -rf ~/.julia/compiled
rm -rf ~/.julia/packages/PyCall