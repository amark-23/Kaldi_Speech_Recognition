**1. Description**

The purpose of this project is to develop a speech recognition system using Kaldi, a powerful speech processing tool. Specifically, the system will recognize phonemes from recordings in the USC-TIMIT dataset by training both acoustic and language models.

The process is divided into four main stages:
- Extracting acoustic features (MFCCs) from the audio data.
- Constructing a language model that computes the probability of phoneme sequences.
- Training acoustic models (GMM-HMM & DNN-HMM) to map acoustic features to phonemes.
- Decoding sentences, where the system converts new audio into a phonetic representation and evaluates performance using the Phone Error Rate (PER).

---

**2. Theoretical Background**

### **Mel-Frequency Cepstral Coefficients (MFCCs)**

MFCCs are a widely used method for extracting features from audio signals, especially useful in Automatic Speech Recognition (ASR) systems. They are numerical coefficients that represent the spectrum of an audio signal in a way that mimics human hearing.

The human ear does not perceive frequencies linearly but according to the Mel Scale, a nonlinear scale reflecting human sensitivity to different frequencies:
- At low frequencies (<~1kHz), the human ear can distinguish very small changes.
- At high frequencies (>~1kHz), the ear has reduced sensitivity, perceiving larger frequency intervals as similar.

MFCCs exploit this behavior using a Mel filterbank that partitions the audio spectrum according to the Mel scale.

#### **MFCC Computation Process:**
1. **Pre-Emphasis:** A pre-emphasis filter is applied to enhance high frequencies, balancing the spectrum and improving the signal-to-noise ratio (SNR). The filter is defined as: *y(t) = x(t) - α ⋅ x(t-1)*, where *α* is typically 0.95 or 0.97.
2. **Framing:** The signal is divided into small time frames (20-40 ms) with 50% overlap, assuming signal properties remain stable within such short periods.
3. **Windowing:** A window function (e.g., Hamming window) is applied to each frame to minimize spectral leakage.
4. **Fast Fourier Transform (FFT):** Converts the signal from the time domain to the frequency domain.
5. **Power Spectrum Calculation:** Computes the power spectrum of each frame, representing energy distribution across frequencies.
6. **Mel Filterbank Application:** The power spectrum is passed through a series of filters distributed according to the Mel scale.
7. **Logarithmic Scaling:** Logarithmic scaling is applied to simulate human perception of sound intensity.
8. **Discrete Cosine Transform (DCT):** DCT is applied to the logarithmically scaled results to decorrelate the coefficients and produce the MFCCs. Typically, the first 2-13 coefficients are retained.

While MFCCs are the most common feature in speech recognition, they have limitations:
- **Loss of phase information** (since they rely only on the magnitude spectrum).
- **Noise sensitivity** if not properly normalized.
- **Temporal constraints** as they are designed for short-time windows.

Modern approaches such as Mel Spectrograms, CNN-enhanced MFCCs, and Wave2Vec 2.0 (self-supervised learning) provide improvements.

---

### **Language Models (LMs)**

Language Models (LMs) are a fundamental component of ASR systems. Their role is to assign probabilities to possible word or phoneme sequences, determining the most likely sequences in the recognized language. When an ASR system converts audio into possible words or phonemes, multiple potential transcriptions exist. The language model helps correct recognition errors by eliminating improbable combinations and improving recognition accuracy using statistical knowledge of the language.

#### **Types of Language Models:**
1. **N-gram Models:**
   - Use statistical probabilities to estimate the likelihood of a word/phoneme based on previous words/phonemes.
   - *Bigram Model:* *P(w_n | w_(n-1))* (probability of a word depends on the previous word).
   - *Unigram Model:* Probability of a word is independent of previous words.
2. **HMM-based Language Models:**
   - Combine with acoustic models to describe word sequences alongside their acoustic representations.
3. **Neural Language Models (Neural LMs):**
   - Use neural networks (RNNs, LSTMs, or Transformers) to learn richer representations.
   - Higher computational complexity but better generalization ability.

A key evaluation metric for language models is **Perplexity (PP):**

$$
PP(W) = P(w_1, w_2, \dots, w_n)^{-1/n}
$$

Lower perplexity indicates a better language model, as it means the model is more confident in predicting word sequences.

---

### **Acoustic Models (AMs)**

Acoustic Models (AMs) in an ASR system map audio signals to possible phoneme or word sequences. That is, they estimate the probability of a particular sound (feature vector) corresponding to a phoneme.

