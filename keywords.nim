type
  SpecialWords* = enum
    wInvalid

    # operators
    wPlus, wMinus, wMul, wDiv
    wDot, wDotDot, wColon, wColonColon      # this two section
    wBang, wChoice, wAt                     # must match with
    wEquals, wGreaterOrEqual, wLessOrEqual  # TokenKind's order
    # keyword                               # to ensure proper
    wProgram, wStyle, wAlias                # token generated
    wEvent, wProp, wFlex

    # constraint relative
    wThis, wParent, wChild, wPrev, wNext

    # view's basic constraint field
    wLeft, wRight, wTop, wBottom
    wWidth, wHeight, wCenterX, wCenterY

    # view's basic prop
    wContent, wTitle, wZindex, wOverflow
    wVisible, wMultiline, wLink, wImg, wIcon

    # view's basic mouse events
    wClick, wContextMenu, wDblClick, wMouseDown
    wMouseEnter, wMouseLeave, wMouseMove, wMouseOver
    wMouseOut, wMouseUp, wWheel

    # view's basic keyboard events
    wKeyDown, wKeyPress, wKeyUp

    # other events
    wAbort, wBeforeUnload, wError, wHashChange
    wLoad, wResize, wScroll, wUnload

    # focus events
    wBlur, wChange, wFocus, wFocusIn, wFocusOut
    wInput, wSelect

    # drag drop events
    wDrag, wDragEnd, wDragEnter, wDragLeave
    wDragOver, wDragStart, wOnDrop

const
  specialWords* = [
    "+", "-", "*", "/",
    ".", "..", ":", "::",
    "!", "|", "@",
    "=", ">=", "<=",

    "program", "style", "alias",
    "flex", "event", "prop",

    "this", "parent", "child", "prev", "next",
    "left", "right", "top", "bottom",
    "width", "height", "centerX", "centerY",

    "content", "title", "zindex", "overflow",
    "visible", "multiline", "link", "img", "icon",

    "click", "contextMenu", "dblClick", "mouseDown",
    "mouseEnter", "mouseLeave", "mouseMove", "mouseOver",
    "mouseOut", "mouseUp", "wheel",

    "keyDown", "keyPress", "keyUp",

    "abort", "beforeUnload", "error", "hashChange",
    "load", "resize", "scroll", "unload",

    "blur", "change", "focus", "focusIn", "focusOut",
    "input", "select",

    "drag", "dragEnd", "dragEnter", "dragLeave",
    "dragOver", "dragStart", "onDrop",
  ]

  constOpr* = {wEquals, wGreaterOrEqual, wLessOrEqual}
  constRel* = {wThis, wParent, wChild, wPrev, wNext}
  constProp* = {wLeft..wCenterY}
  constBinaryTermOp* = {wPlus, wMinus, wMul, wDiv}
  constUnaryTermOp* = {wMinus}

  validEvents* = {wClick..wOnDrop}
  validProps* = {wContent..wIcon}
