# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import dom
import math
import strformat
import random
import strutils

import html5_canvas 

type
  Node = ref object
    x: float
    y: float
  Chain = ref object
    nodes: seq[Node]
    width: float

var selectedChain: Chain
var selectedNode: Node
var dragging: bool
var can: Canvas
var ctx: CanvasRenderingContext2D
var chains: seq[Chain]
var drawing: bool
var clickZone = 7'f


proc drawNodes(mousePosX: float, mousePosY: float)

when isMainModule:
  # initialize globals
  chains = @[]
  selectedChain = nil 
  selectedNode = nil
  drawing = false
  dragging = false

  can = document.createElement("canvas").Canvas
  document.body.appendChild(can)

  can.height = 500 
  can.width = 500 

  ctx = can.getContext2D()

  # create an input box for the user to input a chain width
  var widthInput = document.createElement("input")
  widthInput.setAttribute("type", "text")
  widthInput.value = ""
  widthInput.style.position = "absolute"
  widthInput.style.left = "10px"
  widthInput.style.top = "10px"
  widthInput.style.width = "100px"
  widthInput.style.height = "22px"
  widthInput.style.backgroundColor = "white"
  widthInput.style.border = "1px solid black"
  widthInput.style.borderRadius = "5px"
  widthInput.style.padding = "2px"
  widthInput.style.fontSize = "12px"
  widthInput.style.fontFamily = "monospace"
  widthInput.style.textAlign = "center"
  widthInput.style.color = "black"
  widthInput.style.outline = "none"
  widthInput.style.zIndex = "1"
  widthInput.style.boxShadow = "0px 0px 5px #888"
  widthInput.style.textShadow = "0px 0px 5px #888"
  widthInput.style.borderRadius = "5px"
  widthInput.style.boxSizing = "border-box"
  document.body.appendChild(widthInput)
  widthInput.addEventListener("input", proc(e: Event) =
    # update the current chain width
    if (selectedChain != nil):
      selectedChain.width = try:
        parseFloat($(e.target.value))
      except:
        1.0
      drawNodes(0'f,0'f)
  )


  # when you double click the canvas, create a new chain and start drawing
  can.addEventListener("dblclick", proc(e: MouseEvent) =
    if not drawing:
      var chain = Chain()
      chain.width = rand(3.0) + 1.0
      chain.nodes = @[]

      let x = e.clientX - can.offsetLeft
      let y = e.clientY - can.offsetTop

      chain.nodes.add(Node(x:x.float, y:y.float))
      chains.add(chain)
      selectedChain = chain
      selectedNode = chain.nodes[0]
      # update the input box for the chain's width
      widthInput.value = fmt"{selectedChain.width:.1f}"

      drawing = true
    else:
      drawing = false
      if selectedChain != nil and selectedChain.nodes.len > 1:
        discard selectedChain.nodes.pop
          
  )

  can.addEventListener("mousedown", proc(e: MouseEvent) =
    let x = e.clientX - can.offsetLeft
    let y = e.clientY - can.offsetTop

    if drawing:
      # add a new node to the chain
      selectedChain.nodes.add(Node(x:x.float, y:y.float))
      selectedNode = selectedChain.nodes[^1] 
    else:
      # find an existing chain that contains the clicked point
      selectedChain = nil
      selectedNode = nil

      block search:
        for chain in chains:
          for node in chain.nodes:
            if abs(node.x - x.float) <= clickZone and
               abs(node.y - y.float) <= clickZone:
              selectedChain = chain
              selectedNode = node
              break search
      
      if not selectedChain.isNil and not selectedNode.isNil:
        # we have selected a chain and node, so start dragging
        dragging = true
        # update the input box for the chain's width
        widthInput.value = fmt"{selectedChain.width:.1f}"

        
    
    echo fmt"{selectedChain==nil}, {selectedNode==nil}, {drawing}, {dragging}"
  )

  can.addEventListener("mouseup", proc(e: MouseEvent) =
    dragging = false
  )

  can.addEventListener("mousemove", proc(e: MouseEvent) =
    let x = e.clientX - can.offsetLeft
    let y = e.clientY - can.offsetTop

    if not drawing:
      if dragging:
        let x = e.clientX - can.offsetLeft
        let y = e.clientY - can.offsetTop
        selectedNode.x = x.float
        selectedNode.y = y.float

    drawNodes(x.float, y.float)
  )

  drawNodes(0'f, 0'f)


# draw the chain and its nodes on the canvas
proc drawNodes(mousePosX: float, mousePosY: float) = 
  ctx.fillStyle = "rgb(200,200,200)"
  ctx.fillRect(0'f, 0'f, can.width.float, can.height.float)

  var lastNode: Node
  for chain in chains:
    ctx.lineWidth = chain.width
    lastNode = nil
    for node in chain.nodes:
      if chain == selectedChain:
        ctx.strokeStyle = "black"
        if node == selectedNode:
          ctx.fillStyle = "red"
        else:
          ctx.fillStyle = "black"
      else:
        ctx.fillStyle = "rgb(100,100,100)"
        ctx.strokeStyle = "rgb(100,100,100)"

      ctx.beginPath()
      ctx.arc(node.x, node.y, 5, 0, 2*math.PI)
      ctx.closePath()
      ctx.fill()

      # draw a line from the last node to the current node
      if not lastNode.isNil:
        ctx.beginPath()
        ctx.moveTo(lastNode.x, lastNode.y)
        ctx.lineTo(node.x, node.y)
        ctx.stroke()

      lastNode = node

  if drawing and not selectedChain.isNil and selectedChain.nodes.len > 0:
    ctx.lineWidth = selectedChain.width
    ctx.strokeStyle = "black dashed"
    ctx.beginPath()
    ctx.moveTo(selectedChain.nodes[^1].x, selectedChain.nodes[^1].y)
    ctx.lineTo(mousePosX, mousePosY)
    ctx.stroke()
    echo "drawing livepath?"
