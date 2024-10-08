### Julia package dependencies:

using Pkg
Pkg.add([
    "PyCall", # call python functions from Julia
    "GSW", # Gibbs SeaWater Oceanographic Toolbox
    "SparseArrays", # for numerical calculations
    "LinearAlgebra", # for numerical calculations
    "CSV", # for data handling
    "DataFrames", # for data handling
    "Plots", # for visualization
    "PyCall" # to use PyCO2SYS
    ])





####################
### PYTHON STUFF ###
####################

### 1. CREATE A VIRTUAL ENVIRONMENT
# In the directory PoseidonMRV/python, create a virtual environment called "pyseidon". use command:

python -m venv pyseidon

# Install the pyco2sys package using

pip install pyco2sys

# after installation, deactivate the pyseidon environment using 

deactivate

