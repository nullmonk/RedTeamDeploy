FROM alpine:latest
RUN apk add --update python3 tzdata git

# Set the timezone
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN git clone --branch dev https://github.com/RITRedteam/Sangheili /opt/sangheili
WORKDIR /opt/sangheili
RUN pip3 install -r requirements.txt
RUN pip3 install requests
RUN rm config.yml
COPY config.yml config.yml
# Run the app
ENTRYPOINT [ "python3" ]
CMD [ "sangheili.py" ]
