RUN_ENV="-e JAVA_ZIP_LOCATION=https://s3-us-west-2.amazonaws.com/sample-deploy/sample-dcos-0.9.4.zip"
RUN_ENV="$RUN_ENV -e JAVA_RUN_COMMAND=/opt/sample-dcos-0.9.4/bin/sample-dcos"
docker run -t -i  $RUN_ENV  advantageous/run-java-zip:0.1 /opt/install.sh
