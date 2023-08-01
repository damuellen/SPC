# CSV Data Interpolator

This Swift command-line program is designed to interpolate CSV data to a specified number of steps. It can process CSV files with various delimiters and supports two interpolation modes, depending on whether the file contains "PVSYST" data or date information. The interpolated data can be saved to a new CSV file or copied to the clipboard for easy access.

## Requirements

- Swift 5.0 or later

## Usage

To run the CSV Data Interpolator, use the following command:

```bash
$ csv-data-interpolator <steps> [separator] <input_file_path> [output_file_path]
```

### Parameters

- `<steps>`: The number of steps to interpolate the data. Use a positive integer to increase the data points or a negative integer to decrease the data points (step-by-step reduction).
- `[separator]`: (Optional) The separator used in the CSV file. If not provided, the program will attempt to automatically detect the separator. Common separators include commas (`,`), tabs (`\t`), and semicolons (`;`).
- `<input_file_path>`: The path to the CSV file containing the data to interpolate.
- `[output_file_path]`: (Optional) The path to the output CSV file. If not provided, the interpolated data will be saved in a new file with a name starting with "New_" in the same directory as the input file.

## Examples

1. Interpolate CSV data to 1000 steps:

```bash
$ csv-data-interpolator 1000 input.csv output.csv
```

This will read the data from "input.csv," interpolate it to 1000 steps, and save the result in "output.csv."

2. Decrease data points step-by-step:

```bash
$ csv-data-interpolator -10 input.csv output.csv
```

This will read the data from "input.csv," reduce the data points step-by-step (by 10), and save the result in "output.csv."

3. Interpolate CSV data with a specific separator:

```bash
$ csv-data-interpolator 500 ";" data.csv interpolated.csv
```

This will read the data from "data.csv" using semicolon as the separator, interpolate it to 500 steps, and save the result in "interpolated.csv."

## Notes

- If the CSV file contains "PVSYST" data or date information in the header, the program will automatically handle the interpolation accordingly.
- The program will display error messages for read errors, missing parameters, or invalid file paths.
