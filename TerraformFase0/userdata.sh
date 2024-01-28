#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y docker.io
git clone https://github.com/Roballed/docker-frontend-backend-db.git
cd docker-frontend-backend-db
docker-compose up -d
