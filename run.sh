#!/bin/bash
# Copyright 2020 Deepmind Technologies Limited.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Fail on any error.
set -e

# Display commands being run.
set -x


# Define the dataset name
DATASET_NAME="WaterDropSample"

# Get the current working directory and append "/learning_to_simulate"
temp=$(pwd)
temp+="/learning_to_simulate"

# Initialize the folder name with the dataset name followed by _temp_1
folder_name="${DATASET_NAME}_temp_1"
counter=1

# Check if the folder already exists, if so, increment the counter
while [ -d "$temp/$folder_name" ]; do
    counter=$((counter + 1))
    folder_name="${DATASET_NAME}_temp_$counter"
done

# Create the folder
mkdir "$temp/$folder_name"

# Store the entire path of the created folder in a new variable
TMP_DIR="$temp/$folder_name"


# virtualenv --python=python3.6 "${TMP_DIR}/learning_to_simulate"
# source "${TMP_DIR}/learning_to_simulate/bin/activate"

# Install dependencies.
# pip install --upgrade -r learning_to_simulate/requirements.txt

# Run the simple demo with dummy inputs.
python -m learning_to_simulate.model_demo

# Run some training and evaluation in one of the dataset samples.


bash ./learning_to_simulate/download_dataset.sh ${DATASET_NAME} "${TMP_DIR}/datasets"

# Train for a few steps.
DATA_PATH="${TMP_DIR}/datasets/${DATASET_NAME}"
MODEL_PATH="${TMP_DIR}/models/${DATASET_NAME}"
python -m learning_to_simulate.train --data_path=${DATA_PATH} --model_path=${MODEL_PATH} --num_steps=50

# Evaluate on validation split.
python -m learning_to_simulate.train --data_path=${DATA_PATH} --model_path=${MODEL_PATH} --mode="eval" --eval_split="valid"

# Generate test rollouts.
ROLLOUT_PATH="${TMP_DIR}/rollouts/${DATASET_NAME}"
mkdir -p ${ROLLOUT_PATH}
python -m learning_to_simulate.train --data_path=${DATA_PATH} --model_path=${MODEL_PATH} --mode="eval_rollout" --output_path=${ROLLOUT_PATH}

# Plot the first rollout.
python -m learning_to_simulate.render_rollout --rollout_path="${ROLLOUT_PATH}/rollout_test_0.pkl" --block_on_show=False --save_video_name="${TMP_DIR}/${TMP_DIR}.mp4"

# Clean up.
# rm -r ${TMP_DIR}
