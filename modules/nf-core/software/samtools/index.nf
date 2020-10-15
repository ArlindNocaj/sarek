include { initOptions; saveFiles; getSoftwareName } from './../functions'

params.options = [:]
def options    = initOptions(params.options)

environment = params.enable_conda ? "bioconda::samtools=1.10" : null
container = "quay.io/biocontainers/samtools:1.10--h2e538c0_3"
if (workflow.containerEngine == 'singularity' && !params.pull_docker_container) container = "https://depot.galaxyproject.org/singularity/samtools:1.10--h2e538c0_3"

process SAMTOOLS_INDEX {
   label 'cpus_8'

    tag "${meta.id}"

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: { filename ->
                    if (options.publish_results == "none") null
                    else if (filename.endsWith('.version.txt')) null
                    else "${options.publish_dir_up}/${meta.sample}/${options.publish_dir_down}/${filename}" }

    conda environment
    container container

    input:
        tuple val(meta), path(bam)

    output:
        tuple val(meta), path("${name}.bam"), path("*.bai")

    script:
    name = options.suffix ? "${meta.id}.${options.suffix}" : "${meta.id}"
    """
    [ ! -f  ${name}.bam ] && ln -s ${bam} ${name}.bam

    samtools index ${name}.bam
    """
}