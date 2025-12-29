"""
Script for analyzing and categorizing compilation errors from execution reports created by compile_batches.py script.

This script processes execution_report.txt files specifically for MS SQL to PostgreSQL migrations. It:
- Traverses through batch folders in the 'converted_db_objects' directory
- Collects and categorizes error messages from failed conversions
- Maps error messages to affected files
- Generates a hierarchical report grouping errors by their first word
- Outputs both console summary and detailed report file with:
  * Error categories
  * Error messages within each category
  * List of affected files for each error
  * Count of affected files per category and error message

Output: Creates 'categorized_errors_with_files.txt' in the converted_db_objects directory
"""

import os
from collections import defaultdict, Counter

# Root directory containing the batch folders
ROOT_DIR = 'converted_db_objects'

def collect_error_messages(report_file_path):
    """Extracts error messages and affected files from a batch's execution_report.txt file for failed files."""
    error_data = []  # List of tuples (error_message, file_name)
    try:
        with open(report_file_path, 'r') as report_file:
            lines = report_file.readlines()
            for i, line in enumerate(lines):
                if line.startswith("File:") and "Status: Failed" in line:
                    # Extract the file name from the "File:" line
                    file_name = line.split(":")[1].replace("File: ", "").strip()
                    # The error message is typically on the next line after a failed status
                    if i + 1 < len(lines) and lines[i + 1].strip().startswith("Error:"):
                        error_message = lines[i + 1].strip().replace("Error: ", "")
                        error_data.append((error_message, file_name))
    except Exception as e:
        print(f"Error reading report file {report_file_path}: {e}")
    return error_data

def collect_and_categorize_errors():
    """Aggregates, categorizes, and maps error messages to affected files."""
    error_categories = defaultdict(lambda: {'errors': defaultdict(set), 'file_count': 0})

    batch_folders = [f for f in os.listdir(ROOT_DIR) if os.path.isdir(os.path.join(ROOT_DIR, f))]

    for batch_folder in batch_folders:
        report_file_path = os.path.join(ROOT_DIR, batch_folder, 'execution_report.txt')
        if os.path.exists(report_file_path):
            print(f"Collecting errors from: {report_file_path}")
            batch_errors = collect_error_messages(report_file_path)
            for error_message, file_name in batch_errors:
                first_word = error_message.split()[0] if error_message else "Unknown"
                # Add the file to the set of files for this error message
                error_categories[first_word]['errors'][error_message].add(file_name)
        else:
            print(f"No execution_report.txt found in {batch_folder}, skipping...")

    # Calculate total file count for each category
    for category, data in error_categories.items():
        data['file_count'] = sum(len(files) for files in data['errors'].values())

    return error_categories

def main():
    print("Collecting and categorizing error messages...")
    error_categories = collect_and_categorize_errors()

    # Sort categories by total number of unique files with errors (descending order)
    sorted_categories = sorted(
        error_categories.items(),
        key=lambda x: x[1]['file_count'],  # Sorting by total file count
        reverse=True
    )

    # Print categorized errors with filenames
    print("\nCategorized Error Messages with Affected Files:")
    for category, data in sorted_categories:
        print(f"\nCategory: {category} (Total files: {data['file_count']})")
        # Sort errors within the category by the number of unique files (descending order)
        sorted_errors = sorted(
            data['errors'].items(),
            key=lambda x: len(x[1]),  # Sorting by the number of unique files for each error
            reverse=True
        )
        for error_message, files in sorted_errors:
            print(f"  Error: {error_message} ({len(files)} files)")
            print(f"    Affected files: {', '.join(files)}")

    # Save the categorized errors and filenames to a file
    categorized_errors_path = os.path.join(ROOT_DIR, 'categorized_errors_with_files.txt')
    with open(categorized_errors_path, 'w') as error_report_file:
        error_report_file.write("Categorized Error Messages with Affected Files:\n")
        for category, data in sorted_categories:
            error_report_file.write(f"\nCategory: {category} (Total files: {data['file_count']})\n")
            sorted_errors = sorted(
                data['errors'].items(),
                key=lambda x: len(x[1]),
                reverse=True
            )
            for error_message, files in sorted_errors:
                error_report_file.write(f"  Error: {error_message} ({len(files)} files)\n")
                error_report_file.write(f"    Affected files: {', '.join(files)}\n")

    print(f"\nCategorized error messages saved to: {categorized_errors_path}")

if __name__ == "__main__":
    main()