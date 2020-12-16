docker container rm test_sshd -f
docker image prune -f
docker image rmi 12213-domain-home-in-image-wdt -f
./build-archive.sh

###
###
####rm -rf keys/*
####cp /home/oracle/.ssh/authorized_keys keys/.
####ssh-keygen -t rsa -f keys/wls_rsa -q -P ""
####cd keys
####cp authorized_keys authorized_keys-bck
####cat wls_rsa.pub >> authorized_keys

cd /home/oracle/WLS_deploy_scripts/source-12213-domain



##       --no-cache=true \
docker build \
      --build-arg CUSTOM_ADMIN_PORT=7001 \
      --build-arg CUSTOM_MANAGED_SERVER_PORT=8001 \
      --build-arg WDT_MODEL=simple-topology.yaml \
      --build-arg WDT_ARCHIVE=archive.zip \
      --build-arg WDT_VARIABLE=properties/docker-build/domain.properties \
      --force-rm=true \
      -t 12213-domain-home-in-image-wdt .
