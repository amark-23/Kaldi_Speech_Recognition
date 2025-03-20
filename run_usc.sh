#!/bin/bash

# Set Kaldi root directory (modify this if needed)
KALDI_ROOT=~/kaldi

# Add Kaldi binaries to PATH
export PATH=$KALDI_ROOT/tools/irstlm/bin:$KALDI_ROOT/src/lmbin:$KALDI_ROOT/src/fstbin:$KALDI_ROOT/src/gmmbin:$KALDI_ROOT/src/featbin:$KALDI_ROOT/src/latbin:$KALDI_ROOT/src/nnetbin:$KALDI_ROOT/src/nnet3bin:$KALDI_ROOT/src/sgmm2bin:$KALDI_ROOT/src/chainbin:$KALDI_ROOT/tools/openfst/bin:$PATH
export IRSTLM=~/kaldi/tools/irstlm
export PATH=$IRSTLM/bin:$PATH

# Define green color (and reset/no color)
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "\n${GREEN}Running data preperation...${NC}"
./scripts/data_prep.sh

echo -e "\n${GREEN}Running USC preparation...${NC}"
./scripts/prepare_usc.sh

echo -e "\n${GREEN}Running dictionary preparation...${NC}"
./scripts/prepare_dict.sh

echo -e "\n${GREEN}Initializing language models...${NC}"
./scripts/prepare_lm_models.sh

echo -e "\n${GREEN}Evaluating language models...${NC}"
./scripts/evaluate_models.sh

echo -e "\n${GREEN}Extracting MFCC features...${NC}"
./scripts/mffc_analysis.sh

echo -e "\n${GREEN}Training Monophone GMM-HMM model...${NC}"
./scripts/train_mono.sh
./scripts/HCLGgraphs.sh

echo -e "\n${GREEN}Decoding & scoring ...${NC}\n"
./scripts/decode_data.sh

echo -e "\n${GREEN}Training Triphone model...${NC}\n"
./scripts/train_tri.sh

echo -e "\n${GREEN}All steps completed!${NC}"
