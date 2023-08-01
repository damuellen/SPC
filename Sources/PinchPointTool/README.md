# PinchPoint Tool

The PinchPoint Tool is a Swift command-line program for calculating pinch points in heat exchangers. It provides a simple and efficient way to perform pinch point calculations for various heat exchanger configurations.

## How to Use

### Installation

1. Ensure you have Swift installed on your system.
2. Clone the repository or copy the code into a new Swift file.

### Command Line Arguments

The PinchPoint Tool takes the following command-line arguments:

- **Input**: An array of 11 double values representing various input parameters (optional).
- **HTF**: Heat transfer fluid used in the heat exchangers (optional, default: VP1).
- **Case**: Heat exchanger case number (optional, default: 2).
- **Hex**: Flag to enable hex values input mode (optional).
- **PDF**: Flag to generate a PDF report (optional).
- **JSON**: Flag to output the result in JSON format (optional).
- **HTML**: Flag to generate an HTML report (optional).
- **Excel**: Flag to generate an Excel report (optional).

### Examples

1. Calculate the pinch point using default values and display the results:

```
swift run PinchPointTool
```

2. Calculate the pinch point using custom input parameters:

```
swift run PinchPointTool 250.8 66.42 380.0 102.85 1.0 217.8 22.23 53.58 2800.9 21.02 393
```

3. Calculate the pinch point and generate an HTML report:

```
swift run PinchPointTool -html
```

4. Calculate the pinch point and generate a PDF report:

```
swift run PinchPointTool -pdf
```

### Output

The PinchPoint Tool will display the lower HTF temperature, total HTF mass flow to the heat exchangers, and power of the power block. If the JSON flag is used, it will output the result in JSON format.

## Swift Package Dependencies

The PinchPoint Tool uses the following Swift packages:

- `ArgumentParser`: For parsing command-line arguments.
- `Utilities`: For utility functions.
- `Web`: For generating SVG plots.
- `xlsxwriter`: For generating Excel reports.
