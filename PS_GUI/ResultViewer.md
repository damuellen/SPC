# PowerShell Script: Daily Image Viewer

This PowerShell script provides a simple image viewer that allows you to navigate through a series of PNG images corresponding to different days. It displays images found in a specified folder and allows you to navigate using keyboard shortcuts. The script uses Windows Forms to create the user interface for the image viewer.

## Features

- **View Daily Images:** The script displays PNG images found in a specified folder, representing images for each day.
- **Keyboard Navigation:** You can use the keyboard shortcuts to navigate between images and perform other actions:
  - `Space`: Switch between two specified folders to view images from different locations.
  - `Home`: Jump to the first day (Day 1).
  - `End`: Jump to the last day (Day 365).
  - `Left Arrow`: Move to the previous day (decrement Day).
  - `Right Arrow`: Move to the next day (increment Day).
  - `Down Arrow`: Jump ten days back.
  - `Up Arrow`: Jump ten days forward.
  - `Escape`: Change the folder path to load images from a different location.

## Prerequisites

- PowerShell (Windows PowerShell or PowerShell Core) installed on your system.

## How to Use

1. Run the PowerShell script "ImageViewer.ps1" using PowerShell.
2. The script will prompt you to select the folder containing the PNG images for each day.
3. The image viewer window will appear, displaying the image corresponding to Day 1.
4. Use the keyboard shortcuts mentioned above to navigate through the images and perform other actions.

## Note

- Ensure that the images are named in the format "*SummerX.png*", where X represents the day number.
- The script will automatically load the image for Day 1 when launched.

## License

This script is provided as-is and is free to use and modify.
