#!/bin/bash

docker build -t d.kt-team.de/php:7.0-centos .
docker push d.kt-team.de/php:7.0-centos
