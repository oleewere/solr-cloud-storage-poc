# Ambari Infra Solr S3 POC
POC for supporting S3 through HDFS client for Ambari Infra Solr

### Checkout Ambari Infra Solr project and build container
```bash
git clone git@github.com:apache/ambari-infra.git
cd ambari-infra
git checkout origin/s3-poc
make docker-build
```
### Edit Config files

Edit `docker-compose.yml` file to use the right bucket urls (see `SOLR_OPTS`) and set the volumes to use `core-site-s3a.xml` or `core-site-s3n.xml`. (those files should be updated as well with the rigth secret access key settings)

### Run Solr & LogSearch

```bash
docker-compose up -d zookeeper solr logsearch
```

### Use Localstack (fake s3)

By default `core-site-s3a.xml` is defined to use `fakes3` address (that points to the localstack container)
```bash
./up.sh
```

`NOTES`: s3a shutdown connection pools, that is the same behavior for localstack and real s3 as well. S3N looks like could work properly, but data update/delete can be really slow.
