mkdir study

curl -o study/nsclc_tracerx_2017.tar.gz https://cbioportal-datahub.s3.amazonaws.com/nsclc_tracerx_2017.tar.gz

tar -xzvf study/nsclc_tracerx_2017.tar.gz -C study/

docker compose run cbioportal metaImport.py -u http://cbioportal:8080 -s study/nsclc_tracerx_2017/ -o