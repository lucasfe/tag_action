FROM alpine:3.10
LABEL "repository"="https://github.com/lucasfe/tag_action"
LABEL "homepage"="https://github.com/lucasfe/tag_action"
LABEL "maintainer"="Lucas Ferreira"

COPY entrypoint.sh /entrypoint.sh

RUN apk update && apk add bash git curl jq

ENTRYPOINT ["/entrypoint.sh"]
