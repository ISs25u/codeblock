#!/usr/bin/env bash

sed 's|\([^@]\)=|\1·|gm' locale/codeblock.en.tr | awk 'BEGIN {FS="·"} {print $2}' >locale/en.tr
sed 's|\([^@]\)=|\1·|gm' locale/codeblock.fr.tr | awk 'BEGIN {FS="·"} {print $2}' >locale/fr.tr
