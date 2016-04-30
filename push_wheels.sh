export BUILD_BRANCH="builder"
export PUBLISH_BRANCH="wheels"
export REPO=giorgiomaccari/seqFP
export wheeldir=wheelhouse_py${TRAVIS_PYTHON_VERSION}_${TRAVIS_OS_NAME}


if [ "$TRAVIS_REPO_SLUG" == $REPO ] && [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == ${BUILD_BRANCH} ]; then

    echo "Pushing to ${PUBLISH_BRANCH}."

    git config --global user.email "giorgio.maccari@gmail.com"
    git config --global user.name "giorgiomaccari"
    git clone --quiet --branch=${PUBLISH_BRANCH}  https://${GH_TOKEN}@github.com/${REPO} seqFP_wheels > /dev/null

    cd seqFP_wheels

    mkdir -p ${wheeldir}
    cp -Rf ${wheelhouse}/*.whl ./${wheeldir}/
    git status
    git add ${wheeldir} ${wheeldir}/*.whl
    git commit -m "Latest wheels build by travis-ci."
    git status
    git push origin ${PUBLISH_BRANCH} > /dev/null
else
    echo "Not pushing to ${PUBLISH_BRANCH}. In PR: ${TRAVIS_PULL_REQUEST}; Branch: ${TRAVIS_BRANCH};"
fi
