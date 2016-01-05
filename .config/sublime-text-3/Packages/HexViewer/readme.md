[![Unix Build Status][travis-image]][travis-link]
![License][license-image]
# HexViewer
Hex Viewer is a plugin for Sublime Text that allows the toggling of a file into a hex viewing mode.  Hex Viewer also supports hex editing.

<img src="http://dl.dropbox.com/u/342698/HexViewer/preview.png" border="0"/>

# Features

- View any file (that exist on disk) in a hex format showing both byte and ASCII representation.
- Command to jump to a specific address.
- In place editing of bytes or ASCII chars.
- Highlight selected byte **and** ascii code.
- Inspection panel showing different integer representation at the cursor position.
- Configurable display of byte grouping, bytes per line, endianness.
- Export hex view to a binary file.
- Get the checksum of a given file (various checksums are available).
- Generate checksum/hash from input via panel or text selection.
- Optionally auto convert binary to hex view.

# Documentation
http://facelessuser.github.io/HexViewer/

# License
Hex Viewer is released under the MIT license.

Copyright (c) 2011 - 2015 Isaac Muse <isaacmuse@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[travis-image]: https://img.shields.io/travis/facelessuser/HexViewer/master.svg
[travis-link]: https://travis-ci.org/facelessuser/HexViewer
[license-image]: https://img.shields.io/badge/license-MIT-blue.svg
