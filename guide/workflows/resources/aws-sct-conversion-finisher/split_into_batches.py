"""
Script to organize SQL files into batches for easier processing.

This script takes SQL files from a source directory and organizes them into numbered batch folders.
Each batch folder contains a specified number of SQL files (default 100).
This is particularly useful when dealing with large numbers of SQL files from AWS Schema Conversion Tool
that need to be processed in smaller batches.

Usage:
    python split_into_batches.py [--batch_size NUMBER]

Arguments:
    --batch_size: Optional. Number of SQL files to include in each batch (default: 100)

Example:
    python split_into_batches.py --batch_size 50
"""

import argparse
import os
import shutil
from math import ceil
from natsort import natsorted  # Import natsorted for natural sorting

def organize_csv_files(source_folder, batch_size=50):
    # Ensure the source folder exists
    if not os.path.exists(source_folder):
        print(f"Source folder '{source_folder}' does not exist.")
        return

    # Get a naturally sorted list of all CSV files in the source folder
    csv_files = natsorted([f for f in os.listdir(source_folder) if f.endswith('.sql')])

    # Calculate the number of batches needed
    num_batches = ceil(len(csv_files) / batch_size)

    for batch_num in range(1, num_batches + 1):
        # Create a batch folder
        batch_folder = os.path.join(f'batches/batch_{batch_num}')
        os.makedirs(batch_folder, exist_ok=True)

        # Move files into the batch folder
        start_index = (batch_num - 1) * batch_size
        end_index = start_index + batch_size
        for csv_file in csv_files[start_index:end_index]:
            source_path = os.path.join(source_folder, csv_file)
            destination_path = os.path.join(batch_folder, csv_file)
            shutil.copy(source_path, destination_path)

    print(f"Organized {len(csv_files)} SQL files into {num_batches} batch folders.")

if __name__ == "__main__":
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Organize SQL files into batches.")
    parser.add_argument("--batch_size", type=int, default=100, help="Number of files per batch (default: 100).")

    args = parser.parse_args()

    # Call the function with default source and output folders and parsed batch size
    organize_csv_files('aws_sct_sql_files', batch_size=args.batch_size)