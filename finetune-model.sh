#!/bin/bash

fn=0
FONTS=""
# use "${FONTS[@]}" to pass array param

while getopts "m:o:f:i:" opt; do  
  case "$opt" in
    m)  MODEL=$OPTARG
    ;;
    o)  OUTPUT=$OPTARG
    ;;   
    f)  FONTS[$fn]="$OPTARG"
        fn=$((fn+1))                    
    ;;
    i)  ITER=$OPTARG
    ;;
  esac
done

: ${MODEL:="eng"}
: ${OUTPUT:="date"}
: ${FONTS:=("Arial")}
: ${ITER:=1000}

TESSDATA_DIR=./tessdata_best
TRAINNED_DATA=$TESSDATA_DIR/${MODEL}.traineddata
TRAINNED_TEXT=./output/${MODEL}.$OUTPUT.training_text
MODEL_OUTPUT_DIR=./output/${OUTPUT}_plus
MODEL_EVAL_DIR=./output/${OUTPUT}
FINE_TUNE_TRAINED_DATA=${MODEL_EVAL_DIR}/${MODEL}/${MODEL}.traineddata

echo "****** Finetune plus tessdata_best/${MODEL} model ${FONTS[@]} ***********"

# step 1
node generate_training_text.js -t $OUTPUT -o $TRAINNED_TEXT
rm -rf $MODEL_EVAL_DIR
./tesstrain.sh \
--fonts_dir ./.fonts \
--lang ${MODEL} --linedata_only \
--noextract_font_properties \
--langdata_dir ./langdata \
--tessdata_dir $TESSDATA_DIR \
--exposures "0" \
--save_box_tiff \
--fontlist "${FONTS[@]}" \
--training_text $TRAINNED_TEXT \
--workspace_dir ./tmp \
--output_dir $MODEL_EVAL_DIR


# step 2
combine_tessdata -e $TRAINNED_DATA \
$TESSDATA_DIR/${MODEL}.lstm

# step 3
rm -rf  ${MODEL_OUTPUT_DIR}
mkdir  ${MODEL_OUTPUT_DIR}
lstmtraining \
--model_output ${MODEL_OUTPUT_DIR}/${OUTPUT}_plus \
--traineddata $FINE_TUNE_TRAINED_DATA \
--continue_from $TESSDATA_DIR/${MODEL}.lstm \
--old_traineddata $TRAINNED_DATA \
--train_listfile ${MODEL_EVAL_DIR}/${MODEL}.training_files.txt \
--debug_interval 0 \
--max_iterations $ITER


# step 4
# best model from checkpoint
lstmtraining \
--stop_training \
--traineddata $FINE_TUNE_TRAINED_DATA \
--continue_from ${MODEL_OUTPUT_DIR}/${OUTPUT}_plus_checkpoint \
--model_output ${MODEL_OUTPUT_DIR}/${OUTPUT}.traineddata

# step 5
# fast model from checkpoint
lstmtraining \
--stop_training \
--convert_to_int \
--traineddata $FINE_TUNE_TRAINED_DATA \
--continue_from ${MODEL_OUTPUT_DIR}/${OUTPUT}_plus_checkpoint \
--model_output ${MODEL_OUTPUT_DIR}/${OUTPUT}_int.traineddata