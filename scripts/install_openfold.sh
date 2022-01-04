#!/bin/bash

source scripts/vars.sh

conda create --name $ENV_NAME -y python==3.7 \
    openmm=7.5.1 pdbfixer -c conda-forge
source activate $ENV_NAME
pip install -r requirements.txt
conda install -y -c bioconda kalign2==2.04

pip install nvidia-pyindex
pip install nvidia-dllogger

OPENFOLD_DIR=$PWD
pushd $HOME/conda/envs/$ENV_NAME/lib/python3.7/site-packages/ \
    && patch -p0 < $OPENFOLD_DIR/lib/openmm.patch \
    && popd

# Download folding resources
wget -q -P openfold/resources \
    https://git.scicore.unibas.ch/schwede/openstructure/-/raw/7102c63615b64735c4941278d92b554ec94415f8/modules/mol/alg/src/stereo_chemical_props.txt

# Certain tests need access to this file
mkdir -p tests/test_data/alphafold/common
ln -rs openfold/resources/stereo_chemical_props.txt tests/test_data/alphafold/common
ln -sf ~/db/AlphaFold/params openfold/resources/params


# Decompress test data
gunzip tests/test_data/sample_feats.pickle.gz
