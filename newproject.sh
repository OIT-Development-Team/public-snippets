#!/bin/sh
#Version 1.8

#Pull down github action file
if [ ! -f .github/workflows/build.yaml ]; then
       curl https://raw.githubusercontent.com/OIT-Development-Team/public-deploy-scripts/v8.3.0/build.yaml --create-dirs -o .github/workflows/build.yaml
fi

#Pull down docker-compose.yaml file
if [ ! -f docker-compose.yaml ]; then
       curl https://raw.githubusercontent.com/OIT-Development-Team/public-deploy-scripts/v8.3.0/docker-compose.yaml --create-dirs -o docker-compose.yaml
fi

#Pull down deploy-plan.json file
if [ ! -f deploy-plan.json ]; then
       curl https://raw.githubusercontent.com/OIT-Development-Team/public-deploy-scripts/v8.3.0/deploy-plan.json --create-dirs -o deploy-plan.json
fi

#give developers a script to create a new laravel project if a laravel app is not detected
if [ ! -d app ]; then
       if [ ! -f new-laravel-app.sh ]; then
              curl https://raw.githubusercontent.com/OIT-Development-Team/public-deploy-scripts/v8.3.0/new-laravel-app.sh --create-dirs -o new-laravel-app.sh
              chmod +x new-laravel-app.sh
       fi
fi

curl -X POST -d @deploy-plan.json --header "Content-Type: application/json" -H "AUTH: $AUTH" https://build-dockerfile-api.oitapps.ua.edu/api/docker/build-dev > Dockerfile.dev

#Build and run container
docker stop app
docker rm app

# Check for Windows by detecting 'OS' environment variable in cmd/Git Bash
if [ "$OS" = "Windows_NT" ]; then
    # Windows environment (cmd or Git Bash)
    if command -v docker compose >/dev/null 2>&1; then
        docker compose up -d --build
    else
        docker-compose up -d --build
    fi
else
    # Unix-like environment (Linux, macOS)
    if command -v docker compose >/dev/null 2>&1; then
        docker compose up -d --build
    else
        docker-compose up -d --build
    fi
fi
