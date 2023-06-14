FROM golang:1.20-alpine AS builder

ARG PORT=3000

ENV USER=go
ENV UID=10001
ENV HTTP_PORT=${PORT}

RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/nonexistent" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid "${UID}" \    
    "${USER}"

WORKDIR /app

COPY ./service/go.mod ./
COPY ./service/go.sum ./
RUN go mod download
RUN go mod verify

COPY ./service/*.go ./

RUN GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /stations

FROM scratch AS production
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /stations /stations

ENV HTTP_PORT=${PORT}

EXPOSE ${PORT}

USER go:go

ENTRYPOINT ["/stations"]"
