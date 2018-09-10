FROM centos:7

RUN groupadd -g 998 mrnobody && useradd -r -u 998 -g mrnobody mrnobody && \
	mkdir -m 750 logs && chown mrnobody:mrnobody logs

USER mrnobody

COPY app.py .

CMD /app.py
