#!/bin/bash

# Define paths
EXP_DIR=exp/mono  # Path to monophone model
DECODE_NJ=4       # Number of parallel jobs (adjust based on CPU)
GRAPH_UG=$EXP_DIR/graph_ug
GRAPH_BG=$EXP_DIR/graph_bg
DATA_DEV=data/dev
DATA_TEST=data/test

# Ensure scoring script exists
if [ ! -f local/score.sh ]; then
    echo "Copying Kaldi scoring script..."
    cp ~/kaldi/egs/wsj/s5/local/score.sh local/score.sh
    chmod +x local/score.sh
fi

echo "############################################"
echo "Step 1: Decoding Validation & Test Sets (Unigram)"
echo "############################################"

# Decode validation set with unigram model
steps/decode.sh --nj $DECODE_NJ --cmd run.pl $GRAPH_UG $DATA_DEV $EXP_DIR/decode_ug_dev
# Decode test set with unigram model
steps/decode.sh --nj $DECODE_NJ --cmd run.pl $GRAPH_UG $DATA_TEST $EXP_DIR/decode_ug_test

echo "############################################"
echo "Step 2: Decoding Validation & Test Sets (Bigram)"
echo "############################################"

# Decode validation set with bigram model
steps/decode.sh --nj $DECODE_NJ --cmd run.pl $GRAPH_BG $DATA_DEV $EXP_DIR/decode_bg_dev
# Decode test set with bigram model
steps/decode.sh --nj $DECODE_NJ --cmd run.pl $GRAPH_BG $DATA_TEST $EXP_DIR/decode_bg_test

echo "############################################"
echo "Step 3: Running Scoring (PER Calculation)"
echo "############################################"

# Function to calculate PER (Phone Error Rate)
calculate_per() {
    DECODE_DIR=$1
    SCORING_DIR="$DECODE_DIR/scoring_kaldi"
    BEST_WER_FILE="$SCORING_DIR/best_wer"

    echo "Scoring: $DECODE_DIR"

    if [ ! -f "$BEST_WER_FILE" ]; then
        echo "Error: best_wer file not found in $SCORING_DIR!"
        return
    fi

    # Extract the best WER string
    WER_STRING=$(cat "$BEST_WER_FILE")

    # Extract values using grep and awk
    TOTAL_PHONEMES=$(echo "$WER_STRING" | grep -oP '\[ \d+ / \K\d+')
    INSERTIONS=$(echo "$WER_STRING" | grep -oP '\d+(?= ins)')
    DELETIONS=$(echo "$WER_STRING" | grep -oP '\d+(?= del)')
    SUBSTITUTIONS=$(echo "$WER_STRING" | grep -oP '\d+(?= sub)')

    # Print extracted values
    echo "Total phonemes: $TOTAL_PHONEMES"
    echo "Insertions: $INSERTIONS"
    echo "Deletions: $DELETIONS"
    echo "Substitutions: $SUBSTITUTIONS"

    # Calculate PER
    if [[ -n "$TOTAL_PHONEMES" && "$TOTAL_PHONEMES" -gt 0 ]]; then
        PER=$(echo "scale=2; 100 * ($INSERTIONS + $SUBSTITUTIONS + $DELETIONS) / $TOTAL_PHONEMES" | bc)
        echo "PER for $DECODE_DIR: $PER%"
    else
        echo "Error: Total phonemes count is zero or missing!"
    fi
}

# Compute PER for all decoding runs
calculate_per "$EXP_DIR/decode_ug_dev" "$DATA_DEV"
calculate_per "$EXP_DIR/decode_ug_test" "$DATA_TEST"
calculate_per "$EXP_DIR/decode_bg_dev" "$DATA_DEV"
calculate_per "$EXP_DIR/decode_bg_test" "$DATA_TEST"

echo "############################################"
echo "Decoding and PER calculation completed!"
echo "############################################"
