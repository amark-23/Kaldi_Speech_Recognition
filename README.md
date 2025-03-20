---

# **Phoneme Recognition using Kaldi**

This repository contains scripts and resources for training and evaluating phoneme-based speech recognition models using the **Kaldi** toolkit. The project follows a step-by-step process from **data preparation** to **training monophone and triphone models**, **decoding** using the **Viterbi algorithm**, and evaluating results using **Phone Error Rate (PER)**.


---

## 🛠 **Installation**
1. Install **Kaldi** following the official instructions:  
   - [Kaldi Installation Guide](http://kaldi-asr.org/doc/install.html)
2. Clone this repository into your **Kaldi egs** directory:  
   ```bash
   cd ~/kaldi/egs
   git clone https://github.com/amark-23/Kaldi_Speech_Recognition.git usc
   cd usc
   ```
3. Set up your Kaldi environment:
   ```bash
   export KALDI_ROOT=~/kaldi
   export PATH=$KALDI_ROOT/tools/irstlm/bin:$KALDI_ROOT/src/lmbin:$KALDI_ROOT/src/fstbin:$KALDI_ROOT/src/gmmbin:$KALDI_ROOT/src/featbin:$KALDI_ROOT/src/latbin:$KALDI_ROOT/src/nnetbin:$KALDI_ROOT/src/nnet3bin:$KALDI_ROOT/src/sgmm2bin:$KALDI_ROOT/src/chainbin:$KALDI_ROOT/tools/openfst/bin:$PATH
   ```
 
 4. Add a dataset, as described below, to the project folder
 
 5. Execute the pipeline:
    ```bash
    chmod +x run_usc.sh
    ./run_usc.sh  
    ```
---

## 📂 **Dataset**
The dataset consists of **recordings from 4 speakers** (m1, m3, f1, f5) with **460 utterances per speaker**.  
📌 **Download the dataset**: [USC](https://drive.google.com/file/d/1_mIoioHMeC2HZtIbGs1LcL4kkIF696nB/view)  

📁 **Data Structure**:
```
usc
├── wav/                     # Audio recordings
├── lexicon.txt              # A disctionary of the English Language  
├── filesets/                # Train, Dev, and Test partitions
├── transcription.txt        # Text transcriptions
```

---

## 📌 **Project Structure**
```
usc/
├── wav/                     # Audio recordings
├── lexicon.txt              # A disctionary of the English Language  
├── filesets/                # Train, Dev, and Test partitions
├── transcription.txt        # Text transcriptions
├── data/
│   ├── train/               # Training set metadata
│   ├── dev/                 # Validation set metadata
│   ├── test/                # Test set metadata
│   ├── lang/                # Kaldi language models
│   ├── local/
│      ├── local/dict/       # Lexicon and phoneme mapping
│      ├── local/lm_tmp/     # Intermediate LM files
│      ├── local/nist_lm/    # Final compiled LM
├── exp/                     # Experiment results (models, alignments)
├── scripts/                 # Shell scripts for automation
├── run_usc.sh               # Main script to execute the pipeline
├── cleanup.sh               # Cleanup script to reset repository   
```



---

## 🏗 **Preprocessing**
1. **Data preparation**  
   - Convert transcriptions to phoneme sequences  
   - Generate **utt2spk**, **wav.scp**, and **text** files  
   - Sort and format data for Kaldi  
   ```bash
   ./scripts/data_prep.sh
   ```
2. **Lexicon & Phoneme Mapping**  
   - Create **phoneme lexicon (lexicon.txt)**  
   - Define **silence and non-silence phonemes**  
   ```bash
   ./scripts/prepare_dict.sh
   ```
3. **Language Model Training**  
   - Unigram and Bigram models are trained using IRSTLM  
   - Compile **ARPA** language models  
   ```bash
   ./scripts/prepare_lm_models.sh
   ```

---

## 🎙 **Feature Extraction**
MFCC features are extracted using:
1. **make_mfcc.sh**  
2. **compute_cmvn_stats.sh** (Cepstral Mean & Variance Normalization)  
```bash
./scripts/mffc_analysis.sh
```

---

## 🔥 **Acoustic Model Training**
1. **Train Monophone (Mono) GMM-HMM Model**  
   ```bash
   ./scripts/train_mono.sh
   ```
2. **Train Triphone (Tri) GMM-HMM Model**  
   - Align monophone model  
   - Train triphone model using delta features  
   ```bash
   ./scripts/train_tri.sh
   ```

---

## 🔎 **Decoding and Scoring**
1. **Create HCLG decoding graph**  
   ```bash
   ./scripts/HCLGgraphs.sh
   ```
2. **Decode validation & test sets** using **Viterbi algorithm** and **compute Phone Error Rate (PER)**
   ```bash
   ./scripts/decode_data.sh
   ```

---



## 📖 **References**
- Kaldi Documentation: [http://kaldi-asr.org/doc/](http://kaldi-asr.org/doc/)
- Kaldi for Beginners: [http://kaldi-asr.org/doc/kaldi_for_dummies.html](http://kaldi-asr.org/doc/kaldi_for_dummies.html)

---

