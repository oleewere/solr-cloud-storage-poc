# Ambari Infra Solr Cloud Storage POC
POC for supporting S3/GCS/WASB/ADLSv2 through HDFS client for Ambari Infra Solr

### Requirements
- git
- JDK 8+
- Maven 3.5.x+
- docker & docker-compose
- AWS cli (for S3A mode)

### Checkout Ambari Infra Solr project and build container
```bash
git clone git@github.com:apache/ambari-infra.git
cd ambari-infra
git checkout origin/cloud-storage-poc
make docker-build
```

### Create Profile file
Run the following command:
```bash
./up.sh
```
If you do not have any Profile file, it will generate you one. That will contain different environment variables, those will be used to create `core-site.xml` and `docker-compose.yml` files from templates.

### Cloud modes
Cloud modes can be set in the Profile file by `TEST_SOLR_STORAGE_MODE`, the following values are valid right now:
- S3A
- S3N
- WASB
- ABFS

### Run Solr & LogSearch

```bash
./up.sh
```

### NOTES
- S3A shutdown connection pools, that is the same behavior for localstack and real s3 as well
- S3N looks like could work properly, but data update/delete can be really slow.
- WASB/WASBS looks good
- ABFS - https://issues.jboss.org/browse/WFLY-8753 - a similar issue happens
