#!/bin/bash

# Load Kaldi environment
. ./path.sh || exit 1;
. ./cmd.sh || exit 1;

# Set the number of parallel jobs
nj=4  # Adjust based on your CPU cores

# Define directories
train_data="data/train"
lang_data="data/lang"
exp_dir="exp/mono"

# Step 1: Train monophone model
echo "Training Monophone GMM-HMM model..."
steps/train_mono.sh --nj $nj --cmd "run.pl" $train_data $lang_data $exp_dir || exit 1;

echo "Monophone training completed! Model saved in $exp_dir."

echo "Align the monophone model"
steps/align_si.sh --nj 4 --cmd run.pl data/train data/lang exp/mono exp/mono_ali
