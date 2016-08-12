## Overview
If you set two environment variables, `JAVA_ZIP_LOCATION` and `JAVA_RUN_COMMAND`
this image will download the zip file at `JAVA_ZIP_LOCATION` and then run the command
`JAVA_RUN_COMMAND`. This allows us to reuse the same image for many services built
with gradle.

Location `JAVA_ZIP_LOCATION` is a URL (S3 or Artifactory) to a zip file.
`JAVA_ZIP_LOCATION` URL is expected to be set to an Java zip file
built with gradle `distZip`.

The `JAVA_RUN_COMMAND` environment variable sets the command to run after unzipping.

#### JAVA_RUN_COMMAND
```
JAVA_RUN_COMMAND=/opt/sample-dcos-0.9.4/bin/sample-dcos
```

The image uses a simple install.sh.

#### install.sh
```
cd opt
wget $JAVA_ZIP_LOCATION
unzip *.zip
$JAVA_RUN_COMMAND
```

## Usage
To run this docker container run it with `JAVA_RUN_COMMAND` and `JAVA_ZIP_LOCATION`
set as follows:

## Usage DOCKER
#### Running a Java dist from Docker
```
RUN_ENV="-e JAVA_ZIP_LOCATION=https://s3-us-west-2.amazonaws.com/sample-deploy/sample-dcos-0.9.4.zip"
RUN_ENV="$RUN_ENV -e JAVA_RUN_COMMAND=/opt/sample-dcos-0.9.4/bin/sample-dcos"
docker run -t -i  $RUN_ENV  advantageous/run-java-zip:0.1 /opt/install.sh
```


## Usage DC/OS Mesosphere
#### To run this app in DC/OS or Mesosphere
```
dcos marathon app add mesos-deploy.json
```

#### mesos-deploy.json
```javascript
{
  "acceptedResourceRoles": [
    "slave_public"
  ],
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "advantageous/run-java-zip:0.1",
      "network": "BRIDGE",
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 0,
          "servicePort": 0,
          "protocol": "tcp"
        },
        {
          "containerPort": 9090,
          "hostPort": 0,
          "protocol": "tcp"
        }
      ]
    }
  },
  "cmd": "/opt/install.sh",
  "cpus": 0.5,
  "env": {
    "DEPLOYMENT_ENVIRONMENT": "staging",
    "JAVA_ZIP_LOCATION": "https://s3-us-west-2.amazonaws.com/sample-deploy/sample-dcos-0.9.4.zip",
    "JAVA_RUN_COMMAND": "/opt/sample-dcos-0.9.4/bin/sample-dcos"
  },
  "healthChecks": [
    {
      "gracePeriodSeconds": 30,
      "intervalSeconds": 20,
      "maxConsecutiveFailures": 3,
      "path": "/__admin/ok",
      "portIndex": 1,
      "protocol": "HTTP"
    }
  ],
  "id": "sample-dcos2",
  "instances": 1,
  "mem": 1024,
  "portDefinitions": [
    {
      "name": "eventbus",
      "port": 0,
      "protocol": "tcp"
    },
    {
      "name": "admin",
      "port": 0,
      "protocol": "tcp"
    }
  ],
  "upgradeStrategy": {
    "minimumHealthCapacity": 0
  }
}
```

Check to see if it is running.

```sh
$ dcos marathon app list
/sample-dcos2          1024  0.5    1/1    0/1      scale       DOCKER   /opt/install.sh
```

Find the IP address of the server that our app is running on.

```sh
$ dcos task
NAME                  HOST          USER  STATE  ID                                                         
sample-dcos2          10.16.205.15  root    R    sample-dcos2.3df2501f-60bb-11e6-8de6-ea046373ee46   
```

## Development notes
We use packer for this project.

#### Packer provision script for this project java-run-docker.json
```javascript
{
  "builders":
  [
    {
      "type": "docker",
      "image": "openjdk:8u102-jdk",
      "commit": true
    }
  ],
  "provisioners": [
    {
      "type" : "file",
      "source": "./install.sh",
      "destination": "/opt/install.sh"
    },
    {
      "type" : "shell",
      "inline" : [
        "chmod +x /opt/install.sh"
      ]
    }
  ],
  "post-processors": [
    [
      {
        "type": "docker-tag",
        "repository": "advantageous/run-java-zip",
        "tag": "0.1"
      },
      {
        "type": "docker-tag",
        "repository": "advantageous/run-java-zip",
        "tag": "latest"
      },
      "docker-push"
    ]
  ]

}
```

To build an image we run this.

#### Running packer
```
 packer build java-run-docker.json
```
