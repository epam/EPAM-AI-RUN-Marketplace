"""
This script calculates and aggregates execution statistics from multiple batch folders
containing SQL migration results. It processes execution_report.txt files (output of compile_batches.py) 
from each batch folder under the 'converted_db_objects' directory, compiling total counts of:
- Total SQL files processed
- Successful SQL executions
- Failed SQL executions

The aggregated statistics are both displayed in the console and saved to
'overall_statistics.txt' in the root directory.
"""

import os

# Root directory containing the batch folders
ROOT_DIR = 'converted_db_objects'

def read_batch_statistics(report_file_path):
    """Reads statistics from a batch's execution_report.txt file."""
    stats = {'total_files': 0, 'success_count': 0, 'failure_count': 0}
    try:
        with open(report_file_path, 'r') as report_file:
            lines = report_file.readlines()
            for line in lines:
                if line.startswith("Total SQL files:"):
                    stats['total_files'] = int(line.split(":")[1].strip())
                elif line.startswith("Successful executions:"):
                    stats['success_count'] = int(line.split(":")[1].strip())
                elif line.startswith("Failed executions:"):
                    stats['failure_count'] = int(line.split(":")[1].strip())
    except Exception as e:
        print(f"Error reading report file {report_file_path}: {e}")
    return stats

def calculate_overall_statistics():
    """Aggregates statistics from all batch folders."""
    overall_stats = {'total_files': 0, 'success_count': 0, 'failure_count': 0}
    batch_folders = [f for f in os.listdir(ROOT_DIR) if os.path.isdir(os.path.join(ROOT_DIR, f))]

    for batch_folder in batch_folders:
        report_file_path = os.path.join(ROOT_DIR, batch_folder, 'execution_report.txt')
        if os.path.exists(report_file_path):
            print(f"Reading statistics from: {report_file_path}")
            batch_stats = read_batch_statistics(report_file_path)
            overall_stats['total_files'] += batch_stats['total_files']
            overall_stats['success_count'] += batch_stats['success_count']
            overall_stats['failure_count'] += batch_stats['failure_count']
        else:
            print(f"No execution_report.txt found in {batch_folder}, skipping...")

    return overall_stats

def main():
    print("Calculating overall statistics...")
    overall_stats = calculate_overall_statistics()

    # Print overall statistics
    print("\nOverall Statistics:")
    print(f"Total SQL files processed: {overall_stats['total_files']}")
    print(f"Total successful executions: {overall_stats['success_count']}")
    print(f"Total failed executions: {overall_stats['failure_count']}")

    # Optionally, save the overall statistics to a file
    overall_report_path = os.path.join(ROOT_DIR, 'overall_statistics.txt')
    with open(overall_report_path, 'w') as overall_report_file:
        overall_report_file.write("Overall Statistics:\n")
        overall_report_file.write(f"Total SQL files processed: {overall_stats['total_files']}\n")
        overall_report_file.write(f"Total successful executions: {overall_stats['success_count']}\n")
        overall_report_file.write(f"Total failed executions: {overall_stats['failure_count']}\n")

    print(f"\nOverall statistics saved to: {overall_report_path}")

if __name__ == "__main__":
    main()