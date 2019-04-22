FROM golang:1.11
ADD ./app /go/src/github.com/furikuri/canary/app
WORKDIR /go/src/github.com/furikuri/canary/app
RUN go get ./
RUN go build

FROM alpine:3.8
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
WORKDIR /root/
COPY --from=0 /go/bin/app .

ENTRYPOINT ["/root/app"]