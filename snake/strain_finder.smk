use rule start_jupyter as start_jupyter_sfinder with:
    conda: 'conda/strain_finder.yaml'


use rule start_ipython as start_ipython_sfinder with:
    conda: 'conda/strain_finder.yaml'


use rule start_shell as start_shell_sfinder with:
    conda: 'conda/strain_finder.yaml'


rule metagenotype_tsv_to_strain_finder_aln:
    output:
        cpickle="{stem}.metagenotype-n{n}-g{g}.strain_finder.aln.cpickle",
        indexes='{stem}.metagenotype-n{n}-g{g}.strain_finder.aln.indexes.txt',
    input:
        script="scripts/metagenotype_to_strainfinder_alignment.py",
        data="{stem}.metagenotype-n{n}-g{g}.tsv",
    conda:
        "conda/strain_finder.yaml"
    shell:
        """
        {input.script} {input.data} {output}
        """


rule run_strain_finder:
    output:
        "{stem}.strain_finder_fit-s{nstrain}.em.cpickle",
    input:
        "{stem}.strain_finder.aln.cpickle",
    conda:
        "conda/strain_finder.yaml"
    params:
        nstrain=lambda w: int(w.nstrain)
    shell:
        """
        rm -rf {output}
        include/StrainFinder/StrainFinder.py \
                --force_update --merge_out --msg \
                --aln {input} \
                -N {params.nstrain} \
                --max_reps 1 --dtol 1 --ntol 2 --max_time 1800 --n_keep 5 --converge \
                --em_out {output}
        # TODO: Do I need to add back the other output file flags: '--otu_out' and '--log'?
        """


rule parse_strain_finder_cpickle:
    output:
        pi='{stem}.strain_finder_fit-s{nstrain}.pi.tsv',
        gamma='{stem}.strain_finder_fit-s{nstrain}.gamma.tsv',
    input:
        script="scripts/strainfinder_result_to_flatfiles.py",
        cpickle="{stem}.strain_finder_fit-s{nstrain}.em.cpickle",
        indexes='{stem}.strain_finder.aln.indexes.txt',
    conda:
        "conda/strain_finder.yaml"
    shell:
        """
        {input.script} {input.cpickle} {input.indexes} {output.pi} {output.gamma}
        """
