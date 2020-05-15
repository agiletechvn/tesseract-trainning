#!/bin/bash

#  --fontlist "$MODEL_NAME" "Arial" \
MODEL_NAME=date
TESSDATA_DIR=./tessdata_best
# TRAINNED_DATA=$TESSDATA_DIR/digits.traineddata
TRAINNED_DATA=$TESSDATA_DIR/eng.traineddata
TRAINNED_TEXT=./eng.$MODEL_NAME.training_text
# TRAINNED_TEXT=./eng.MRZ.training_text


rm -rf ./${MODEL_NAME}
./tesstrain.sh \
--fonts_dir ./.fonts \
--lang eng --linedata_only \
--noextract_font_properties \
--langdata_dir ./langdata \
--tessdata_dir $TESSDATA_DIR \
--exposures "0" \
--save_box_tiff \
--fontlist "Arial" \
--training_text $TRAINNED_TEXT \
--workspace_dir ./tmp \
--output_dir ./${MODEL_NAME}

#  echo "/n ****** Finetune plus tessdata_best/eng model ***********"

rm -rf  ./${MODEL_NAME}_plus
mkdir  ./${MODEL_NAME}_plus

combine_tessdata -e $TRAINNED_DATA \
$TESSDATA_DIR/eng.lstm

lstmtraining \
--model_output ./${MODEL_NAME}_plus/${MODEL_NAME}_plus \
--traineddata ./${MODEL_NAME}/eng/eng.traineddata \
--continue_from $TESSDATA_DIR/eng.lstm \
--old_traineddata $TRAINNED_DATA \
--train_listfile ./${MODEL_NAME}/eng.training_files.txt \
--debug_interval 0 \
--max_iterations 2000


# best model from checkpoint
lstmtraining \
--stop_training \
--traineddata ./${MODEL_NAME}/eng/eng.traineddata \
--continue_from ./${MODEL_NAME}_plus/${MODEL_NAME}_plus_checkpoint \
--model_output ./${MODEL_NAME}_plus/${MODEL_NAME}.traineddata


# fast model from checkpoint
lstmtraining \
--stop_training \
--convert_to_int \
--traineddata ./${MODEL_NAME}/eng/eng.traineddata \
--continue_from ./${MODEL_NAME}_plus/${MODEL_NAME}_plus_checkpoint \
--model_output ./${MODEL_NAME}_plus/${MODEL_NAME}_int.traineddata


