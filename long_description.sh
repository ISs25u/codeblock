#!/usr/bin bash
cat README.md | grep -v 'screenshot.png' | perl -0777 -pe 's|\n|\\n|gm' | xsel -ibps