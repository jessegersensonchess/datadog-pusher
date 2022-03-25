#### DESCRIPTION: pushes metrics to datadog
#### INPUT: metric.name, value
#### NOTE: expects env variables and is written in python, so likely won't be portable or last long?!

FROM debian:latest

RUN apt-get update && \
	apt-get install -y python3 python3-pip curl jq && \
	pip install datadog	

WORKDIR /app
COPY . ./
RUN chmod +x *sh
CMD ["/app/start.sh"]
