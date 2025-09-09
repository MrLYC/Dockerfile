FROM golang:1.13.3 as builder
WORKDIR /

COPY . .
RUN go mod download
RUN go build -o app .

FROM alpine
WORKDIR /

ENV GIN_MODE release
COPY --from=builder app .

ENTRYPOINT ["./app"]
