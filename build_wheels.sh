mkdir -p ${wheelhouse}

pip wheel --wheel-dir=${wheelhouse} ./seqFP

ls ${wheelhouse}

