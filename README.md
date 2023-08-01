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

The SPC is an indispensable tool for engineers, researchers, and operators to optimize solar power plant configurations and maximize clean energy generation.

## Getting Started

### Installation

Clone the repository to your local machine:

```bash
git clone https://github.com/damuellen/spc.git
cd spc
swift build -c release
cp .build/release/spc /usr/local/bin/spc
```

### Usage

1. Provide the necessary input data, such as meteorological records, solar field configuration, and HTF characteristics.
2. Run the SPC program and obtain the performance simulation results.
3. Analyze the output to gain insights into solar power plant performance and potential improvements.

To use SPC, run the following command:

```bash
spc [OPTIONS]
```

### Options

- `-m, --meteofilePath <path>`: The search path for the meteorological data file used in the simulation.

- `-c, --configPath <path>`: The search path for configuration files related to the solar power plant. (Default: current directory)

- `-r, --pathForResult <path>`: The destination path for the result files generated during the simulation. (Default: current directory)

- `--resultName <name>`: Custom name for the result files. If not provided, they are numbered with two digits.

- `-y, --year <year>`: The year of simulation. If not specified, it uses the current year.

- `-z, --timezone <timezone>`: Timezone of the solar power plant location.

- `--long <longitude>`: Longitude of the solar power plant location in decimal degrees (negative west of Greenwich meridian).

- `--lat <latitude>`: Latitude of the solar power plant location in decimal degrees.

- `--ele <elevation>`: Elevation of the solar power plant location in meters.

- `--stepsCalculation <steps>`: The number of calculation steps per hour during the simulation.

- `--outputValues <values>`: The number of values per hour in the output file.

- `--database`: Output performance data as a SQLite database.

- `--verbose`: Enable a detailed overview of the model parameters.

- `--json`: Save the model parameters in JSON file format.

- `--excel`: Output performance data as an Excel file.

- `--open`: Automatically open the result file after calculation.

- `--plot`: Use the result to create time series charts with gnuplot.

### Examples

1. Calculate performance for a specific year with default parameters:

```bash
spc -y 2023
```

2. Calculate performance with custom meteofile path, timezone, and output format:

```bash
spc -m data/meteo.csv -z 7 --excel
```

3. Calculate performance with custom location and elevation:

```bash
spc --long -115.1739 --lat 36.1146 --ele 550
```

4. Calculate performance with custom calculation steps and output values:

```bash
spc --stepsCalculation 4 --outputValues 4
```

5. Output performance data as an SQLite database:

```bash
spc --database
```

6. Save model parameters in JSON file format:

```bash
spc --json
```

7. Enable verbose mode for a detailed overview of the model parameters:

```bash
spc --verbose
```

8. Calculate performance and create time series charts with gnuplot:

```bash
spc --plot
```

## License

This project is licensed under the [Apache License 2.0](LICENSE).

## Acknowledgements

The Solar Performance Calculator was inspired by and built upon the knowledge gained from similar programs such as PCTrough.
We are grateful to the developers and researchers for their valuable contributions.
