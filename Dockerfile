FROM golang:alpine AS source

RUN apk add --no-cache git gcc musl-dev

# Prepare workdir
WORKDIR /go/src/app
COPY app.go .

# Dependencies
RUN go get -d -v ./...

#
# DEBUG CONTAINER
#

FROM source AS debugger

RUN apk add --no-cache cgdb

# cflags disable optimizations
RUN env go install -gcflags '-N -l' -a -v .
CMD ["cgdb", "--args", "/go/bin/app"]

#
# RELEASE CONTAINER
#

FROM source AS release-builder

# Build
RUN env CGO_ENABLED=0 go install -buildmode=pie -a -v .

FROM scratch

COPY --from=release-builder /go/bin/app .
COPY --from=release-builder /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1

USER 405

ENTRYPOINT ["/app"]
