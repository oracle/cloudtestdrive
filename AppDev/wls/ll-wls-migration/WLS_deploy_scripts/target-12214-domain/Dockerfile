################################################################################
###  DOckerfile for the target Docker image used to demonstrate the migration
###
#Copyright (c) 2019, 2020,  Oracle and/or its affiliates.
#
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle WebLogic 12.2.1.3 domain persisted on a Docker volume
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# This Oracle WebLogic domain image extends the Oracle WebLogic 12.2.1.3 developer image, you must first build the Oracle WebLogic 12.2.1.3 binary image.
# Run:
#      $ docker build -f Dockerfile -t 12214-weblogic-domain-in-volume .
#
# IMPORTANT
# ---------
# The resulting image of this Dockerfile contains a WebLogic Domain.
#
# From
# ----
FROM store/oracle/weblogic:12.2.1.4

# Labels
# ------
LABEL "provider"="Oracle"                                               \
      "maintainer"="Eugene Simos <eugene.simos@oracle.com>"       \
      "issues"="https://github.com/oracle/docker-images/issues"         \
      "port.admin.listen"="9001"                                        \
      "port.administration"="11002"                                      \
      "port.managed.server"="10001"                                      

# WLS Configuration
# -----------------
ENV DOMAIN_ROOT="/u01/oracle/user_projects/domains" \
    ADMIN_HOST="${ADMIN_HOST:-AdminContainer}" \
    MANAGED_SERVER_PORT="${MANAGED_SERVER_PORT:-10001}" \
    MANAGED_SERVER_NAME_BASE="${MANAGED_SERVER_NAME_BASE:-MS}" \
    MANAGED_SERVER_CONTAINER="${MANAGED_SERVER_CONTAINER:-false}" \
    CONFIGURED_MANAGED_SERVER_COUNT="${CONFIGURED_MANAGED_SERVER_COUNT:-2}" \
    MANAGED_NAME="${MANAGED_NAME:-MS1}" \
    CLUSTER_NAME="${CLUSTER_NAME:-cluster1}" \
    CLUSTER_TYPE="${CLUSTER_TYPE:-DYNAMIC}" \
    PROPERTIES_FILE_DIR="/u01/oracle/properties" \
	WDT_HOME="/u01" \
	ORACLE_HOME=/u01/oracle \
    JAVA_OPTIONS="-Doracle.jdbc.fanEnabled=false -Dweblogic.StdoutDebugEnabled=false"  \
    PATH="$PATH:${JAVA_HOME}/bin:/u01/oracle/oracle_common/common/bin:/u01/oracle/wlserver/common/bin:/u01/oracle/container-scripts"


# Unzip and install the WDT image and change the permissions / owner.
## https://docs.docker.com/engine/examples/running_ssh_service/
## https://bbs.archlinux.org/viewtopic.php?id=165382
#Create directory where domain will be written to
USER root
# Add files required to build this image
COPY --chown=oracle:oracle weblogic-deploy.zip ${WDT_HOME}
COPY --chown=oracle:oracle container-scripts/* /u01/oracle/container-scripts/
COPY --chown=oracle:oracle container-scripts/get_healthcheck_url.sh /u01/oracle/get_healthcheck_url.sh
COPY keys/* /home/oracle/.ssh/
RUN  chown -R oracle:root /home/oracle/.ssh && \
     chmod go-rw /home/oracle/.ssh/*
	 
RUN	yum install -y openssh-server openssh-clients vi sudo shadow-utils sed zip git hostname &&     yum clean all && \
    echo "oracle ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
	echo 'root:Welcome1412#' | chpasswd && \
	echo 'oracle:Welcome1412#' | chpasswd && \
	sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
	sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd && \
	sed -i 's/#Banner none/Banner \/home\/oracle\/WLS_deploy_scripts\/welcome_target.txt/g' /etc/ssh/sshd_config && \
	/usr/bin/ssh-keygen -A && \
     mkdir -p $DOMAIN_ROOT && \
    chown -R oracle:oracle $DOMAIN_ROOT/.. && \
    chmod -R a+xwr $DOMAIN_ROOT/.. && \
    mkdir -p $ORACLE_HOME/properties && \
    chmod -R a+r $ORACLE_HOME/properties && \ 
    chmod +x /u01/oracle/container-scripts/*  && \
     cd ${WDT_HOME} && \
     unzip weblogic-deploy.zip && \
	 chmod +xw weblogic-deploy/bin/*.sh && \
     chmod -R +xw weblogic-deploy/lib/python && \
     chown -R oracle:oracle /u01/weblogic-deploy	 

	

USER oracle
WORKDIR $ORACLE_HOME
RUN     echo "export PATH=/u01/weblogic-deploy/bin:$PATH" >> /home/oracle/.bashrc && \
		echo "export ORACLE_HOME=/u01/oracle" >> /home//oracle/.bashrc  && \
		echo "export MW_HOME=$ORACLE_HOME" >> /home/oracle/.bashrc && \
		echo "export DOMAIN_HOME=/u01/oracle/user_projects/domains/base_domain" >> /home/oracle/.bashrc  && \
		echo "export JAVA_HOME=/u01/jdk" >> /home/oracle/.bashrc	&& \
		echo "export WLST_PATH=/u01/oracle" >> /home/oracle/.bashrc	&& \
		cd /home/oracle && \
		git clone https://github.com/eugsim1/WLS_deploy_scripts.git && \
		chmod u+x WLS_deploy_scripts/*.sh

VOLUME $DOMAIN_ROOT

EXPOSE 22 9001 10001 11001
##CMD ["/bin/bash","/bootstrap.sh"]
USER  root
CMD ["/usr/sbin/sshd", "-D"]
#USER oracle
#WORKDIR $ORACLE_HOME
##CMD ["/u01/oracle/container-scripts/createWLSDomain.sh"]
#CMD ["/bin/sh"]
#!/bin/bash
####
###
#### docker run -d -P --name test_sshd_target 12214-domain:latest
#### export DOCKER_PORT=`docker port test_sshd_target 22`
#### export DOCKER_PORT=`echo $DOCKER_PORT | sed 's/0.0.0.0://g' `
#### echo $DOCKER_PORT
#### ssh -i ~/.ssh/priv.txt  -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"  oracle@localhost -p $DOCKER_PORT
####### docker container stop test_sshd_target
####### docker container rm test_sshd_target      

#docker container stop test_sshd_target
#docker container rm test_sshd_target