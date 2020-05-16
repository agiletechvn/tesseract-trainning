#!/bin/bash

while getopts "m:o:f:i:" opt; do
  case "$opt" in
    m)  MODEL=$OPTARG
    ;;
    o)  OUTPUT=$OPTARG
    ;;   
    f)  FONT=$OPTARG
    ;;
    i)  ITER=$OPTARG
    ;;
  esac
done

: ${MODEL:="eng"}
: ${OUTPUT:="date"}
: ${FONT:="Arial"}
: ${ITER:=1000}

TESSDATA_DIR=./tessdata_best
TRAINNED_DATA=$TESSDATA_DIR/${MODEL}.traineddata
TRAINNED_TEXT=./${MODEL}.$OUTPUT.training_text
MODEL_OUTPUT_DIR=./output/${OUTPUT}_plus


echo "/n ****** Finetune plus tessdata_best/${MODEL} model ${FONT} ***********"

# step 1
node generate_training_text.js -t $OUTPUT
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


# step 2
rm -rf  ${MODEL_OUTPUT_DIR}
mkdir  ${MODEL_OUTPUT_DIR}

combine_tessdata -e $TRAINNED_DATA \
$TESSDATA_DIR/${MODEL}.lstm

# step 3
lstmtraining \
--model_output ${MODEL_OUTPUT_DIR}/${OUTPUT}_plus \
--traineddata ./${OUTPUT}/${MODEL}/${MODEL}.traineddata \
--continue_from $TESSDATA_DIR/${MODEL}.lstm \
--old_traineddata $TRAINNED_DATA \
--train_listfile ./${OUTPUT}/${MODEL}.training_files.txt \
--debug_interval 0 \
--max_iterations $ITER


# step 4
# best model from checkpoint
lstmtraining \
--stop_training \
--traineddata ./${OUTPUT}/${MODEL}/${MODEL}.traineddata \
--continue_from ${MODEL_OUTPUT_DIR}/${OUTPUT}_plus_checkpoint \
--model_output ${MODEL_OUTPUT_DIR}/${OUTPUT}.traineddata

# step 5
# fast model from checkpoint
lstmtraining \
--stop_training \
--convert_to_int \
--traineddata ./${OUTPUT}/${MODEL}/${MODEL}.traineddata \
--continue_from ${MODEL_OUTPUT_DIR}/${OUTPUT}_plus_checkpoint \
--model_output ${MODEL_OUTPUT_DIR}/${OUTPUT}_int.traineddata


