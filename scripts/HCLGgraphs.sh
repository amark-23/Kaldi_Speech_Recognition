# Define paths
LANG_DIR=data/lang
EXP_DIR=exp/mono
LM_UG=data/lang_test_ug
LM_BG=data/lang_test_bg

# Create decoding graph for unigram model
utils/mkgraph.sh --mono $LM_UG $EXP_DIR $EXP_DIR/graph_ug

# Create decoding graph for bigram model
utils/mkgraph.sh --mono $LM_BG $EXP_DIR $EXP_DIR/graph_bg
