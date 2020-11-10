./clean.sh
####rm -rf keys/*
####cp -R ../source-12213-domain/keys/* keys/
####ls -la keys/

docker image prune -f
docker build \
      -t 12214-domain .
	  
###
###
#### docker run -d -P --name test_sshd_target 12214-domain:latest
#### export DOCKER_PORT=`docker port test_sshd_target 22`
#### export DOCKER_PORT=`echo $DOCKER_PORT | sed 's/0.0.0.0://g' 
#### echo $DOCKER_PORT
#### ssh -i ~/.ssh/priv.txt  -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"  oracle@localhost -p $DOCKER_PORT
####### docker container stop test_sshd_target
####### docker container rm test_sshd_target      
