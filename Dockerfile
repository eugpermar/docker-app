# Another way:
# FROM python:2.7-alpine
# FROM python:2.7-slim
# FROM python:...
#
# Please check the differences with python2.7-alpine dockerfile

#
# BASE. Just for "naming"
#
FROM alpine AS base

#
# DEVEL CONTAINER
# This image contains the common stuff for devel and release.
#

FROM base AS devel

RUN mkdir -m 750 logs && chown 405:405 logs
RUN apk add --no-cache py-pip
RUN pip install nltk

RUN python -c "import nltk; \
               nltk.download('punkt', download_dir='/nltk_data'); \
               nltk.download('averaged_perceptron_tagger', \
                             download_dir='/nltk_data')"

COPY app.py back_server.py ./

#
# DEBUG CONTAINER
# This container must include all debug information and tools
#

FROM devel AS debug

CMD exec env NLTK_DATA=/nltk_data python2 -m pdb /app.py


#
# RELEASE DEVELOPMENT CONTAINER
# This container includes compiler and all the needed tools to build final
# script, libs, binary, and artifacts.
# We can install and do everything we want in this image, since we are not going
# to use any layer directly
#

FROM devel AS release-devel

# Compile here everything, do not including source
RUN python2 -OO -m compileall app.py back_server.py /nltk_data

# Delete everything we don't want! We can continue with pip, python libraries...
RUN find /nltk_data/ -type d \
        -o -name '*.pickle' -o -name '*.pyc' -o -name '*.pyo' -o -delete

#
# RELEASE DEVELOPMENT CONTAINER
# This image does not
#

FROM base AS release

# Delete installed stuffs in the same layer!
RUN apk add --no-cache python2 && apk add --no-cache py-pip && \
    pip install nltk && apk del py-pip

USER guest

COPY --from=release-devel --chown=405 /logs/ /logs/
COPY --from=release-devel app.pyo back_server.pyo ./
COPY --from=release-devel /nltk_data /nltk_data/

VOLUME /logs

ENTRYPOINT ["env", "NLTK_DATA=/nltk_data", "python2", "/app.pyo"]
