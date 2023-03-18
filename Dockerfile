FROM golang

WORKDIR /root

CMD ["clean", "build"]
ENTRYPOINT ["make"]