#!/bin/bash
mkdir data/local/lm_tmp
build-lm.sh -i data/local/dict/lm_train.text -n 1 -o data/local/lm_tmp/lm_phone_ug.ilm.gz
build-lm.sh -i data/local/dict/lm_train.text -n 2 -o data/local/lm_tmp/lm_phone_bg.ilm.gz

echo ""
echo "Unigram Perplexity(test):"
compile-lm data/local/lm_tmp/lm_phone_ug.ilm.gz --eval=data/local/dict/lm_test.text --dub=10000000
echo ""

echo ""
echo "Unigram Perplexity(val):"
compile-lm data/local/lm_tmp/lm_phone_ug.ilm.gz --eval=data/local/dict/lm_dev.text --dub=10000000
echo ""

echo ""
echo "Bigram Perplexity(test):"
compile-lm data/local/lm_tmp/lm_phone_bg.ilm.gz --eval=data/local/dict/lm_test.text --dub=10000000
echo ""

echo ""
echo "Bigram Perplexity(val):"
compile-lm data/local/lm_tmp/lm_phone_bg.ilm.gz --eval=data/local/dict/lm_dev.text --dub=10000000
echo ""




