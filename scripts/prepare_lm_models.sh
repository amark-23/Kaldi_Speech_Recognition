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


