workflow variantMetrics {
	File vcf
	File vcf_index
	String joint_sample_name
	String region

	File ref_dict
	File dbsnp_vcf
	File dbsnp_vcf_index

	String docker = "dnastack/picard_samtools:2.18.9"

	call runVariantMetrics {
		input:
			vcf = vcf,
			vcf_index = vcf_index,
			joint_sample_name = joint_sample_name,
			region = region,
			ref_dict = ref_dict,
			dbsnp_vcf = dbsnp_vcf,
			dbsnp_vcf_index = dbsnp_vcf_index,
			docker = docker
	}

	output {
		File summary_metrics_file = runVariantMetrics.summary_metrics_file
		File detail_metrics_file = runVariantMetrics.detail_metrics_file
	}

	meta {
		author: "Heather Ward"
		email: "heather@dnastack.com"
		description: "## MSSNG DB6 Variant Metrics\n\nRun once per VCF file output from step 05 to produce metrics on the final VCF. `region` is a string containing chromosome name (same as step05, e.g. `chr10`).\n\n"
  	}

}

task runVariantMetrics {
	File vcf
	File vcf_index
	String joint_sample_name
	String region

	File ref_dict
	File dbsnp_vcf
	File dbsnp_vcf_index

	String docker
	Int disk_size = ceil((size(vcf, "GB") + size(dbsnp_vcf, "GB")) * 2 + 50)

	command {
	    java -Xmx6g -Xms6g -jar $PICARD \
			CollectVariantCallingMetrics \
			INPUT=${vcf} \
			DBSNP=${dbsnp_vcf} \
			SEQUENCE_DICTIONARY=${ref_dict} \
			OUTPUT=${joint_sample_name}.${region} \
			THREAD_COUNT=2
	}

	output {
    	File summary_metrics_file = "${joint_sample_name}.${region}.variant_calling_summary_metrics"
    	File detail_metrics_file = "${joint_sample_name}.${region}.variant_calling_detail_metrics"
  	}

	runtime {
		docker: docker
		cpu: 2
		memory: "7.5 GB"
		disks: "local-disk " + disk_size + " HDD"
	}
}
