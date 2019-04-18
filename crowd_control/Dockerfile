FROM alpine:latest
RUN apk add --update python3 tzdata git

# Set the timezone
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN git clone https://github.com/degenerat3/crowd_control /opt/cc
WORKDIR /opt/cc/server
RUN pip3 install -r requirements.txt
# Run the app
ENTRYPOINT [ "python3" ]
CMD [ "app.py" ]
