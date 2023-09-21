
ARG IMG_TAG=latest

# Compile the gaiad binary
FROM golang:1.18-alpine AS gaiad-builder
WORKDIR /src/app/
COPY go.mod go.sum* ./
RUN go mod download
COPY . .
ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev python3
RUN apk add --no-cache $PACKAGES
# Fixed the typo in the make command to build the gaiad binary
# Changed 'install' to 'build'
RUN CGO_ENABLED=0 make build

# Add to a distroless container
FROM gcr.io/distroless/static:$IMG_TAG
ARG IMG_TAG
# Changed the copy command to copy the gaiad binary from the previous stage
COPY --from=gaiad-builder /src/app/gaiad /usr/local/bin/
EXPOSE 26656 26657 1317 9090
USER 0

ENTRYPOINT ["gaiad", "start"]
