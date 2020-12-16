################################################################################
###  DOckerfile for the source Docker image used to demonstrate the migration
###
#Copyright (c) 2018, 2019 Oracle and/or its affiliates. All rights reserved.
#
#Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This Dockerfile extends the Oracle WebLogic image by creating a sample domain.
#
# Util scripts are copied into the image enabling users to plug NodeManager
# automatically into the AdminServer running on another container.
#
# PREREQUISITES:
# --------------
# This sample requires that a Java JDK 1.8 or greater version must be installed on the machine
# running the docker build command, and that the JAVA_HOME environment variable is set to the java home
# location. The sample unzips the weblogic-deploy.zip into the image using the java jar command.
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Build the deployment archive file using the build-archive.sh script.
#      $ ./build-archive.sh
#
# Run:
#      $ sudo docker build \
#            --build-arg CUSTOM_ADMIN_HOST=wlsadmin \
#            --build-arg CUSTOM_ADMIN_PORT=7001 \
#            --build-arg CUSTOM_ADMIN_NAME=7001 \
#            --build-arg CUSTOM_MANAGED_SERVER_PORT=8001 \
#            --build-arg CUSTOM_DOMAIN_NAME=base_domain \
#            --build-arg CUSTOM_DEBUG_PORT=8453 \
#            --build-arg WDT_MODEL=simple-topology.yaml \
#            --build-arg WDT_ARCHIVE=archive.zip \
#            --build-arg WDT_VARIABLE=properties/docker-build/domain.properties \
#            --force-rm=true \
#            --no-cache=true \
#            -t 12213-domain-home-in-image-wdt .
#
# If the ADMIN_HOST, ADMIN_PORT, MS_PORT, DOMAIN_NAME are not provided, the variables 
# are set to default values. (The values shown in the build statement). 
#
# You must insure that the build arguments align with the values in the model. 
# The sample model replaces the attributes with tokens that are resolved from values in the
# corresponding property file domain.properties. The container-scripts/setEnv.sh script
# demonstrates parsing the variable file to build a string of --build-args that can
# be passed on the docker build command.
#
# Pull base image
# ---------------
# FROM store/oracle/weblogic:12.2.1.3
FROM store/oracle/weblogic:12.2.1.3
######FROM store/oracle/weblogic:12.2.1.3-dev

# Maintainer
# ----------
MAINTAINER Eugene Simos  <eugene.simos@oracle.com>

ARG WDT_ARCHIVE
ARG WDT_VARIABLE
ARG WDT_MODEL
ARG CUSTOM_ADMIN_NAME=admin-server
ARG CUSTOM_ADMIN_HOST=wlsadmin
ARG CUSTOM_ADMIN_PORT=7001
ARG CUSTOM_MANAGED_SERVER_PORT=8001
ARG CUSTOM_DOMAIN_NAME=base_domain
ARG CUSTOM_DEBUG_PORT=8453

# Persist arguments - for ports to expose and container to use
# Create a placeholder for the manager server name. This will be provided when run the container
# Weblogic and Domain locations
# The boot.properties will be created under the DOMAIN_HOME when the admin server container is run 
# WDT installation
# ---------------------------
ENV ADMIN_NAME=${CUSTOM_ADMIN_NAME} \
    ADMIN_HOST=${CUSTOM_ADMIN_HOST} \
    ADMIN_PORT=${CUSTOM_ADMIN_PORT} \
    MANAGED_SERVER_NAME=${MANAGED_SERVER_NAME} \
    MANAGED_SERVER_PORT=${CUSTOM_MANAGED_SERVER_PORT} \
    DEBUG_PORT=${CUSTOM_DEBUG_PORT} \
    ORACLE_HOME=/u01/oracle \
    DOMAIN_NAME=${CUSTOM_DOMAIN_NAME} \
    DOMAIN_PARENT=${ORACLE_HOME}/user_projects/domains 

ENV DOMAIN_HOME=${DOMAIN_PARENT}/${DOMAIN_NAME} \
    PROPERTIES_FILE_DIR=$ORACLE_HOME/properties \
    WDT_HOME="/u01" \
    SCRIPT_HOME="${ORACLE_HOME}" \
    PATH=$PATH:${ORACLE_HOME}/oracle_common/common/bin:${ORACLE_HOME}/wlserver/common/bin:${DOMAIN_HOME}:${DOMAIN_HOME}/bin:${ORACLE_HOME}

