FROM pseudomuto/protoc-gen-doc as builder

WORKDIR /app
ADD . .

RUN mkdir docs

RUN protoc \
    --plugin=protoc-gen-doc=/usr/local/bin/protoc-gen-doc \
    --doc_out=./docs \
    --doc_opt=html,index.html \
    --proto_path=extensions \
    --proto_path=messages \
    messages/*.proto

FROM nginx:alpine

COPY --from=builder /app/docs /usr/share/nginx/html
RUN touch /usr/share/nginx/html/ping.html
