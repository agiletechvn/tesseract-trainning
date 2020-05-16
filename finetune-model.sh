#!/bin/bash

while getopts "m:o:f:" opt; do
  case "$opt" in
    m)  MODEL=$OPTARG
    ;;
    o)  OUTPUT=$OPTARG
    ;;   
    f)  FONT=$OPTARG
    ;;
  esac
done

: ${MODEL:="eng"}
: ${OUTPUT:="date"}
: ${FONT:="Arial"}


TESSDATA_DIR=./tessdata_best
# TRAINNED_DATA=$TESSDATA_DIR/digits.traineddata
TRAINNED_DATA=$TESSDATA_DIR/${MODEL}.traineddata
TRAINNED_TEXT=./${MODEL}.$OUTPUT.training_text
# TRAINNED_TEXT=./${MODEL}.MRZ.training_text


rm -rf ./${OUTPUT}
./tesstrain.sh \
--fonts_dir ./.fonts \
--lang ${MODEL} --linedata_only \
--noextract_font_properties \
--langdata_dir ./langdata \
--tessdata_dir $TESSDATA_DIR \
--exposures "0" \
--save_box_tiff \
--fontlist $FONT \
--training_text $TRAINNED_TEXT \
--workspace_dir ./tmp \
--output_dir ./${OUTPUT}

#  echo "/n ****** Finetune plus tessdata_best/${MODEL} model ***********"

rm -rf  ./${OUTPUT}
mkdir  ./${OUTPUT}

combine_tessdata -e $TRAINNED_DATA \
$TESSDATA_DIR/${MODEL}.lstm

lstmtraining \
--model_output ./${OUTPUT}/${OUTPUT} \
--traineddata ./${OUTPUT}/${MODEL}/${MODEL}.traineddata \
--continue_from $TESSDATA_DIR/${MODEL}.lstm \
--old_traineddata $TRAINNED_DATA \
--train_listfile ./${OUTPUT}/${MODEL}.training_files.txt \
--debug_interval 0 \
--max_iterations 2000


# best model from checkpoint
lstmtraining \
--stop_training \
--traineddata ./${OUTPUT}/${MODEL}/${MODEL}.traineddata \
--continue_from ./${OUTPUT}/${OUTPUT}_checkpoint \
--model_output ./${OUTPUT}/${OUTPUT}.traineddata


# fast model from checkpoint
lstmtraining \
--stop_training \
--convert_to_int \
--traineddata ./${OUTPUT}/${MODEL}/${MODEL}.traineddata \
--continue_from ./${OUTPUT}/${OUTPUT}_checkpoint \
--model_output ./${OUTPUT}/${OUTPUT}_int.traineddata


