export BUILD_BRANCH="builder"
export PUBLISH_BRANCH="wheels"
export REPO=giorgiomaccari/seqFP


if [ "$TRAVIS_REPO_SLUG" == $REPO ] && [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == ${BUILD_BRANCH} ]; then

    echo "Pushing to ${PUBLISH_BRANCH}."

    git config --global user.email "giorgio.maccari@gmail.com"
    git config --global user.name "giorgiomaccari"
    git clone --quiet --branch=${PUBLISH_BRANCH}  https://github.com/giorgiomaccari/seqFP.git > /dev/null

    cd seqFP

    mkdir -p wheelhouse
    cp -Rf ${wheelhouse}/*.whl ./wheelhouse/
    git status
    git add wheelhouse wheelhouse/*.whl
    git commit -m "Latest wheels build by travis-ci."
    git status
    git push origin ${PUBLISH_BRANCH} > /dev/null
else
    echo "Not pushing to ${PUBLISH_BRANCH}. In PR: ${TRAVIS_PULL_REQUEST}; Branch: ${TRAVIS_BRANCH};"
fi
