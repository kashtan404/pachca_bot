FROM golang:1.17.6-alpine3.15 as builder
WORKDIR /app
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
RUN GOGC=off CGO_ENABLED=0 go build -v -o pachca_bot

FROM alpine:3.15.0 as alpine
RUN apk add --no-cache ca-certificates tzdata

FROM scratch
EXPOSE 9087
WORKDIR /
COPY --from=alpine /etc/passwd /etc/group /etc/
COPY --from=alpine /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=alpine /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /app/pachca_bot /pachca_bot
USER nobody
CMD ["/pachca_bot"]
