# Run cBioportal Galaxy connector Docker compose
Download necessary files (seed data, example config and example study from
datahub):
```bash
./init.sh
```
Configure the Redis cache. The example file can be used for a demo:
```shell
cp config/redis.conf.EXAMPLE config/redis.conf
```
Configure cBioportal. need to modify the following lines in the default application study:
```markdown
persistence.cache_type=redis
cache.endpoint.api-key=<random-api-key>
redis.name=cbioportal_galaxy
redis.leader_address=redis://<redis-leader-url>:<redis-port>
redis.follower_address=redis://<redis-follower-url>:<redis-port> # Can be the same as redis.leader_address if you only have one redis cache
redis.database=0
redis.password=<redis-password>
redis.ttl_mins=10000
redis.clear_on_startup=true
```
redis.password must match the one in redis.conf.

In addition, the modified cbioportal-frontend need a new variable (code available here at tmr branch: https://github.com/jCHENEBY/cbioportal/tree/tmr):
```markdown
export_server_url=http://<cbioportal-galaxy-connector-url>/export-to-galaxy
```
It should be noted that <cbioportal-galaxy-connector-url> must be this specific URL cannot be the name of a Docker container, but the one used by your navigator to reach the server.

An demo ready application.properties can be used:
```shell
cp config/application.properties.EXAMPLE config/application.properties
```

Start docker containers. This can take a few minutes the first time because the
database needs to import some data.
```shell
docker compose up -d
```
Other instructions are in the official docker compose repo: https://github.com/cBioPortal/cbioportal-docker-compose


# Configuration in the Docker compose

## cBioportal Galaxy connector

Code can be found here: https://github.com/jCHENEBY/cbioportal-galaxy-connector

### Environment variables
GALAXY_URL: URL of your Galaxy server. 

CBIOPORTAL_URL: URL of your cBioportal instance.

In this example cbioportal-galaxy-connector is on the same Docker network as Galaxy and cBioportal, they are referenced by their container name.


### Volume

Study directory:
- type: bind
- source: Must be the same directory mount by the cBioportal container
- target: Where the scripts will be looking for the study

cBioportal configuration:
- type: bind
- source: Must be the same cBioportal configuration file used for the cBioportal server. It is necessary for the metaImport.py script (see [cbioportal-core repo](https://github.com/cBioPortal/cbioportal-core))
- target: Replace the dummy application.properties 

Image directory:
- type: volume
- source: image_data
- target: Where images are uploaded and made available at http://<URL_CONNECTOR>/images/<image_name>

## Galaxy

Contain default tools and tools develop for this project:
- PyClone-VI (Under Variant): https://github.com/jCHENEBY/docker-galaxy-pyclone
- Plotting clonal population from PyClone-VI output: https://github.com/jCHENEBY/galaxy-tool-plot-cluster-prevalence
- Exporting raw PyClone-VI TSV output to cBioportal as a timeline: https://github.com/jCHENEBY/galaxy-tool-export-cbioportal-timeline
- Adding images as a cBioportal resource: https://github.com/jCHENEBY/galaxy-tool-export-cbioportal-image

### Environment variables

EXPORT_TIMELINE_ENDPOINT: URL endpoint of the intermediary server with the endpoint
UPLOAD_IMAGE_ENDPOINT: URL endpoint of the intermediary server with the endpoint
CBIOPORTAL_LOAD_RESOURCE_ENDPOINT: URL endpoint of the intermediary server with the endpoint
IMAGE_BASE_URL: cannot be the name of a Docker container, but the one used by your navigator to reach the image

### Volume
Galaxy database:
type: volume
source: galaxy_data
target: Path to the Galaxy database directory

---
# Run cBioPortal using Docker Compose
Download necessary files (seed data, example config and example study from
datahub):
```
./init.sh
```

Start docker containers. This can take a few minutes the first time because the
database needs to import some data.
```
docker compose up
```
If you are developing and want to expose the MySQL database for inspection through a program like Sequel Pro, run:
```
docker compose -f docker-compose.yml -f dev/open-ports.yml up
```
In a different terminal import a study
```
docker compose exec cbioportal metaImport.py -u http://cbioportal:8080 -s study/lgg_ucsf_2014/ -o
```

Restart the cbioportal container after importing:
```
docker compose restart cbioportal
```

The compose file uses docker volumes which persist data between reboots. To completely remove all data run:

```
docker compose down -v
```

If you were able to successfully set up a local installation of cBioPortal, please add it here: https://www.cbioportal.org/installations. Thank you!

## Known issues

## Loading other seed databases
### hg38 support
To enable hg38 support. First delete any existing databases and containers:
```
docker compose down -v
```
Then run
```
init_hg38.sh
```
Followed by:
```
docker compose up
```
When loading hg38 data make sure to set `reference_genome: hg38` in [meta_study.txt](https://docs.cbioportal.org/5.1-data-loading/data-loading/file-formats#meta-file-4). The example study in `study/` is `hg19` based. 

## Example Commands
### Connect to the database
```
docker compose exec cbioportal-database \
    sh -c 'mysql -hcbioportal-database -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"'
```

## Advanced topics
### Run different cBioPortal version

A different version of cBioPortal can be run using docker compose by declaring the `DOCKER_IMAGE_CBIOPORTAL`
environmental variable. This variable can point a DockerHub image like so:

```
export DOCKER_IMAGE_CBIOPORTAL=cbioportal/cbioportal:3.1.0
docker compose up
```

which will start the v3.1.0 portal version rather than the newer default version.

### Change the heap size
#### Web app
You can change the heap size in the command section of the cbioportal container

#### Importer
For the importer you can't directly edit the java command used to import a study. Instead add `JAVA_TOOL_OPTIONS` as an environment variable to the cbioportal container and set the desired JVM parameters there (e.g. `JAVA_TOOL_OPTIONS: "-Xms4g -Xmx8g"`).
