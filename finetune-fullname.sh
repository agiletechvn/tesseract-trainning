#!/bin/bash

#  --fontlist "OCRB" "Arial" \

# combine_tessdata -u vie.traineddata vie.

# set_unicharset_properties -U vie.unicharset -O new_unicharset --script_dir=langdata

TESSDATA_DIR=./tessdata_best
LANG=eng
TRAINNED_DATA=${LANG}.traineddata
TRAINNED_TEXT=./vie.fullnames.training_text
NAME=fullnames


rm -rf ./$NAME
./tesstrain.sh \
--fonts_dir ./.fonts \
--lang $LANG --linedata_only \
--noextract_font_properties \
--langdata_dir ./langdata \
--tessdata_dir $TESSDATA_DIR \
--exposures "0" \
--save_box_tiff \
--fontlist "Arial" \
--training_text $TRAINNED_TEXT \
--workspace_dir ./tmp \
--output_dir ./$NAME

rm -rf  ./${NAME}_plus
mkdir  ./${NAME}_plus

combine_tessdata -e $TESSDATA_DIR/$TRAINNED_DATA \
$TESSDATA_DIR/${LANG}.lstm

lstmtraining \
--model_output ./${NAME}_plus/${NAME}_plus \
--traineddata ./$NAME/${LANG}/$TRAINNED_DATA \
--continue_from $TESSDATA_DIR/${LANG}.lstm \
--old_traineddata $TESSDATA_DIR/$TRAINNED_DATA \
--train_listfile ./$NAME/${LANG}.training_files.txt \
--debug_interval 0 \
--max_iterations 2000


lstmtraining \
--stop_training \
--convert_to_int \
--traineddata ./$NAME/${LANG}/$TRAINNED_DATA \
--continue_from ./${NAME}_plus/${NAME}_plus_checkpoint \
--model_output ./${NAME}_plus/${NAME}_int.traineddata

