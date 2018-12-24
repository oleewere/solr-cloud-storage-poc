#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
docker-compose kill

if [[ -f Profile ]]; then
  echo "Prolfe file exists. Sourcing it ..."
else
  echo "Profile file does not exist, creating it ... check/update the file, then restart."
  cat << EOF > Profile
TEST_SOLR_STORAGE_MODE=S3A
TEST_SOLR_CLOUD_STORAGE_URL=s3a://infra-solr
#TEST_SOLR_CLOUD_STORAGE_URL=wasb://infra-solr@myaccount.blob.core.windows.net
#TEST_SOLR_CLOUD_STORAGE_URL=abfs://infra-solr@myaccount.dfs.core.windows.net
TEST_SOLR_AWS_ACCESS_KEY=MyAccessKey
TEST_SOLR_AWS_SECRET_KEY=MySecretKey
TEST_SOLR_AZURE_ACCESS_KEY=MyAccessKey
TEST_SOLR_AZURE_ACCOUNT=MyAccount
EOF
  exit 0
fi

source Profile

cp docker-compose-tmpl.yml docker-compose.yml
sed -i.bak "s#{TEST_SOLR_CLOUD_STORAGE_URL}#$TEST_SOLR_CLOUD_STORAGE_URL#g" docker-compose.yml && rm docker-compose.yml.bak
sed -i.bak "s#{TEST_SOLR_CLOUD_STORAGE_URL}#$TEST_SOLR_CLOUD_STORAGE_URL#g" docker-compose.yml && rm docker-compose.yml.bak

if [[ "$TEST_SOLR_STORAGE_MODE" == "S3A" ]]; then
  echo "Using S3A HDFS client setup for Solr ..."
  cp core-site-s3a.xml core-site.xml
  sed -i.bak "s#{TEST_SOLR_CLOUD_STORAGE_URL}#$TEST_SOLR_CLOUD_STORAGE_URL#g" core-site.xml && rm core-site.xml.bak
  sed -i.bak "s#{TEST_SOLR_AWS_ACCESS_KEY}#$TEST_SOLR_AWS_ACCESS_KEY#g" core-site.xml && rm core-site.xml.bak
  sed -i.bak "s#{TEST_SOLR_AWS_SECRET_KEY}#$TEST_SOLR_AWS_SECRET_KEY#g" core-site.xml && rm core-site.xml.bak
  docker-compose up -d fakes3
  sleep 5
  aws --endpoint-url=http://localhost:4569 s3 mb s3://infra-solr
  docker-compose up -d zookeeper solr logsearch
  docker logs -f infra_solr
elif [[ "$TEST_SOLR_STORAGE_MODE" == "S3N" ]]; then
  echo "Using S3N HDFS client setup for Solr ..."
  cp core-site-s3n.xml core-site.xml
  sed -i.bak "s#{TEST_SOLR_CLOUD_STORAGE_URL}#$TEST_SOLR_CLOUD_STORAGE_URL#g" core-site.xml && rm core-site.xml.bak
  sed -i.bak "s#{TEST_SOLR_AWS_ACCESS_KEY}#$TEST_SOLR_AWS_ACCESS_KEY#g" core-site.xml && rm core-site.xml.bak
  sed -i.bak "s#{TEST_SOLR_AWS_SECRET_KEY}#$TEST_SOLR_AWS_SECRET_KEY#g" core-site.xml && rm core-site.xml.bak
  docker-compose up -d zookeeper solr logsearch
  docker logs -f infra_solr
elif [[ "$TEST_SOLR_STORAGE_MODE" == "WASB" ]]; then
  echo "Using WASB HDFS client setup for Solr ..."
  cp core-site-wasb.xml core-site.xml
  sed -i.bak "s#{TEST_SOLR_CLOUD_STORAGE_URL}#$TEST_SOLR_CLOUD_STORAGE_URL#g" core-site.xml && rm core-site.xml.bak
  sed -i.bak "s#{TEST_SOLR_AZURE_ACCESS_KEY}#$TEST_SOLR_AZURE_ACCESS_KEY#g" core-site.xml && rm core-site.xml.bak
  sed -i.bak "s#{TEST_SOLR_AZURE_ACCOUNT}#$TEST_SOLR_AZURE_ACCOUNT#g" core-site.xml && rm core-site.xml.bak
  docker-compose up -d zookeeper solr logsearch
  docker logs -f infra_solr
elif [[ "$TEST_SOLR_STORAGE_MODE" == "ABFS" ]]; then
  echo "Using ADLSv2 HDFS client setup for Solr ..."
  cp core-site-abfs.xml core-site.xml
  sed -i.bak "s#{TEST_SOLR_CLOUD_STORAGE_URL}#$TEST_SOLR_CLOUD_STORAGE_URL#g" core-site.xml && rm core-site.xml.bak
  sed -i.bak "s#{TEST_SOLR_AZURE_ACCESS_KEY}#$TEST_SOLR_AZURE_ACCESS_KEY#g" core-site.xml && rm core-site.xml.bak
  sed -i.bak "s#{TEST_SOLR_AZURE_ACCOUNT}#$TEST_SOLR_AZURE_ACCOUNT#g" core-site.xml && rm core-site.xml.bak
  docker-compose up -d zookeeper solr logsearch
  docker logs -f infra_solr
else
  echo "No valid 'TEST_SOLR_STORAGE_MODE' set in Profile"
fi
