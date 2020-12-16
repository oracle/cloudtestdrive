updateDomain.sh \
-oracle_home $MW_HOME \
-domain_home $DOMAIN_HOME \
-model_file update.yaml \
-variable_file update.properties \
-archive_file update.zip \
-admin_user weblogic \
-admin_url t3://localhost:7001<<EOF
welcome1
EOF