if [ "$TRAVIS_BRANCH" = "master" ]; then
  wget http://go-cli.s3-website-us-east-1.amazonaws.com/releases/latest/cf-cli_amd64.deb -qO temp.deb && sudo dpkg -i temp.deb
  rm temp.deb

  cd ./devDist

  cf api https://api.uswest.appfog.ctl.io
  cf login --u $APPFOG_USERNAME --p $APPFOG_PASSWORD --o "uiux" --s "dev"
  cf push "cyclops-dev"
  cf logout
else
  echo "we only deploy the master branch"
fi
