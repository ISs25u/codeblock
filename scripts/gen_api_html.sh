#!/usr/bin/env bash

cat doc/commands.md |\
    perl -0777 -pe 's|`(.+?)\((.*?)\)`|<b><style color=#888888 font=mono size=12>\1</style>`(\2)`|gm' |\
    perl -0777 -pe 's|`\((.*)\)`|<style font=mono size=12>(</style><style color=#e9c46a font=mono size=12>\1</style><style font=mono size=12>)</style></b>|gm' |\
    perl -0777 -pe 's|,|</style><style font=mono size=12>,</style><style color=#e9c46a font=mono size=12>|gm' |\
    perl -0777 -pe 's|# (.+)|<b><style font=normal size=16>\1</style></b>|gm' |\
    perl -0777 -pe 's|`(.+)`|<b><style color=#888888 font=mono size=12>\1</style></b>|gm' |\
    perl -0777 -pe 's|\n\n|\n|gs' |\
    perl -0777 -pe 's|\[|\\[|gs' |\
    perl -0777 -pe 's|\]|\\]|gs' |\
    xclip -selection clipboard