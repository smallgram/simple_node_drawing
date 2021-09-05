# Package

version       = "0.1.0"
author        = "smallgram"
description   = "Node drawing in JS"
license       = "MIT"
srcDir        = "src"
bin           = @["simple_node_drawing"]
namedBin      = {"simple_node_drawing": "nodedraw"}.toTable

binDir        = "public"
backend       = "js"


# Dependencies

requires "nim >= 1.4.6"
requires "html5_canvas >= 1.3"
