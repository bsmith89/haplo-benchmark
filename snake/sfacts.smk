use rule start_jupyter as start_jupyter_sfacts with:
    conda: 'conda/sfacts.yaml'


use rule start_ipython as start_ipython_sfacts with:
    conda: 'conda/sfacts.yaml'


use rule start_shell as start_shell_sfacts with:
    conda: 'conda/sfacts.yaml'



rule simulate_from_model_no_missing:
    output:
        "data/sfacts_simulate-model_{model_name}-n{n}-g{g}-s{s}-rho{rho_hyper}-pi{pi_hyper}-mu{mu_hyper_mean}-eps{epsilon_hyper_mode}-alpha{alpha_hyper_mean}-seed{seed}.world.nc"
    wildcard_constraints:
        seed='[0-9]+',
        alpha_hyper_mean='[0-9]+',
    params:
        seed=lambda w: int(w.seed),
        n=lambda w: int(w.n),
        g=lambda w: int(w.g),
        s=lambda w: int(w.s),
        rho_hyper=lambda w: float(w.rho_hyper) / 10,
        pi_hyper=lambda w: float(w.pi_hyper) / 100,
        epsilon_hyper_mode=lambda w: float(w.epsilon_hyper_mode) / 1000,
        alpha_hyper_mean=lambda w: float(w.alpha_hyper_mean),
        mu_hyper_mean=lambda w: float(w.mu_hyper_mean) / 10,
    conda: 'conda/sfacts.yaml'
    shell:
        dd(
            r"""
        rm -rf {output}
        python3 -m sfacts simulate \
                --model-structure {wildcards.model_name} \
                -n {params.n} -g {params.g} -s {params.s} \
                --hyperparameters gamma_hyper=1e-1 \
                --hyperparameters rho_hyper={params.rho_hyper} pi_hyper={params.pi_hyper} \
                --hyperparameters epsilon_hyper_mode={params.epsilon_hyper_mode} epsilon_hyper_spread=1e3 \
                --hyperparameters alpha_hyper_mean={params.alpha_hyper_mean} alpha_hyper_scale=1e-5 \
                --hyperparameters mu_hyper_mean={params.mu_hyper_mean} mu_hyper_scale=1e-5 \
                --hyperparameters m_hyper_r_mean=10. m_hyper_r_scale=1e-5 \
                --seed {params.seed} \
                --outpath {output}
        """
        )


rule extract_and_portion_metagenotype_tsv:
    output:
        "{stem}.metagenotype-n{n}-g{g}.tsv",
    wildcard_constraints:
        n='[0-9]+',
        g='[0-9]+',
    input:
        script="scripts/extract_metagenotype_to_tsv.py",
        world="{stem}.world.nc",
    params:
        num_samples=lambda w: int(w.n),
        num_positions=lambda w: int(w.g),
    conda: 'conda/sfacts.yaml'
    shell:
        """
        {input.script} {input.world} {params.num_samples} {params.num_positions} > {output}
        """

rule fit_sfacts_strategy1:
    output: "{stem}.metagenotype-n{n}-g{g}.fit-sfacts1-s{nstrain}-seed{seed}.world.nc"
    input:
        data="{stem}.metagenotype-n{n}-g{g}.tsv",
    params:
        device={0: 'cpu', 1: 'cuda'}[config['USE_CUDA']],
        nstrain=lambda w: int(w.nstrain),
        gamma_hyper=1e-3,
        rho_hyper=0.2,
        pi_hyper=0.5,
        learning_rate=1e-2,
        # cull=1e-4,
        # collapse=0.02,
        seed = lambda w: int(w.seed)
    benchmark:
        "{stem}.metagenotype-n{n}-g{g}.fit-sfacts1-s{nstrain}-seed{seed}.benchmark"
    conda: 'conda/sfacts.yaml'
    shell:
        """
        python3 -m sfacts simple_fit -m simple  \
                --verbose --device {params.device} \
                --inpath {input.data} \
                --hyperparameters gamma_hyper={params.gamma_hyper} pi_hyper={params.pi_hyper} rho_hyper={params.rho_hyper} \
                --optimizer-learning-rate {params.learning_rate} \
                -s {params.nstrain} \
                --random-seed {params.seed} \
                --outpath {output}

        """


# use rule simple_fit_sfacts_1 as sim_fit_sfacts_2 with:
#     output:
#         "{stem}.sfacts_fit2.world.nc",
#     params:
#         seed=0,
#         device={0: 'cpu', 1: 'cuda'}[config['USE_CUDA']],
#         num_strains=50,
#         gamma_hyper=1e-3,
#         rho_hyper=0.3,
#         pi_hyper=0.5,
#         learning_rate=1e-2,


rule build_world_from_tsv:
    output: '{stem}.fit-{params}.world.nc'
    input:
        script='scripts/sfacts_world_from_flatfiles.py',
        gamma='{stem}.fit-{params}.gamma.tsv',
        pi='{stem}.fit-{params}.pi.tsv',
        mgen='{stem}.tsv'
    conda: 'conda/sfacts.yaml'
    shell: "{input.script} {input.mgen} {input.gamma} {input.pi} {output}"
