#!/bin/bash

# Define paths
DICT_DIR="data/local/dict"
TEXT_DIR="data"
LEXICON="lexicon.txt"  

# Step 1: Create the dictionary directory
mkdir -p $DICT_DIR

# Step 2: Create `silence_phones.txt` and `optional_silence.txt`
echo "sil" > $DICT_DIR/silence_phones.txt
echo "sil" > $DICT_DIR/optional_silence.txt

# Step 3: Extract phonemes from `lexicon.txt` to generate `nonsilence_phones.txt`
cut -f2- -d' ' $LEXICON | tr ' ' '\n' | sort -u > $DICT_DIR/nonsilence_phones.txt
sed -i '/<oov>/d' $DICT_DIR/nonsilence_phones.txt  # Remove <oov> if present
sed -i '/sil/d' $DICT_DIR/nonsilence_phones.txt  # Remove sil if present
echo "spn" >> $DICT_DIR/nonsilence_phones.txt

# Step 4: Create `lexicon.txt` (phoneme-to-phoneme mapping)
echo "<oov> spn" >> $DICT_DIR/lexicon.txt
awk '{print $1, $1}' $DICT_DIR/nonsilence_phones.txt | grep -v '^spn '>> $DICT_DIR/lexicon.txt
echo "sil sil" >> $DICT_DIR/lexicon.txt  # Add silence phoneme mapping

# Step 5: Generate `lm_train.text`, `lm_dev.text`, and `lm_test.text` with <s> and </s>
for subset in train dev test; do
    awk '{$1="";print "<s>", $0, "</s>"}' $TEXT_DIR/$subset/text > $DICT_DIR/lm_${subset}.text
    grep "<s> <s>" $DICT_DIR/lm_${subset}.text
    echo " lm_${subset}.text created!"
done

# Step 6: Create `extra_questions.txt` (empty)
touch $DICT_DIR/extra_questions.txt

echo " Dictionary preparation completed successfully."