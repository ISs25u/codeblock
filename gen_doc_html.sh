#!/usr/bin/env bash

pandoc doc/api.md \
    -f markdown -t html \
    --toc \
    --metadata title="codeblock API" \
    --template="https://gist.githubusercontent.com/gigaturbo/b0c4d762f42bbdfacd9e087c942b0b32/raw/39c9c44979ed11424edb172f78f9ca26e05b2810/HTML.html" \
    -o doc/api.html
