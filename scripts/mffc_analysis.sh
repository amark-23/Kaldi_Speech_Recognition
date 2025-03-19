#!/bin/bash

# Load Kaldi environment
. ./path.sh || exit 1;
. ./cmd.sh || exit 1;

# Step 1: Extract MFCCs
echo "Extracting MFCC features..."
for subset in train dev test; do
    steps/make_mfcc.sh --nj 4 --cmd "run.pl" data/$subset exp/make_mfcc/$subset mfcc || exit 1;
done
echo "MFCC extraction completed!"

# Step 2: Compute CMVN
echo "Computing Cepstral Mean and Variance Normalization (CMVN)..."
for subset in train dev test; do
    steps/compute_cmvn_stats.sh data/$subset exp/make_mfcc/$subset mfcc || exit 1;
done
echo "CMVN computation completed!"

# Step 3: Count the number of frames for the first 5 utterances in train
echo "Counting the number of acoustic frames for the first 5 utterances in train set..."
feat-to-len scp:data/train/feats.scp ark,t:- | head -n 5 > data/train/first_5_frames.txt

echo "Frame count saved in data/train/first_5_frames.txt:"
cat data/train/first_5_frames.txt

# Step 4: Check feature dimension
echo "Checking MFCC feature dimension..."
feat-to-dim scp:data/train/feats.scp -

