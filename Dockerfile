# Another way:
# FROM python:2.7-alpine
# FROM python:2.7-slim
# FROM python:...
#
# Please check the differences with python2.7-alpine dockerfile

FROM alpine

RUN apk add --no-cache python

RUN mkdir -m 750 logs && chown 405:405 logs
RUN apk add --no-cache py-pip
RUN pip install nltk

RUN python -c "import nltk; \
               nltk.download('punkt', download_dir='/nltk_data'); \
               nltk.download('averaged_perceptron_tagger', \
                             download_dir='/nltk_data')"

USER guest

COPY app.py .

ENTRYPOINT ["env", "NLTK_DATA=/nltk_data", "python2", "/app.py"]
