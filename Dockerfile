FROM golang:1.13.3 as builder
WORKDIR /

COPY . .
RUN go mod download
RUN go build -o app .

FROM nginx:alpine
RUN apk --no-cache add ca-certificates
WORKDIR /

ENV GIN_MODE release
COPY --from=builder app .

ENTRYPOINT ["./app"]
