export BUILD_BRANCH="builder"
export PUBLISH_BRANCH="master"
export REPO=giorgiomaccari/seqFP
export PUBLISH_REPO=giorgiomaccari/seqFP-wheels
export wheeldir=wheelhouse_py${TRAVIS_PYTHON_VERSION}_${TRAVIS_OS_NAME}


if [ "$TRAVIS_REPO_SLUG" == $REPO ] && [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == ${BUILD_BRANCH} ]; then

    echo "Pushing to ${PUBLISH_BRANCH} on ${PUBLISH_REPO}."

    git config --global user.email "giorgio.maccari@gmail.com"
    git config --global user.name "giorgiomaccari"
    git clone --quiet --branch=${PUBLISH_BRANCH}  https://${GH_TOKEN}@github.com/${PUBLISH_REPO} seqFP-wheels > /dev/null

    cd seqFP-wheels

    mkdir -p ${wheeldir}
    cp -Rf ${wheelhouse}/*.whl ./${wheeldir}/
    git status
    git add ${wheeldir} ${wheeldir}/*.whl
    git commit -m "Latest wheels build by travis-ci."
    git status
    git pull --rebase
    git push origin ${PUBLISH_BRANCH} > /dev/null
else
    echo "Not pushing to ${PUBLISH_BRANCH}. In PR: ${TRAVIS_PULL_REQUEST}; Branch: ${TRAVIS_BRANCH};"
fi
