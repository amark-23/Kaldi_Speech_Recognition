#!/bin/bash

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

echo -e "\n${GREEN}All steps completed!${NC}"
