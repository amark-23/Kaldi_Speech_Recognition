#!/bin/bash

# Define paths
KALDI_ROOT="/home/a-mark23/kaldi"  # Update this path if needed
WSJ_DIR="../wsj/s5"
USC_DIR="."
CONF_DIR="$USC_DIR/conf"
DICT_DIR="$USC_DIR/data/local/dict"

# Step 1: Copy path.sh and cmd.sh
cp $WSJ_DIR/path.sh $USC_DIR/path.sh
cp $WSJ_DIR/cmd.sh $USC_DIR/cmd.sh

# Step 2: Update path.sh
sed -i "s|export KALDI_ROOT=.*|export KALDI_ROOT=$KALDI_ROOT|" $USC_DIR/path.sh
if ! grep -q "irstlm/bin" $USC_DIR/path.sh; then
    echo "export PATH=\$KALDI_ROOT/tools/irstlm/bin:\$PATH" >> $USC_DIR/path.sh
fi


# Step 3: Update cmd.sh (replace queue.pl with run.pl)
sed -i 's|queue.pl|run.pl|g' $USC_DIR/cmd.sh

# Step 4: Create soft links for 'steps' and 'utils'
ln -sfn $WSJ_DIR/steps $USC_DIR/steps
ln -sfn $WSJ_DIR/utils $USC_DIR/utils

# Step 5: Create 'local' directory and link 'score_kaldi.sh'
mkdir -p $USC_DIR/local
ln -sfn $WSJ_DIR/steps/score_kaldi.sh $USC_DIR/local/score_kaldi.sh

# Step 6: Create 'conf' directory and copy 'mfcc.conf'
mkdir -p $CONF_DIR
cp $WSJ_DIR/conf/mfcc.conf $CONF_DIR/mfcc.conf
echo "--sample-frequency=22050" >> $CONF_DIR/mfcc.conf

# Step 7: Create necessary directories inside 'data'
mkdir -p $USC_DIR/data/lang
mkdir -p $DICT_DIR
mkdir -p $USC_DIR/data/local/lm_tmp
mkdir -p $USC_DIR/data/local/nist_lm

echo "USC Kaldi preparation completed successfully."

