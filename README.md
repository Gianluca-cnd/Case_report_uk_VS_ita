# Case report
# Actogram between Timezone Analysis

This script is designed for analyzing and visualizing an actigraphy data recording from end of 2022 to the beginning of 2024, highlighting timezone, shift, photoperiod, DST and activity patterns. It utilizes a combination of Python libraries to load, process, and plot actigraphy data.

The script is designed to be modular, allowing for easy customization based on specific research needs.

## Libraries Used

- `pyActigraphy`: A Python library specifically designed for reading, processing, and analyzing actigraphy data.
- `os`: Standard Python library for interacting with the operating system, used here for file path manipulation.
- `plotly.graph_objects` and `plotly.subplots`: Used for creating interactive plots. `plotly.subplots` is specifically used for creating subplots.
- `pandas`: A powerful data manipulation and analysis library for Python, used for handling data structures and operations.
- `numpy`: A fundamental package for scientific computing with Python, used for numerical operations.
- `matplotlib.pyplot`: A plotting library for creating static, interactive, and animated visualizations in Python.

## Key Components

- **Data Loading**: Utilizes `pyActigraphy.io` for loading actigraphy data from various formats.
- **Visualization**: Employs `plotly.graph_objects` and `matplotlib.pyplot` for plotting the actigraphy data, allowing for interactive and static visualizations.
- **Data Processing**: Uses `pandas` and `numpy` for data manipulation and analysis, crucial for preparing the data for visualization and further analysis.
- **File Handling**: The `os` library is used for managing file paths, ensuring compatibility across different operating systems.
