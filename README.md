# SimpleTimeService

A tiny microservice that returns the current timestamp and the client's IP in JSON.

## Run locally
1. Create a virtualenv and install:
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py

2. Visit: http://localhost:8080/

## Docker
Build:
docker build -t your_dockerhub_username/simple-timeservice:latest .

Run:
docker run --rm -p 8080:8080 your_dockerhub_username/simple-timeservice:latest



## Notes
- App respects X-Forwarded-For header.
- The container runs the app as a non-root user.

# Tag it with your DockerHub username (replace <your-username>)
docker build -t <your-username>/simple-timeservice:latest .

# (Optional) test locally
docker run --rm -p 8080:8080 <your-username>/simple-timeservice:latest

# Test with curl
curl -s http://localhost:8080/

docker login
# enter username and password

Tag & push:
docker tag <your-username>/simple-timeservice:latest <your-username>/simple-timeservice:latest
docker push <your-username>/simple-timeservice:latest

---------------------------------------------------------------


TERRAFORM NOTES:

AUTHENTICATE WITH AWS ACCOUNT 

AWS Access Key ID [None]: YOUR_ACCESS_KEY_ID
AWS Secret Access Key [None]: YOUR_SECRET_ACCESS_KEY
Default region name [None]: us-east-1
Default output format [None]: json

First, clone the GitHub URL locally.
Switch to the Terraform directory.

Terraform init
terraform plan and apply 



