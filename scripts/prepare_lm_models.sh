#!/bin/bash

# Step 1: language model intermediate
build-lm.sh -i data/local/dict/lm_train.text -n 1 -o data/local/lm_tmp/lm_phone_ug.ilm.gz
build-lm.sh -i data/local/dict/lm_train.text -n 2 -o data/local/lm_tmp/lm_phone_bg.ilm.gz


# Step 2: compile
mkdir -p data/local/nist_lm

compile-lm data/local/lm_tmp/lm_phone_ug.ilm.gz -t=yes /dev/stdout | grep -v unk | gzip -c > data/local/nist_lm/lm_phone_ug.arpa.gz

compile-lm data/local/lm_tmp/lm_phone_bg.ilm.gz -t=yes /dev/stdout | grep -v unk | gzip -c > data/local/nist_lm/lm_phone_bg.arpa.gz

# Step 3: create FST
utils/prepare_lang.sh --position-dependent-phones false \
  data/local/dict "<oov>" data/local/lang_tmp data/lang
WORDS_FILE="data/lang/words.txt"
if ! grep -q "^spn " "$WORDS_FILE"; then
    echo "spn 45" >> "$WORDS_FILE"  # Adjust the number accordingly
    echo "Added 'spn' to words.txt"
fi

# Step 4: sort
DATA_DIR="data"

for subset in train dev test; do
    for file in wav.scp text utt2spk; do
        if [ -f "$DATA_DIR/$subset/$file" ]; then
            sort "$DATA_DIR/$subset/$file" -o "$DATA_DIR/$subset/$file"
            echo "Sorted $DATA_DIR/$subset/$file"
        else
            echo "Warning: $DATA_DIR/$subset/$file not found!"
        fi
    done
done

echo "Data Sorting completed!"

# Step 5: create spk2utt
for subset in train dev test; do
    if [ -f "$DATA_DIR/$subset/utt2spk" ]; then
        utils/utt2spk_to_spk2utt.pl $DATA_DIR/$subset/utt2spk > $DATA_DIR/$subset/spk2utt
        echo "spk2utt created for $subset"
    else
        echo "Warning: utt2spk not found for $subset"
    fi
done

echo "spk2utt generation completed!"

# Step 6: generate G.fst

# USC-specific G.fst preparation
. ./path.sh || exit 1;

echo "Preparing train, dev, and test data for USC"

# Define paths
srcdir=data
lmdir=data/local/nist_lm
tmpdir=data/local/lm_tmp
lexicon=data/local/dict/lexicon.txt

mkdir -p $tmpdir



# Step 2: Prepare language models and FST
echo "Preparing language models for test"

for lm_suffix in ug bg; do  # unigram and bigram models
  test=data/lang_test_${lm_suffix}
  mkdir -p $test
  cp -r data/lang/* $test

  gunzip -c $lmdir/lm_phone_${lm_suffix}.arpa.gz | \
    arpa2fst --disambig-symbol=#0 --read-symbol-table=$test/words.txt - $test/G.fst || exit 1

  fstisstochastic $test/G.fst
  echo " Created G.fst for $lm_suffix"
  
  # Check for empty-word cycles in G.fst (diagnostics)
  mkdir -p $tmpdir/g
  awk '{if(NF==1){ printf("0 0 %s %s\n", $1,$1); }} END{print "0 0 #0 #0"; print "0";}' \
    < "$lexicon"  > $tmpdir/g/select_empty.fst.txt
  fstcompile --isymbols=$test/words.txt --osymbols=$test/words.txt $tmpdir/g/select_empty.fst.txt | \
    fstarcsort --sort_type=olabel | fstcompose - $test/G.fst > $tmpdir/g/empty_words.fst
  
  fstinfo $tmpdir/g/empty_words.fst | grep cyclic | grep -w 'y' &&
    echo " Language model has cycles with empty words" && exit 1
  
  rm -r $tmpdir/g
done

utils/validate_lang.pl data/lang_test_bg || exit 1

echo " Succeeded in formatting G.fst for USC"
rm -r $tmpdir

echo "G.fst successfully generated!"
