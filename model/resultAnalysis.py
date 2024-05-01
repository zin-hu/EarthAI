# Description: This simple script reads log files from different configurations and 
# calculates the average computation time per epoch and overall accuracy for 
# each configuration.

import pandas as pd
import json

# Function to load and process log data
def process_log_file(file_path):
    with open(file_path, 'r') as file:
        log_data = [json.loads(line) for line in file.readlines()]
    return pd.DataFrame(log_data)

# Paths to log files for different configurations
log_files = {
    'Without_LoRA': '/Users/rabia/Downloads/withoutLora.log.json',
    'LoRA_r32': '/Users/rabia/Downloads/r32lora.log.json',
    'LoRA_r16': '/Users/rabia/Downloads/r16lora.log.json',
    'LoRA_r8': '/Users/rabia/Downloads/r8lora.json'
}

# Load and process each log file
log_dfs = {config: process_log_file(path) for config, path in log_files.items()}

# Initialize a dictionary to hold summary data
summary_data = {
    'Configuration': [],
    'Average Computation Time per Epoch (sec)': [],
    'Overall Accuracy (%)': []
}

# Iterate over each configuration to calculate metrics
for config, df in log_dfs.items():
    # Calculate average computation time per epoch
    average_time_per_epoch = df.groupby('epoch')['time'].sum().mean()
    
    # Assuming the final accuracy is the last recorded accuracy in each epoch
    final_accuracy = df.groupby('epoch')['decode.acc_seg'].last().mean()
    
    # Append data to summary
    summary_data['Configuration'].append(config)
    summary_data['Average Computation Time per Epoch (sec)'].append(average_time_per_epoch)
    summary_data['Overall Accuracy (%)'].append(final_accuracy)

# Create DataFrame to display summary
summary_df = pd.DataFrame(summary_data)
print(summary_df)
