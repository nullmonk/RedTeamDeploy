FROM alpine:latest
RUN apk add --update python3 tzdata git py3-pip

# Set the timezone
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN git clone https://github.com/degenerat3/crowdcontrol /opt/cc

WORKDIR /opt/cc/server
RUN pip3 install -r requirements.txt

# Set up the data directories for the app
RUN mkdir -p /tmp/cc/hosts
RUN mkdir -p /tmp/cc/windows/hosts
RUN touch /tmp/cc/calls.log /tmp/cc/tasks.log /tmp/cc/windows/calls.log /tmp/cc/windows/tasks.log 

# Run the app
CMD ["python3", "app.py"]
