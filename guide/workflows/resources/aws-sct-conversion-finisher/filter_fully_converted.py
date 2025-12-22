"""
This script processes SQL files in a batch directory to identify and separate fully converted files
from those that still need conversion with AI/RUN Workflow.

It searches for SQL files in the specified batch directory and checks each file for SCT-specific
severity comments. Files without these comments are considered fully converted and are moved to
a 'sct_already_converted' subfolder. The script maintains count of processed, moved, and
remaining files, providing statistics upon completion.

Usage:
    - Set the parent_directory variable to point to your batch repository
    - Run the script to automatically process and organize SQL files
    - Check the console output for processing statistics
"""

import os
import re
import shutil

# Define the parent directory containing the batch repositories
parent_directory = 'all_files\\'  # Replace with the path to your batches repository

# Define the regex pattern to match the specific comment
comment_pattern = re.compile(r"\[\d+\s+-\s+Severity\s+\w+\s+-.*?\]", re.IGNORECASE)

def process_batches(parent_directory):
    # Initialize total statistics
    total_files_processed = 0
    total_files_moved = 0
    total_files_remaining = 0

    # Create a subfolder called 'sct_already_converted' within the batch directory
    output_folder = os.path.join(parent_directory, 'sct_already_converted')
    os.makedirs(output_folder, exist_ok=True)

    # Initialize statistics for the current batch
    files_processed = 0
    files_moved = 0
    files_remaining = 0

    # Process each .sql file in the batch directory
    for file_name in os.listdir(parent_directory):
        # Construct the full file path
        file_path = os.path.join(parent_directory, file_name)

        # Skip if it's not a .sql file
        if not file_name.endswith('.sql'):
            continue

        # Increment the processed files count for this batch
        files_processed += 1
        move_file = False
        # Check if the file contains the specific comment
        with open(file_path, 'r', encoding='utf-8') as file:
            file_content = file.read()
            if not comment_pattern.search(file_content):
                # If the comment is not found, move the file to the output folder
                move_file = True
                files_moved += 1
            else:
                # File remains in the original folder
                move_file = False
                files_remaining += 1
        if move_file:
            shutil.move(file_path, os.path.join(output_folder, file_name))

    # Update total statistics
    total_files_processed += files_processed
    total_files_moved += files_moved
    total_files_remaining += files_remaining

    # Print overall statistics
    print("Overall Statistics:")
    print(f" Total files processed: {total_files_processed}")
    print(f" Total files moved to 'sct_already_converted': {total_files_moved}")
    print(f" Total files remaining in original folders: {total_files_remaining}")

if __name__ == '__main__':
    process_batches(parent_directory)
    print("Batch processing completed.")