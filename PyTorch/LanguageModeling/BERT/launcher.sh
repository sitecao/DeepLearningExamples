herringrun -x FI_PROVIDER=efa \
-x LD_LIBRARY_PATH=/shared/conda/lib:/opt/amazon/efa/lib:/opt/amazon/openmpi/lib \
-x NCCL_DEBUG=INFO -x OMP_NUM_THREADS=2 python /shared/BERT/run_pretraining.py \
--input_dir=/shared/bert/phase1 --output_dir=/shared/BERT/checkpt909 \
--config_file=/shared/BERT/bert_config.json \
--bert_model=bert-large-uncased --train_batch_size=64 --max_seq_length=128 \
--max_predictions_per_seq=20 --max_steps=500 \
--warmup_proportion=0.2843 \
--log_freq=10 \
--num_steps_per_checkpoint=900864 --learning_rate=1.12e-3 --seed=42 \
--fp16 --do_train --json-summary /shared/BERT/results/dllogger.json

