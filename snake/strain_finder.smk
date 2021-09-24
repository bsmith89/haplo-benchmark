use rule start_jupyter as start_jupyter_sfinder with:
    conda: 'conda/strain_finder.yaml'


use rule start_ipython as start_ipython_sfinder with:
    conda: 'conda/strain_finder.yaml'


use rule start_shell as start_shell_sfinder with:
    conda: 'conda/strain_finder.yaml'


rule metagenotype_tsv_to_strain_finder_aln:
    output:
        "{stem}.strain_finder_aln.cpickle",
    input:
        script="scripts/metagenotype_to_strainfinder_alignment.py",
        data="{stem}.metagenotype.tsv",
    conda:
        "conda/strain_finder.yaml"
    shell:
        """
        python2 {input.script} {input.data} {output}
        """


rule run_strain_finder:
    output:
        "{stem}.strain_finder_result.cpickle",
    input:
        "{stem}.strain_finder_aln.cpickle",
    conda:
        "conda/strain_finder.yaml"
    shell:
        """
        python2 include/StrainFinder/StrainFinder.py \
                --force_update --merge_out --msg \
                --aln {input} \
                -N 5 \
                --max_reps 10 --dtol 1 --ntol 2 --max_time 3600 --n_keep 3 --converge \
                --em_out {output}
        # TODO: Do I need to add back the other output file flags: '--otu_out' and '--log'?
        """


rule parse_strain_finder_cpickle:
    output:
        "{stem}.strain_finder_result.flag",
    input:
        script="scripts/parse_strain_finder_output.py",
        cpickle="{stem}.strain_finder_result.cpickle",
    conda:
        "conda/strain_finder.yaml"
    shell:
        """
        python2 {input.script} {input.cpickle} {output}
        """
