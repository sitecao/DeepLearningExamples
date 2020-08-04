#/bin/bash


/shared/conda/bin/herringrun \
    	/shared/conda/bin/python run_pretraining.py \
	--input_files_dir=/shared/data_bert_tf/phase1/training \
	--eval_files_dir=/shared/data_bert_tf/phase1/test \
	--output_dir=/shared/checkpoints/phase_1 \
	--bert_config_file=/shared/data_bert_tf/vocab/uncased_L-24_H-1024_A-16/bert_config.json \
	--do_train=True \
	--do_eval=True \
	--train_batch_size=64 \
	--eval_batch_size=8 \
	--max_seq_length=128 \
	--max_predictions_per_seq=20 \
	--num_train_steps=1000 \
	--num_accumulation_steps=1 \
	--num_warmup_steps=2800 \
	--save_checkpoints_steps=7820 \
	--learning_rate=0.390625e-5 \
	--herring \
	--manual_fp16 \
	--amp=false \
	--use_xla \
	--allreduce_post_accumulation=True \
	--dllog_path=/shared/bert_logs.json
