FROM ubuntu:20.04

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y wget curl httpie git jq

RUN wget https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64 && mv yq_linux_amd64 /usr/bin/yq && chmod +x /usr/bin/yq

COPY build_markdown.sh /build_markdown.sh

COPY task.sh /task.sh

COPY operational-readiness-template.yml .

COPY products.yml .

ENTRYPOINT [ "/task.sh" ]
