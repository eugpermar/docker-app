FROM alpine

RUN apk add --no-cache python2

COPY back_server.py ./

ENTRYPOINT ["python2", "/back_server.py"]
