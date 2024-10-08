# test_co2sys_wrapper.py

from julia_wrappers import co2sys_wrapper

def main():
    # Define sample parameters based on CO2SYSExample2.m
    kwargs = {
        "par1_type": 1,          # The first parameter is of type "1" (alkalinity)
        "par1": 2400,             # Value of the first parameter (umol/kg)
        "par2_type": 3,           # The second parameter is of type "3" (pH)
        "par2": 7.8,               # Value of the second parameter
        "salinity": 35,            # Salinity of the sample (psu)
        "temperature": 25,         # Temperature at input conditions (°C)
        "temperature_out": 2,      # Temperature at output conditions (°C)
        "pressure": 0,             # Pressure at input conditions (dbar)
        "pressure_out": 4000,      # Pressure at output conditions (dbar)
        "total_silicate": 50,      # Concentration of silicate in the sample (umol/kg)
        "total_phosphate": 2,      # Concentration of phosphate in the sample (umol/kg)
        "opt_pH_scale": 1,         # pH scale ("1" means "Total Scale")
        "opt_k_carbonic": 4,       # Dissociation constants ("4" means "Mehrbach refit")
        "opt_k_bisulfate": 1,      # Dissociation constant ("1" means "Dickson")
        "opt_total_borate": 1      # Boron:salinity ratio ("1" means "Uppstrom")
    }

    # Call the CO2SYS function from the wrapper
    try:
        co2sys_result = co2sys_wrapper.co2sys(kwargs)
        print("CO2SYS Result:")
        print(co2sys_result)
    except Exception as e:
        print(f"Error during CO2SYS calculation: {e}")

if __name__ == "__main__":
    main()