COPY weblogic-deploy.zip ${WDT_HOME}
COPY container-scripts/* ${SCRIPT_HOME}/

# Create the properties file directory and the domain home parent with the correct permissions / owner. 
# Unzip and install the WDT image and change the permissions / owner.
## https://docs.docker.com/engine/examples/running_ssh_service/
## https://bbs.archlinux.org/viewtopic.php?id=165382
USER root
RUN	yum install -y openssh-server openssh-clients vi sudo shadow-utils sed zip git &&     yum clean all && \
    echo "oracle ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
	echo 'root:Welcome1412#' | chpasswd && \
	echo 'oracle:Welcome1412#' | chpasswd && \
	sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
	sed -i 's/#Banner none/Banner \/home\/oracle\/WLS_deploy_scripts\/welcome_source.txt/g' /etc/ssh/sshd_config && \
	sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd && \
	/usr/bin/ssh-keygen -A

##&& \
##sed s/SELINUX=enforcing/SELINUX=disabled/g -i /etc/selinux/config

##&& systemctl  start sshd && systemctl  enable sshd

USER root
RUN chmod +xw ${SCRIPT_HOME}/*.sh && \ 
    chown -R oracle:root ${SCRIPT_HOME} && \
    mkdir -p +xwr $PROPERTIES_FILE_DIR && \
    chown -R oracle:root $PROPERTIES_FILE_DIR && \
    mkdir -p $DOMAIN_PARENT && \
    chown -R oracle:root $DOMAIN_PARENT && \
    chmod -R a+xwr $DOMAIN_PARENT && \
    cd ${WDT_HOME} && \
    $JAVA_HOME/bin/jar xf weblogic-deploy.zip && \
    rm weblogic-deploy.zip && \
    chmod +xw weblogic-deploy/bin/*.sh && \
    chmod -R +xw weblogic-deploy/lib/python   && \
    chown -R oracle:root weblogic-deploy 

# Persist the WDT tool home location
ENV WDT_HOME=$WDT_HOME/weblogic-deploy 

# Copy the WDT model, archive file, variable file and credential secrets to the property file directory.
# These files will be removed after the image is built.
# Be sure to build with --force-rm to eliminate this container layer

COPY ${WDT_MODEL} ${WDT_ARCHIVE} ${WDT_VARIABLE} properties/docker-build/*.properties ${PROPERTIES_FILE_DIR}/
# --chown for COPY is available in docker version 18 'COPY --chown oracle:root'
RUN chown -R oracle:root ${PROPERTIES_FILE_DIR}
COPY keys/* /home/oracle/.ssh/
RUN  chown -R oracle:root /home/oracle/.ssh && \
     chmod go-rw /home/oracle/.ssh/*
         
# Create the domain home in the docker image.
#
# The create domain tool creates a domain at the DOMAIN_HOME location
# The domain name is set using the value in the model / variable files 
# The domain name can be different from the DOMAIN_HOME domain folder name.
#
# Set WORKDIR for @@PWD@@ global token in model file
WORKDIR $ORACLE_HOME
USER oracle
##COPY ./scripts/discover_domain.sh /home/oracle/migratioh_scripts/discover_domain.sh 
##RUN chown -R oracle:root  /home/oracle/migratioh_scripts && \
##    chmod ugo+w /home/oracle/migratioh_scripts/discover_domain.sh
RUN cd /home/oracle && \
    git clone https://github.com/eugsim1/WLS_deploy_scripts.git && \
	chmod u+x /home/oracle/WLS_deploy_scripts/*.sh && \
	rm -rf WLS_deploy_scripts/source-12213-domain && \
	rm -rf WLS_deploy_scripts/target-12214-domain && \
	rm -rf WLS_deploy_scripts/js && rm -rf WLS_deploy_scripts/images && rm -rf WLS_deploy_scripts/index.html && rm -rf WLS_deploy_scripts/manifest.json && rm -rf WLS_deploy_scripts/welcome_target.txt && rm -rf WLS_deploy_scripts/.gi* && rm -rf WLS_deploy_scripts/READ* && \
    if [ -n "$WDT_MODEL" ]; then MODEL_OPT="-model_file $PROPERTIES_FILE_DIR/${WDT_MODEL##*/}"; fi && \
    if [ -n "$WDT_ARCHIVE" ]; then ARCHIVE_OPT="-archive_file $PROPERTIES_FILE_DIR/${WDT_ARCHIVE##*/}"; fi && \
    if [ -n "$WDT_VARIABLE" ]; then VARIABLE_OPT="-variable_file $PROPERTIES_FILE_DIR/${WDT_VARIABLE##*/}"; fi && \ 
    ${WDT_HOME}/bin/createDomain.sh \
        -oracle_home $ORACLE_HOME \
        -java_home $JAVA_HOME \
        -domain_home $DOMAIN_HOME \
        -domain_type WLS \
        $VARIABLE_OPT  \
        $MODEL_OPT \
        $ARCHIVE_OPT && \
		echo ". $DOMAIN_HOME/bin/setDomainEnv.sh" >> /u01/oracle/.bashrc && \
		echo "export PATH=$WDT_HOME/bin:$PATH" >> /home/oracle/.bashrc && \
		echo "export ORACLE_HOME=/u01/oracle" >> /home//oracle/.bashrc  && \
		echo "export MW_HOME=$ORACLE_HOME" >> /home/oracle/.bashrc && \
		echo "export DOMAIN_HOME=/u01/oracle/user_projects/domains/base_domain" >> /home/oracle/.bashrc && \
		echo "export JAVA_HOME=/u01/jdk" >> /home/oracle/.bashrc  && \
		echo "this is the source server" >> /home/oracle/server.txt
##		&&         rm -rf $PROPERTIES_FILE_DIR 

# Expose admin server, managed server port and domain debug port
EXPOSE $ADMIN_PORT $MANAGED_SERVER_PORT $DEBUG_PORT  22

WORKDIR $DOMAIN_HOME

### start sshd for this server
USER  root
CMD ["/usr/sbin/sshd", "-D"]
# Define default command to start Admin Server in a container.
##CMD ["/u01/oracle/startAdminServer.sh"]

### ### docker run -d -P --name test_sshd 12213-domain-home-in-image-wdt:latest
####### export DOCKER_PORT=`docker port test_sshd 22`
####### export DOCKER_PORT=`echo $DOCKER_PORT | sed 's/0.0.0.0://g' `
####### echo $DOCKER_PORT
####### ssh -i ~/.ssh/priv.txt  -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"  oracle@localhost -p $DOCKER_PORT
#docker container stop test_sshd
#docker container rm test_sshd
