#!/usr/bin/sed -nf
# Print only lines which consist purely of graphical (glyphical, visible) characters:
/^[[:graph:]]\+$/p
