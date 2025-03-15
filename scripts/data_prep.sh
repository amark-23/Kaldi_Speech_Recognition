#!/bin/bash

# Define paths
DATA_DIR="data"
FILESET_DIR="filesets"
WAV_DIR="wav"
TRANSCRIPTIONS="transcriptions.txt"
LEXICON="lexicon.txt"

# Step 1: Create necessary directories
mkdir -p $DATA_DIR/train $DATA_DIR/dev $DATA_DIR/test

# Step 2: Copy utterance IDs into `uttids` files
cp $FILESET_DIR/training.txt $DATA_DIR/train/uttids
cp $FILESET_DIR/validation.txt $DATA_DIR/dev/uttids
cp $FILESET_DIR/testing.txt $DATA_DIR/test/uttids
echo "uttids files created successfully"

# Step 3: Generate `utt2spk` (map utterances to speaker IDs)
for subset in train dev test; do
    while read -r line; do
        spk=$(echo "$line" | cut -d'_' -f1)
        echo "$line $spk" >> $DATA_DIR/$subset/utt2spk
    done < $DATA_DIR/$subset/uttids
    echo "utt2spk for $subset created"
done

# Step 4: Generate `wav.scp` (map utterances to `.wav` files)
for subset in train dev test; do
    while read -r line; do
        echo "$line $WAV_DIR/$line.wav" >> $DATA_DIR/$subset/wav.scp
    done < $DATA_DIR/$subset/uttids
    echo "wav.scp for $subset created"
done

# Step 5: Generate `text` files (remove second number)
for subset in train dev test; do
    mapfile -t transcriptions < $TRANSCRIPTIONS  

    while read -r line; do
        number=$(echo "$line" | grep -oE '[0-9]{3}$' | sed 's/^0*//')

        if [[ -n "$number" && "$number" -gt 0 && "$number" -le ${#transcriptions[@]} ]]; then
            cleaned_text=$(echo "${transcriptions[number-1]}" | tr '[:upper:]' '[:lower:]' | sed "s/[^a-zA-Z0-9' ]//g")
            utt_id=$(echo "$line" | awk '{print $1}')
            echo "$utt_id $cleaned_text" >> "$DATA_DIR/$subset/text"
        else
            echo "Warning: No valid transcription found for $line"
        fi
    done < $DATA_DIR/$subset/uttids

    echo "text for $subset created and cleaned"
    sed -i 's/^\(.\{7\}\).../\1/' "$DATA_DIR/$subset/text"
done

# Step 6: Convert `text` to phonemes using `lexicon.txt`
for subset in train dev test; do
    while IFS= read -r line || [[ -n "$line" ]]; do
        utt_id=$(echo "$line" | awk '{print $1}')  # Extract utterance ID
        sentence=$(echo "$line" | cut -d' ' -f2-)  # Extract sentence text

        phonemes="sil"
        for word in $sentence; do
            word_upper=$(echo "$word" | tr '[:lower:]' '[:upper:]' | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            lex_entry=$(LC_ALL=C grep -m1 -P "^$word_upper\t" "$LEXICON")

            if [[ -n "$lex_entry" ]]; then
                word_phonemes=$(echo "$lex_entry" | cut -f2-)
                phonemes="$phonemes $word_phonemes"
            else
                phonemes="$phonemes spn"  # Handle missing words
            fi
        done
        phonemes="$phonemes sil"

        echo "$utt_id $phonemes" >> $DATA_DIR/$subset/text_phonemes
    done < "$DATA_DIR/$subset/text"

    echo "text converted to phonemes for $subset"
done

echo "All steps completed successfully!"
