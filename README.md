# Solar Performance Calculator (SPC)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](https://opensource.org/licenses/Apache-2.0)

## Overview

SPC is a high-performance command-line tool written in Swift, designed to calculate the annual production of solar thermal power plants, with a focus on parabolic trough solar power plants. It takes various input parameters through command-line options and generates simulation results for the solar power plant's performance.

The SPC considers solar angles, radiation, ambient temperature, solar field condition, HTF system availability, and thermal losses. It accommodates quasi-steady state conditions, daily startup/shutdown, and changing weather during operation.

Key Features:

- Accurate calculation of solar angles and energy output.
- Comprehensive collector model for precise representation.
- Customizable solar field configurations.
- Consideration of HTF characteristics for optimal operation.
- Startup mode management and night operation simulation.
- Heat exchanger routine for precise steam production and thermal loss calculations.
- Auxiliary consumption calculation for all electric consumers, accounting for DNI variations and SFI load.
- Flexible output formats, including SQLite database, Excel, and CSV.

## Getting Started

### Installation

1. Clone the repository to your local machine.

```bash
git clone https://github.com/damuellen/spc.git
cd spc
```

2. Build the project.

```bash
swift build -c release 
```

3. Copy the binary to a location in your PATH.

```bash
cp .build/release/SPC /usr/local/bin/
```

### Usage

1. Provide the necessary input data, such as meteorological records, solar field configuration, and HTF characteristics.
2. Run the SPC program and obtain the performance simulation results.
3. Analyze the output to gain insights into solar power plant performance and potential improvements.

To use SPC, run the following command:

```bash
SPC [OPTIONS]
```

### Options

- `-z`, `--timezone`: Specify the time zone (optional).
- `--long`: Specify the longitude in decimal degrees (negative west of Greenwich meridian) (optional).
- `--lat`: Specify the latitude in decimal degrees (optional).
- `--ele`: Specify the elevation in meters (optional).
- `-p`, `--path`: The search path for configuration files (default: current directory).
- `--meteofilePath`: The search path for the meteo data file (default: current directory).
- `--pathForResult`: Destination path for result files (default: current directory).
- `--resultName`: Custom name for the result file (otherwise they are numbered with 2 digits) (optional).
- `--year`: Year of the simulation (optional).
- `--stepsCalculation`: Calculation steps per hour (optional).
- `--outputValues`: Values per hour in the output file (optional).
- `--database`: Output performance data as an SQLite database (optional).
- `--verbose`: Display a detailed overview of the model parameters (optional).
- `--json`: Save the model parameters in JSON file format (optional).
- `--excel`: Output performance data as an Excel file (optional).
- `--open`: Open the result file after calculation (optional).
- `--plot`: Use the result to create time series charts with gnuplot (optional).

### Examples

1. Calculate performance for a specific year with default parameters:

```bash
SPC -y 2023
```

2. Calculate performance with custom meteofile path, timezone, and output format:

```bash
SPC -m data/meteo.csv -z 7 --excel
```

3. Calculate performance with custom location and elevation:

```bash
SPC -long -115.1739 -lat 36.1146 --ele 550
```

4. Calculate performance with custom calculation steps and output values:

```bash
SPC --stepsCalculation 4 --outputValues 4
```

5. Output performance data as an SQLite database:

```bash
SPC --database
```

6. Save model parameters in JSON file format:

```bash
SPC --json
```

7. Enable verbose mode for a detailed overview of the model parameters:

```bash
SPC --verbose
```

8. Calculate performance and create time series charts with gnuplot:

```bash
SPC --plot
```

To run the Solar Performance Calculator for a specific year and location, use the following command:

```bash
SPC --year 2023 -lat 52.5200 -long 13.4050 --timezone 2
```

This will calculate the annual production of the solar thermal power plant for the year 2023 at the latitude 52.5200 and longitude 13.4050 (Berlin, Germany) with a time zone offset of +2 hours. The results will be recorded in the default output format (CSV) in the current directory.

For more information on available options and their usage, run:

```bash
SPC --help
```

# BlackBoxModel

## Configuration Functions

### `configure(year: Int)`

Configure the simulation for a specific year.

### `configure(location: Location)`

Configure the simulation for a specific location.

### `configure(meteoFilePath: String? = nil) throws`

Configure the simulation using meteo data from a file.

### `loadConfiguration(atPath path: String) throws -> String?`

Load configuration from a JSON or text configuration file.

## Simulation Function

### `runModel(with record: Historian)`

Run the solar power plant simulation and record the results in a historian.

**Attention**: Before calling this function, you must call one of the `configure` functions to set up the simulation.

# Historian

### Mode Enumeration

The `Mode` enumeration represents the output modes for the historian. It includes the following cases:

- `.database`: Records data in an SQLite database.
- `.inMemory`: Keeps data in-memory without saving it to a file.
- `.custom(interval: DateSeries.Frequence)`: Allows custom data recording intervals.
- `.csv`: Stores data in a comma-separated values (CSV) file.
- `.excel`: Writes data to an Excel file.

### Initialization

The `Historian` class is initialized with various parameters, such as `name`, `path`, and `mode`. It reserves capacity for performance data arrays based on the provided frequency. The `path` parameter specifies the directory path for the output files, and the `name` parameter sets a custom name for the output files. If the mode does not support file output, there will be no output files.

### Recording Data

The `Historian` class records performance data and status history using its callAsFunction method. It appends data to the arrays `status`, `performance`, and `sun`, which store the past states of the plant, performance data, and insolation data, respectively.

### Finalization

The `finish` method finalizes the recording process and returns a `Recording` object containing historical data. It handles different output modes, such as custom CSV files, databases, and Excel files. The data is written to the respective files, and the file stream is closed.

### Excel Output

The class uses the `xlsxwriter` Swift package for writing data to an Excel file. It creates a workbook with two worksheets named "Status" and "Performance." The data is written to these worksheets, and the workbook is saved as an Excel file.

### Database Output (Optional)

The class includes commented-out code for writing data to an SQLite database. If needed, you can uncomment and implement this code to store data in a database.

### Notes

- The Solar Performance Calculator is designed for the simulation of solar thermal power plants. It is crucial to provide accurate meteorological data and configuration files for precise and reliable results.
- The tool provides detailed information about the calculation process, including preparation time, computing time, and wall time, helping users assess the efficiency and resource requirements of the simulation.
- Additionally, the Solar Performance Calculator includes a `plot` option, allowing users to create time series charts with Gnuplot. This visualization feature helps users gain insights into the calculated results and facilitates the interpretation of the simulation data.

#### Disclaimer: This Software is Unfinished and May Contain Bugs

Please be aware that this software is still under development and is considered unfinished. As a single developer is currently working on this project, the development process may take longer, and the software might have limited resources for testing and debugging.

As a result, it may contain bugs, errors, and incomplete features. We do not recommend using this software in a production environment or for critical applications at this time.

While the developer is actively working to improve and enhance the software, there is no guarantee of its stability or reliability. It is important to exercise caution and use this software solely for testing and experimentation purposes.

By using this software, you acknowledge and accept the risks associated with its unfinished state and the fact that it is developed by a single individual. The developer disclaims any liability for any direct or indirect damages that may arise from its usage.

## License

This project is licensed under the [Apache License 2.0](LICENSE).

## Acknowledgements

The Solar Performance Calculator was inspired by and built upon the knowledge gained from similar programs such as PCTrough.
We are grateful to the developers and researchers for their valuable contributions.
