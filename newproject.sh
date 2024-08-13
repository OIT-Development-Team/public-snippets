#!/bin/sh
#Version 1.8

#Pull down github action file
if [ ! -f .github/workflows/build.yaml ]; then
       curl https://gist.githubusercontent.com/jbstowe/c2c7b4c55b8a10bb33f323984424e495/raw/5edc19958b27e97227df4c411404e296126aa560/build.yml --create-dirs -o .github/workflows/build.yaml
fi

#Pull down docker-compose.yml file
if [ ! -f docker-compose.yml ]; then
       curl https://gist.githubusercontent.com/jbstowe/a406fa3c2ad4e04b284d00adca79c975/raw/fac86c973c444bb92a9eb0b4cfe5409ebfbfb141/docker-compose.yml --create-dirs -o docker-compose.yml
fi

#Pull down deploy-plan.json file
if [ ! -f deploy-plan.json ]; then
       curl {{ url for new deploy-plan }} --create-dirs -o deploy-plan.json
fi

#give developers a script to create a new laravel project if a laravel app is not detected
if [ ! -d app ]; then
       if [ ! -f new-laravel-app.sh ]; then
              curl {{ url for new new-laravel-app.sh }} --create-dirs -o new-laravel-app.sh
              chmod +x new-laravel-app.sh
       fi
fi

if [ ! -d Dockerfile.dev ]; then
       curl -X POST -d @deploy-plan.json --header "Content-Type: application/json" -H "AUTH: $AUTH" https://build-dockerfile-api.oitapps.ua.edu/api/docker/build-dev > Dockerfile.dev
fi

#Build and run container
docker stop app
docker rm app
docker-compose up -d --build