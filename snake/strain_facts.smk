use rule start_jupyter as start_jupyter_sfacts with:
    conda: 'conda/strain_facts.yaml'


use rule start_ipython as start_ipython_sfacts with:
    conda: 'conda/strain_facts.yaml'


use rule start_shell as start_shell_sfacts with:
    conda: 'conda/strain_facts.yaml'


rule extract_metagenotype_tsv:
    output: '{stem}.strain_facts.sim.metagenotype.tsv'
    input:
        script='scripts/extract_metagenotype_to_tsv.py',
        world='{stem}.strain_facts.sim.nc',
    conda: 'conda/strain_facts.yaml'
    shell:
        """
        {input.script} {input.world} > {output}
        """

