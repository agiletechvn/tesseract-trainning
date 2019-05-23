#!/bin/bash

#  --fontlist "OCRB" "Arial" \

TESSDATA_DIR=./tessdata_best
# TRAINNED_DATA=$TESSDATA_DIR/digits.traineddata
TRAINNED_DATA=$TESSDATA_DIR/eng.traineddata
TRAINNED_TEXT=./eng.digits.training_text
# TRAINNED_TEXT=./eng.MRZ.training_text

#  rm -rf ./ocrb_eval
#  ./tesstrain.sh \
#    --fonts_dir ./.fonts \
#    --lang eng --linedata_only \
#    --noextract_font_properties \
#    --langdata_dir ./langdata \
#    --tessdata_dir $TESSDATA_DIR \
#    --exposures "0" \
#    --save_box_tiff \
#    --fontlist "OCRB" \
#    --training_text ./eng.MRZ.eval.training_text \
#    --workspace_dir ./tmp \
#    --output_dir ./ocrb_eval
 
 rm -rf ./ocrb
 ./tesstrain.sh \
   --fonts_dir ./.fonts \
   --lang eng --linedata_only \
   --noextract_font_properties \
   --langdata_dir ./langdata \
   --tessdata_dir $TESSDATA_DIR \
   --exposures "0" \
   --save_box_tiff \
   --fontlist "OCRB" \
   --training_text $TRAINNED_TEXT \
   --workspace_dir ./tmp \
   --output_dir ./ocrb
 
#  echo "/n ****** Finetune plus tessdata_best/eng model ***********"
 
 rm -rf  ./ocrb_plus
 mkdir  ./ocrb_plus
 
 combine_tessdata -e $TRAINNED_DATA \
   $TESSDATA_DIR/eng.lstm
  
lstmtraining \
  --model_output ./ocrb_plus/ocrb_plus \
  --traineddata ./ocrb/eng/eng.traineddata \
  --continue_from $TESSDATA_DIR/eng.lstm \
  --old_traineddata $TRAINNED_DATA \
  --train_listfile ./ocrb/eng.training_files.txt \
  --debug_interval 0 \
  --max_iterations 2000


# lstmtraining \
#   --debug_interval 0 \
#   --traineddata ./ocrb/eng/eng.traineddata \  
#   --net_spec '[1,36,0,1 Ct3,3,16 Mp3,3 Lfys48 Lfx96 Lrx96 Lfx256 O1c111]' \
#   --model_output ./ocrb_plus/ocrb_plus \
#   --learning_rate 20e-4 \
#   --train_listfile ./ocrb/eng.training_files.txt \
#   --max_iterations 5000
  
# lstmtraining \
#   --stop_training \
#   --traineddata ./ocrb/eng/eng.traineddata \
#   --continue_from ./ocrb_plus/ocrb_plus_checkpoint \
#   --model_output ./ocrb_plus/ocrb.traineddata
  
# cp ./ocrb_plus/ocrb.traineddata ./
  
# time lstmeval \
#   --model ./ocrb_plus/ocrb.traineddata \
#   --eval_listfile  ./ocrb_eval/eng.training_files.txt 
  
lstmtraining \
  --stop_training \
  --convert_to_int \
  --traineddata ./ocrb/eng/eng.traineddata \
  --continue_from ./ocrb_plus/ocrb_plus_checkpoint \
  --model_output ./ocrb_plus/ocrb_int.traineddata
  
# time lstmeval \
#   --model ./ocrb_plus/ocrb_int.traineddata \
#   --eval_listfile ./ocrb_eval/eng.training_files.txt 

# cp ./ocrb_plus/ocrb_int.traineddata ./


# time lstmeval \
#   --model ./tessdata_best/eng.traineddata \
#   --eval_listfile ./ocrb_eval/eng.training_files.txt 
  