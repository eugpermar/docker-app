# Another way:
# FROM python:2.7-alpine
# FROM python:2.7-slim
# FROM python:...
#
# Please check the differences with python2.7-alpine dockerfile

FROM alpine

RUN apk add --no-cache python

RUN mkdir -m 750 logs && chown 405:405 logs
USER guest

COPY app.py .

CMD ["python2", "/app.py"]
