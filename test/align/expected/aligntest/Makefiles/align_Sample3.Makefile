.DELETE_ON_ERROR:

GOTCLOUD_ROOT = gotcloud
OUT_DIR = aligntest

all: $(OUT_DIR)/Sample3.OK

$(OUT_DIR)/Sample3.OK: $(FINAL_BAM_DIR)/Sample3.recal.bam.done $(QC_DIR)/Sample3.genoCheck.done $(QC_DIR)/Sample3.qplot.done
	rm -f $(SAI_FILES) $(ALN_FILES) $(POL_FILES) $(DEDUP_FILES) $(RECAL_FILES)
	touch $@

$(QC_DIR)/Sample3.genoCheck.done: $(FINAL_BAM_DIR)/Sample3.recal.bam.done
	mkdir -p $(@D)
	@echo "$(VERIFY_BAM_ID_EXE) --verbose --vcf $(HM3_VCF) --bam $(basename $^) --out $(basename $@)  2> $(basename $@).log"
	@$(VERIFY_BAM_ID_EXE) --verbose --vcf $(HM3_VCF) --bam $(basename $^) --out $(basename $@)  2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed VerifyBamID step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(QC_DIR)/Sample3.qplot.done: $(FINAL_BAM_DIR)/Sample3.recal.bam.done
	mkdir -p $(@D)
	@echo "$(QPLOT_EXE) --reference $(REF) --dbsnp $(DBSNP_VCF) --gccontent $(REF).GCcontent --stats $(basename $@).stats --Rcode $(basename $@).R --minMapQuality 0 --bamlabel Sample3_recal,Sample3_dedup $(basename $^) $(DEDUP_TMP)/Sample3.dedup.bam 2> $(basename $@).log"
	@$(QPLOT_EXE) --reference $(REF) --dbsnp $(DBSNP_VCF) --gccontent $(REF).GCcontent --stats $(basename $@).stats --Rcode $(basename $@).R --minMapQuality 0 --bamlabel Sample3_recal,Sample3_dedup $(basename $^) $(DEDUP_TMP)/Sample3.dedup.bam 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed QPLOT step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(FINAL_BAM_DIR)/Sample3.recal.bam.done: $(DEDUP_TMP)/Sample3.dedup.bam.done
	mkdir -p $(@D)
	mkdir -p $(RECAL_TMP)
	@echo "$(BAM_EXE) recab --refFile $(REF) --dbsnp $(DBSNP_VCF) --storeQualTag OQ --in $(basename $^) --out $(RECAL_TMP)/Sample3.recal.bam $(MORE_RECAB_PARAMS) 2> $(basename $@).log"
	@$(BAM_EXE) recab --refFile $(REF) --dbsnp $(DBSNP_VCF) --storeQualTag OQ --in $(basename $^) --out $(RECAL_TMP)/Sample3.recal.bam $(MORE_RECAB_PARAMS) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed Recalibration step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	cp $(RECAL_TMP)/Sample3.recal.bam $(basename $@)
	$(SAMTOOLS_EXE) index $(basename $@)
	touch $@

$(DEDUP_TMP)/Sample3.dedup.bam.done: $(MERGE_TMP)/Sample3.merged.bam.done
	mkdir -p $(@D)
	@echo "$(BAM_EXE) dedup --in $(basename $^) --out $(basename $@) --log $(basename $@).metrics 2> $(basename $@).err"
	@$(BAM_EXE) dedup --in $(basename $^) --out $(basename $@) --log $(basename $@).metrics 2> $(basename $@).err || (echo "`grep -i -e abort -e error -e failed $(basename $@).err`" >&2; echo "\nFailed Deduping step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).err $(OUT_DIR)/failLogs/$(notdir $(basename $@).err); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).err) for more details" >&2; exit 1;)
	rm -f $(basename $@).err
	touch $@

$(MERGE_TMP)/Sample3.merged.bam.done: $(POL_TMP)/fastq/Sample_3/File1_R1.bam.done 
	mkdir -p $(@D)
	@echo "ln $(basename $^) $(basename $@)"
	@ln $(basename $^) $(basename $@) || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed MergingBams step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(POL_TMP)/fastq/Sample_1/File1_R1.bam.done: $(ALN_TMP)/fastq/Sample_1/File1_R1.bam.done
	mkdir -p $(@D)
	@echo "$(BAM_EXE) polishBam -f $(REF) --AS $(AS) --UR file:$(REF) --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log"
	@$(BAM_EXE) polishBam -f $(REF) --AS $(AS) --UR file:$(REF) --checkSQ -i $(basename $^) -o $(basename $@) -l $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed polishBam step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(ALN_TMP)/fastq/Sample_1/File1_R1.bam.done: $(SAI_TMP)/fastq/Sample_1/File1_R1.sai.done $(SAI_TMP)/fastq/Sample_1/File1_R2.sai.done
	mkdir -p $(@D)
	($(BWA_EXE) sampe -r "@RG	ID:RGID1	SM:SampleID1	LB:Lib1	CN:UM	PL:ILLUMINA" $(REF) $(basename $^) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R1.fastq.gz /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R2.fastq.gz | $(SAMTOOLS_EXE) view -uhS - | $(SAMTOOLS_EXE) sort -m $(BWA_MAX_MEM) - $(basename $(basename $@))) 2> $(basename $(basename $@)).sampe.log
	@echo "(grep -q -v -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log || exit 1)"
	@(grep -q -v -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log || exit 1) || (echo "`grep -i -e abort -e error -e failed $(basename $(basename $@)).sampe.log`" >&2; echo "\nFailed sampe step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $(basename $@)).sampe.log $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $(basename $@)).sampe.log) for more details" >&2; exit 1;)
	rm -f $(basename $(basename $@)).sampe.log
	touch $@

$(SAI_TMP)/fastq/Sample_1/File1_R1.sai.done:
	mkdir -p $(@D)
	@echo "$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R1.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

$(SAI_TMP)/fastq/Sample_1/File1_R2.sai.done:
	mkdir -p $(@D)
	@echo "$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log"
	@$(BWA_EXE) aln $(BWA_QUAL) $(BWA_THREADS) $(REF) /home/mktrost/gotcloud/test/align/fastq/Sample_1/File1_R2.fastq.gz -f $(basename $@) 2> $(basename $@).log || (echo "`grep -i -e abort -e error -e failed $(basename $@).log`" >&2; echo "\nFailed aln step" >&2; mkdir -p $(OUT_DIR)/failLogs; cp $(basename $@).log $(OUT_DIR)/failLogs/$(notdir $(basename $@).log); echo "See $(OUT_DIR)/failLogs/$(notdir $(basename $@).log) for more details" >&2; exit 1;)
	rm -f $(basename $@).log
	touch $@

SAI_FILES = $(SAI_TMP)/fastq/Sample_1/File1_R1.sai $(SAI_TMP)/fastq/Sample_1/File1_R2.sai 

ALN_FILES = $(ALN_TMP)/fastq/Sample_1/File1_R1.bam 

POL_FILES = $(POL_TMP)/fastq/Sample_1/File1_R1.bam 

DEDUP_FILES = $(DEDUP_TMP)/Sample3.dedup.bam 

RECAL_FILES = $(RECAL_TMP)/Sample3.recal.bam 