#### **Types of Acoustic Models:**
1. **GMM-HMM (Gaussian Mixture Model - Hidden Markov Model):**
   - Uses Hidden Markov Models (HMMs) to model phoneme sequences.
   - Gaussian Mixture Models (GMMs) estimate the probability of audio features corresponding to phonemes.
   - Trained using the Baum-Welch (Expectation-Maximization) algorithm.
2. **DNN-HMM (Deep Neural Network - HMM):**
   - Replaces GMMs with Deep Neural Networks (DNNs), improving accuracy by learning nonlinear relationships between audio features and phonemes.
3. **End-to-End Models (CTC / Attention-based):**
   - Do not require separate acoustic and language models.
   - Directly convert audio into text using RNNs, LSTMs, or Transformer Networks.

#### **GMM-HMM Acoustic Models**
GMM-HMM models are used in speech recognition to map acoustic features (such as MFCCs) to phonemes.

**Structure of an HMM for Speech Recognition:**
- **States:** Each phoneme is represented by a set of HMM states (typically 3-5).
- **Transitions:** Describe how phonemes change over time.
- **Emission Probabilities:** Use GMMs to determine the probability of an MFCC belonging to a specific state.

The emission probability of a feature *x* given a state *s* is:

$$
P(x | s) = \sum_{i=1}^{M} w_i N(x | \mu_i, \Sigma_i)
$$

$$
M = \text{number of Gaussian components}
$$

$$
w_i = \text{weights of each Gaussian}
$$

$$
N(x | \mu_i, \Sigma_i) = \text{Gaussian distribution with mean } \mu_i \text{ and covariance } \Sigma_i
$$

---

### **Combining Language and Acoustic Models**
Speech recognition is based on Bayes' theorem, where we seek the word/phoneme that maximizes the probability given the audio signal:

$$
\hat{W} = \arg\max_W P(W | X)
$$

Using Bayes' rule:

$$
P(W | X) = \frac{P(X | W) P(W)}{P(X)}
$$

where:
- *P(X | W)*: The acoustic model estimates how likely the audio signal X is given the word W.
- *P(W)*: The language model estimates the probability of a word sequence.
- *P(X)*: A constant that does not affect maximization.

The ASR system combines these two models to determine the most probable word sequence.

Modern neural network models (DNN-HMM and End-to-End models) have replaced traditional GMM-HMM approaches, achieving better speech recognition accuracy.

**3. Preparation**

We create a folder named `usc` inside the `kaldi/egs` directory. The script `scripts/data_prep.sh` generates all necessary files, specifically setting up the directories `data/dev`, `data/train`, and `data/test`. Within these, it organizes the following files:

- `uttids`: Contains a unique symbolic name for each utterance in the dataset.
- `utt2spk`: Maps each utterance to its respective speaker, formatted as `utterance_id <space> speaker_id`.
- `wav.scp`: Specifies the location of the corresponding audio file for each utterance, formatted as `utterance_id <space> /path/to/wav`.
- `text`: Contains the transcription of each utterance, formatted as `utterance_id <space> <utterance_text>`.

In the `text` file, words are replaced with phonemes, punctuation is removed, and silence phonemes (`sil`) are added at the beginning and end of each utterance. For example, the sentence: 

**"This was easy for us."** 

is transformed into: 

**"sil dh ih s w ao z iy z iy f r er ah s sil"**

---

**4. Main Steps**

### **Speech Recognition Setup with USC-TIMIT**

The script `scripts/prepare_usc.sh` creates soft links to the `/steps` and `/utils` directories and copies modified versions of `path.sh` and `cmd.sh` from the `/wsj` folder. It also creates the necessary directories: `local`, `conf`, `data/lang`, `data/local/dict`, `data/local/lm_tmp`, and `data/local/nist_lm`.

### **Language Model Preparation**

The script `scripts/prepare_dict.sh` generates the required files for the `data/local/dict` directory, including:

- `silence_phones.txt` and `optional-silence.txt`, which contain only the phoneme `sil`.
- `nonsilence_phones.txt`, containing all phonemes (aa, ae, etc.) from the dataset.
- `lexicon.txt`, mapping phonemes to themselves. The `<oov>` phoneme is also added for unknown words.
- `lm_dev.txt`, `lm_test.txt`, and `lm_train.txt`, each containing text with `<s>` at the beginning and `</s>` at the end of every sentence.
- `extra_questions.txt`, which lists additional phoneme variations.

The script `scripts/prepare_lm_models` handles language model creation. It first generates an intermediate LM format in `data/local/lm_temp` with the command:

```
build-lm.sh -I <lm_train.text> -n <lm class> -o <output file.ilm.gz>
```

Then, it compiles the LM into ARPA format using:

