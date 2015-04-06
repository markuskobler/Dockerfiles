FROM gliderlabs/alpine:3.1

RUN \
  apk upgrade --update && \
  apk add python python-dev py-pip gcc xz-dev swig openssl-dev libc-dev && \
  rm -rf /var/cache/apk/* && \
  pip install docker-registry

ENV DOCKER_REGISTRY_CONFIG /usr/lib/python2.7/site-packages/config/config_sample.yml
ENV SETTINGS_FLAVOR dev

EXPOSE 5000

USER nobody

CMD ["docker-registry"]

# example docker run -e SETTINGS_FLAVOR=local -e STORAGE_PATH=/data/registry -e SEARCH_BACKEND=sqlalchemy -e SQLALCHEMY_INDEX_DATABASE=sqlite:////var/data/registry.db -v /var/data/registry:/data/registry -e INDEX_ENDPOINT=https://registry.cohesiveio.net -p 5000:5000 --name registry registry
