# SimpleTimeService

A tiny microservice that returns current timestamp and the client's IP in JSON.

## Run locally
1. Create virtualenv and install:
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
curl -s http://localhost:8080/ | jq .
# example response:
# {"timestamp":"2025-12-05T12:34:56.789012+05:30","ip":"127.0.0.1"}

docker login
# enter username and password

Tag & push:
docker tag <your-username>/simple-timeservice:latest <your-username>/simple-timeservice:latest
docker push <your-username>/simple-timeservice:latest


