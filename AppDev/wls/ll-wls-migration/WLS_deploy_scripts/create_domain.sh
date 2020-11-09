#### https://github.com/oracle/weblogic-deploy-tooling/blob/master/site/create.md
#### create a domain_home
createDomain.sh \
-oracle_home $ORACLE_HOME \
-java_home $JAVA_HOME \
-domain_home $DOMAIN_HOME \
-domain_type WLS \
-variable_file <your_properties_file> \
-model_file   <your_model.yaml_file> \
-archive_file <your_application_archive> \
-wlst_path    $WLST_PATH