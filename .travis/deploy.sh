if [ "$TRAVIS_BRANCH" = "master" ]; then
  cd ./devDist

  ../.travis/cf api https://api.uswest.appfog.ctl.io
  ../.travis/cf login --u $APPFOG_USERNAME --p $APPFOG_PASSWORD --o "uiux" --s "dev"
  ../.travis/cf push "cyclops-dev" -b https://github.com/cloudfoundry/staticfile-buildpack.git
  ../.travis/cf logout
else
  echo "we only deploy the master branch"
fi
