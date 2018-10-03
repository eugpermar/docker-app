FROM golang:alpine AS devel

RUN apk add --no-cache git gcc musl-dev

# Prepare workdir
WORKDIR /go/src/app
COPY app.go .

# Dependencies
RUN go get -d -v ./...
RUN go install -v ./...

# Build
RUN env CGO_ENABLED=0 go build -buildmode=pie -a -v .

#
# RELEASE CONTAINER
#

FROM scratch

COPY --from=devel /go/bin/app .
COPY --from=devel /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1

USER 405

ENTRYPOINT ["/app"]
