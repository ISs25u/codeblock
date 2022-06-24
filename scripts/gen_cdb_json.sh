#!/usr/bin/env bash

printf \
'{
    "type": "MOD",
    "title": "CodeBlock",
    "name": "codeblock",
    "short_description": "Use lua code to build anything you want",
    "long_description": "%s",
    "tags": [
        "education",
        "tools"
    ],
    "content_warnings": null,
    "license": "GPL-3.0-only",
    "media_license": "GPL-3.0-only",
    "repo": "https://github.com/gigaturbo/codeblock",
    "website": null,
    "issue_tracker": "https://github.com/gigaturbo/codeblock/issues",
    "forums": null
}' "$(perl -0777 -pe 's|\n|\\n|gs' README.md)" > .cdb.json
