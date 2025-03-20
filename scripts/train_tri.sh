#!/bin/bash

# Define paths
EXP_DIR=exp/mono               # Path to monophone model
EXP_TRI_DIR=exp/tri             # Path to triphone model
DECODE_NJ=4                     # Number of parallel jobs
GRAPH_TRI=$EXP_TRI_DIR/graph    # Path for triphone decoding graph
DATA_DEV=data/dev
DATA_TEST=data/test
ALI_DIR=exp/mono_ali            # Path for monophone alignments

echo "############################################"
echo "Step 1: Aligning phonemes using Monophone Model"
echo "############################################"
steps/align_si.sh --nj 4 --cmd run.pl data/train data/lang exp/mono exp/mono_ali

echo "############################################"
echo "Step 2: Training Triphone Model"
echo "############################################"
steps/train_deltas.sh --cmd run.pl 2000 10000 data/train data/lang exp/mono_ali exp/tri


echo "############################################"
echo "Step 3: Creating HCLG Graph for Triphone Model"
echo "############################################"

# ====== Check and recreate lm.arpa if missing ======
LM_ARPA="data/local/lm.arpa"
if [ ! -f "$LM_ARPA" ] || [ ! -s "$LM_ARPA" ]; then
    echo -e "\n${GREEN}G.fst missing. Recreating lm.arpa...${NC}"
    
    build-lm.sh -i data/local/dict/lm_train.text -n 2 -o data/local/lm_tmp/lm_phone_bg.ilm.gz
    compile-lm data/local/lm_tmp/lm_phone_bg.ilm.gz -t=yes /dev/stdout | grep -v unk | gzip -c > data/local/lm.arpa.gz
    gunzip -c data/local/lm.arpa.gz > data/local/lm.arpa
fi

# Recreate G.fst if it doesn't exist
if [ ! -f data/lang/G.fst ]; then
    echo "G.fst missing. Recreating it..."
    arpa2fst --disambig-symbol=#0 --read-symbol-table=data/lang/words.txt \
        data/local/lm.arpa data/lang/G.fst || exit 1
    fstisstochastic data/lang/G.fst
fi
# create the decoding graph
utils/mkgraph.sh data/lang $EXP_TRI_DIR $GRAPH_TRI

echo "############################################"
echo "Step 4: Decoding Validation & Test Sets with Triphone Model"
echo "############################################"
steps/decode.sh --nj $DECODE_NJ --cmd run.pl $GRAPH_TRI $DATA_DEV $EXP_TRI_DIR/decode_dev
steps/decode.sh --nj $DECODE_NJ --cmd run.pl $GRAPH_TRI $DATA_TEST $EXP_TRI_DIR/decode_test

echo "############################################"
echo "Step 5: Running Scoring (PER Calculation)"
echo "############################################"

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

calculate_per "$EXP_TRI_DIR/decode_dev"
calculate_per "$EXP_TRI_DIR/decode_test"

echo "############################################"
echo "Training and decoding completed!"
echo "############################################"
