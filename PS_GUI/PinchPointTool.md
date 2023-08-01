# Pinch Point Tool - PowerShell Script

This PowerShell script provides a graphical user interface (GUI) for calculating pinch points and related parameters. The script uses Windows Forms to create a simple interactive tool that allows users to input specific values and obtain results based on their inputs. The tool can be used to analyze heat exchanger. Additionally, it has an optional "Expert" mode that provides additional parameters for more detailed analysis.

## Prerequisites

Before running the script, make sure you have the following requirements met:

1. PowerShell (Windows PowerShell or PowerShell Core) installed on your system.
2. The script depends on an external executable, "PinchPointTool.exe," which should be located at "C:\bin\".

## How to Use

1. Download the "PinchPointTool.exe" executable and place it in the "C:\bin\" directory.
2. Run the PowerShell script "PinchPointTool.ps1" using PowerShell.

## GUI Description

The GUI contains the following elements:

- Input Text Boxes: Users can input various values related to heat exchangers and high-temperature fluids.
- ComboBoxes: Users can choose the HTF fluid and HEX case from predefined options.
- Calculate Button: Initiates the calculation and displays the results in a browser window.
- PDF Button: Initiates the calculation and generates two PDF files ("diagram.pdf" and "plot.pdf") with the results.
- Expert Button: Toggles the "Expert" mode, which provides additional parameters for more detailed analysis.

## Input Parameters

The following input parameters are available for customization:

1. ECO Inlet Feedwater Temperature [°C]
2. Live Steam Massflow [kg/s]
3. Live Steam Temperature (at turbine inlet) [°C]
4. Live Steam Pressure (at Turbine inlet) [bar]
5. Continuous Blow Down of Input Mass Flow [%]
6. RH Inlet Steam Temperature [°C]
7. RH Inlet Steam Pressure [bar]
8. RH Inlet Steam Enthalpy [kJ/kg]
9. RH Inlet Steam Massflow [kg/s]
10. RH Outlet Steam Pressure [bar]
11. HTF HEX inlet temperature [°C]
12. Pinch-Point-dT [°C] (Expert mode)
13. Approach [°C] (Expert mode)
14. ECO Pressure Drop [bar] (Expert mode)
15. Pressure Drop betw. ECO & SG [bar] (Expert mode)
16. SG Pressure Drop [bar] (Expert mode)
17. Pressure Drop betw. SG & SH [bar] (Expert mode)
18. SH Pressure Drop [bar] (Expert mode)
19. Pressure Drop betw. SH_out and Turbine_in [bar] (Expert mode)
20. SG Steam Quality Outlet [%] (Expert mode)
21. Required Reheater LMTD [°C] (Expert mode)

## Output

The script performs calculations based on the input parameters and generates the following outputs:

- HTML Report: The "Calculate" button generates an HTML report, which is displayed in your default browser.
- PDF Report: The "PDF" button generates two PDF reports ("diagram.pdf" and "plot.pdf") with the results. These reports can be found in the current working directory.

## Save and Load Inputs

The script allows saving and loading input values for future use. The values are stored in a temporary "pinchpoint.ini" file located in the system's temporary directory (typically "C:\Users\<UserName>\AppData\Local\Temp\"). The script automatically loads the previously saved inputs on startup.

## Note

Ensure that the "PinchPointTool.exe" executable is in the specified location ("C:\bin\") for the script to run successfully.

## License

This script is provided as-is and is free to use and modify. Please check the individual licenses for any external dependencies or executables used.