```
compile-lm.sh <input file.ilm.gz> -t=yes /dev/stdout | grep -v unk | gzip -c > <output file.arpa.gz>
```

The `prepare_lang.sh` script is used to create the lexicon FST. Additionally, `utils/utt2spk_to_spk2utt` is used to generate `spk2utt` mappings, and the grammar FST is built.

Using `scripts/evaluate_models.sh`, we calculate perplexity on training and validation sets. The results indicate:
![image](https://github.com/user-attachments/assets/14753bb6-e3f2-4119-aa00-24d08c1a8c47)

- **Unigram Model (PP ≈ 31.5 on test, 31.87 on validation):** Higher perplexity due to lack of contextual understanding.
- **Bigram Model (PP ≈ 17.05 on test, 17.30 on validation):** Lower perplexity, indicating better phoneme prediction compared to unigrams.

### **Acoustic Feature Extraction**

The script `scripts/mfcc_analysis` extracts MFCCs for all three sets using:

```
make_mfcc.sh
compute_cmvn_stats.sh
```

The `compute_cmvn_stats.sh` command applies Cepstral Mean and Variance Normalization (CMVN) to stabilize acoustic features by:

- **Removing recording condition effects** by normalizing mean values.
- **Normalizing dynamic range** by standardizing feature variances.

### Mathematical Representation

1. **Mean Normalization**

   - Compute the mean for each feature dimension:

     μ⁽ᵈ⁾ = (1 / T) Σ xₜ⁽ᵈ⁾

   - Subtract the mean:

     xₜ⁽ᵈ⁾ = xₜ⁽ᵈ⁾ − μ⁽ᵈ⁾

2. **Variance Normalization**

   - Compute standard deviation:

     σ⁽ᵈ⁾ = √[ (1 / T) Σ (xₜ⁽ᵈ⁾ − μ⁽ᵈ⁾)² ]

   - Normalize:

     xₜ⁽ᵈ⁾ = (xₜ⁽ᵈ⁾ − μ⁽ᵈ⁾) / σ⁽ᵈ⁾

Using `feat_to_dim` and `feat_to_len`, we analyze the feature dimensions and frame counts per utterance. The first five utterances have frame counts: 317, 371, 399, 328, and 464, all with 13-dimensional features.

---

### **Acoustic Model Training and Sentence Decoding**

Using `scripts/train_mono.sh`, we train a **monophone GMM-HMM acoustic model** on the training data and align phonemes with:

```
train_mono.sh --nj $nj --cmd "run.pl" $train_data $lang_data $exp_dir || exit 1;
align_si.sh --nj 4 --cmd run.pl data/train data/lang exp/mono exp/mono_ali
```

Next, we construct the **Kaldi HCLG decoding graph** using `mkgraph.sh` for both unigram and bigram models. The **HCLG graph** integrates:

- **H:** Context-Dependent Phones (HMM states modeling phonemes and their transitions).
- **C:** Phonetic Context Clustering (decision trees for state tying).
- **L:** Lexicon (word-to-phoneme mapping).
- **G:** Grammar (language model defining word sequence probabilities).

With `scripts/decode_data.sh`, we decode the validation/test sets using the **Viterbi algorithm** via:

```
decode.sh
```

Finally, **Phone Error Rate (PER)** is computed:
![image](https://github.com/user-attachments/assets/583cc5bd-5869-4ffb-bfd7-5e97c460a347)

- **Bigram model has lower PER than Unigram.**
- **Best PER achieved: 44.56%.**

### **Scoring Hyperparameters:**
- **Insertion Penalty (IP):** Regulates false phoneme insertions.
- **Language Model Weight (LMW):** Controls the influence of the LM relative to the AM.

The best values (`LMW=7.0, IP=0.0`) were found in the `best_wer` output:

```
%WER 44.56 [ 5526 / 12400, 183 ins, 2538 del, 2805 sub ] exp/mono/decode_bg_test/wer_7_0.0
```

### **Triphone Model Training**
The script `train_tri.sh` trains a triphone model, yielding:


![image](https://github.com/user-attachments/assets/87415cb7-1644-41f4-857d-5e2c7cf3139d)

- **PER = 33.85% (better than monophone models).**
- **Triphones consider phoneme context, improving accuracy.**

To further improve performance, **state-tying techniques** and **DNN-HMM models** could be employed to reduce PER even further.

---

**Final Notes:**
- The entire process can be executed sequentially using `run_usc.sh`.
- The `cleanup.sh` script can reset the directory.

Future enhancements could include deep learning models such as Transformer-based ASR systems for even higher accuracy.

