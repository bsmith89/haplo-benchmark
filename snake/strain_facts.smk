use rule start_jupyter as start_jupyter_sfacts with:
    conda: 'conda/strain_facts.yaml'


use rule start_ipython as start_ipython_sfacts with:
    conda: 'conda/strain_facts.yaml'


use rule start_shell as start_shell_sfacts with:
    conda: 'conda/strain_facts.yaml'



rule simulate_from_model:
    output:
        "data/{model_name}.{dims}.{diversity}.{fidelity}.{missing}.seed-{seed}.strain_facts.sim.nc",
    input:
        dims_params="meta/params/{dims}.txt",
        diversity_params="meta/params/{diversity}.txt",
        fidelity="meta/params/{fidelity}.txt",
        missing="meta/params/{missing}.txt",
    params:
        model_name=lambda w: w.model_name,
        seed=lambda w: int(w.seed),
    conda:
        "conda/strain_facts.yaml"
    shell:
        dd(
            """
        rm -rf {output}
        python3 -m sfacts simulate \
                --seed {params.seed} \
                --model-structure {params.model_name} \
                @{input.dims_params} \
                @{input.diversity_params} \
                @{input.fidelity} \
                @{input.missing} \
                --outpath {output}
        """
        )


rule extract_metagenotype_tsv:
    output:
        "{stem}.strain_facts.sim.metagenotype.tsv",
    input:
        script="scripts/extract_metagenotype_to_tsv.py",
        world="{stem}.strain_facts.sim.nc",
    conda:
        "conda/strain_facts.yaml"
    shell:
        """
        {input.script} {input.world} > {output}
        """

rule simple_fit_strain_facts:
    output: "{stem}.strain_facts.fit.nc"
    input:
        data="{stem}.metagenotype.tsv",
        params="meta/params/default_fit_params.txt",
    params:
        seed=0,
    conda: "conda/strain_facts.yaml"
    shell:
        """
        python3 -m sfacts simple_fit \
                --inpath {input.data} \
                --outpath {output} \
                --random-seed {params.seed} \
                --verbose \
                @{input.params}

        """
                # --collapse 0.05 --cull 0.01 \

