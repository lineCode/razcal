#
# Copyright (c) 2013 Mikko Mononen memon@inside.org
#
# This software is provided 'as-is', without any express or implied
# warranty.  In no event will the authors be held liable for any damages
# arising from the use of this software.
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
# 1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software
#    in a product, an acknowledgment in the product documentation would be
#    appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not be
#    misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.

import math, opengl

when defined(nvgGL2):
  const GLVersion* = "GL2"
elif defined(nvgGL3):
  const GLVersion* = "GL3"
elif defined(nvgGLES2):
  const GLVersion* = "GLES2"
elif defined(nvgGLES3):
  const GLVersion* = "GLES3"
else:
  {.error: "define nvgGL2, nvgGL3, nvgGLES2, or nvgGLES3 (pass -d:... to compile)".}

{.pragma: nvg, header:"nanovg.h", cdecl, importc.}
{.pragma: nvgl, importc, header:"nanovg_gl.h", cdecl.}
{.pragma: nvgType, header:"nanovg.h", importc.}

import os
const ThisPath* = currentSourcePath.splitPath.head

{.passC: " -include\"GL/gl.h\" -include\"nanovg.h\" -include\"nanovg/load_glex.h\"".}
{.passC: "-DNANOVG_"&GLVersion&"_IMPLEMENTATION".}
{.passC: "-I"&ThisPath&"/nanovg".}
{.compile: ThisPath/"nanovg/nanovg.c"}
{.compile: ThisPath/"nanovg/load_glex.c"}

const
  NVG_PI* = math.PI#3.141592653589793

  # Flag indicating if geometry based anti-aliasing is used (may not be needed when using MSAA).
  NVG_ANTIALIAS*       = (1 shl 0).cint
  # Flag indicating if strokes should be drawn using stencil buffer. The rendering will be a little
  # slower, but path overlaps (i.e. self-intersecting or sharp turns) will be drawn just once.
  NVG_STENCIL_STROKES* = (1 shl 1).cint
  # Flag indicating that additional debug checks are done.
  NVG_DEBUG*           = (1 shl 2).cint

type
  NVGContext* = distinct pointer

when defined(nvgGL2):
  proc nvgCreate*(flags: cint): NVGcontext {.nvgl, importc: "nvgCreateGL2".}
  proc nvgDelete*(ctx: NVGcontext) {.nvgl, importc: "nvgDeleteGL2".}
  proc nvgCreateImageFromHandle*(ctx: NVGcontext, textureId: GLuint; w, h, flags: cint): cint {.nvgl, importc: "nvglCreateImageFromHandleGL2".}
  proc nvgImageHandle*(ctx: NVGcontext, image: cint): GLuint {.nvgl, importc: "nvglImageHandleGL2".}
elif defined(nvgGL3):
  proc nvgCreate*(flags: cint): NVGcontext {.nvgl, importc: "nvgCreateGL3".}
  proc nvgDelete*(ctx: NVGcontext) {.nvgl, importc: "nvgDeleteGL3".}
  proc nvgCreateImageFromHandle*(ctx: NVGcontext, textureId: GLuint; w, h, flags: cint): cint {.nvgl, importc: "nvglCreateImageFromHandleGL3".}
  proc nvgImageHandle*(ctx: NVGcontext, image: cint): GLuint {.nvgl, importc: "nvglImageHandleGL3".}
elif defined(nvgGLES2):
  proc nvgCreate*(flags: cint): NVGcontext {.nvgl, importc: "nvgCreateGLES2".}
  proc nvgDelete*(ctx: NVGcontext) {.nvgl, importc: "nvgDeleteGLES2".}
  proc nvgCreateImageFromHandle*(ctx: NVGcontext, textureId: GLuint; w, h, flags: cint): cint {.nvgl, importc: "nvglCreateImageFromHandleGLES2".}
  proc nvgImageHandle*(ctx: NVGcontext, image: cint): GLuint {.nvgl, importc: "nvglImageHandleGLES2".}
elif defined(nvgGLES3):
  proc nvgCreate*(flags: cint): NVGcontext {.nvgl, importc: "nvgCreateGLES3".}
  proc nvgDelete*(ctx: NVGcontext) {.nvgl, importc: "nvgDeleteGLES3".}
  proc nvgCreateImageFromHandle*(ctx: NVGcontext, textureId: GLuint; w, h, flags: cint): cint {.nvgl, importc: "nvglCreateImageFromHandleGLES3".}
  proc nvgImageHandle*(ctx: NVGcontext, image: cint): GLuint {.nvgl, importc: "nvglImageHandleGLES3".}

const
  NVG_IMAGE_NODELETE* = 1 shl 16 # Do not delete GL texture handle.

type
  NVGcolor* {.nvgType, byCopy.} = object
    r*: cfloat
    g*: cfloat
    b*: cfloat
    a*: cfloat

  NVGpaint* {.nvgType, byCopy.} = object
    xform*: array[6, cfloat]
    extent*: array[2, cfloat]
    radius*: cfloat
    feather*: cfloat
    innerColor*: NVGcolor
    outerColor*: NVGcolor
    image*: cint

  NVGwinding* = distinct cint

const
  NVG_CCW* = 1.NVGwinding     # Winding for solid shapes
  NVG_CW* = 2.NVGwinding      # Winding for holes

type
  NVGsolidity* = enum
    NVG_SOLID = 1,            # CCW
    NVG_HOLE = 2              # CW

  NVGlineCap* = enum
    NVG_BUTT, NVG_ROUND, NVG_SQUARE, NVG_BEVEL, NVG_MITER

const
  # Horizontal align
  NVG_ALIGN_LEFT* = (1 shl 0).cint     # Default, align text horizontally to left.
  NVG_ALIGN_CENTER* = (1 shl 1).cint   # Align text horizontally to center.
  NVG_ALIGN_RIGHT* = (1 shl 2).cint    # Align text horizontally to right.
  # Vertical align
  NVG_ALIGN_TOP* = (1 shl 3).cint      # Align text vertically to top.
  NVG_ALIGN_MIDDLE* = (1 shl 4).cint   # Align text vertically to middle.
  NVG_ALIGN_BOTTOM* = (1 shl 5).cint   # Align text vertically to bottom.
  NVG_ALIGN_BASELINE* = (1 shl 6).cint # Default, align text vertically to baseline.

const
  NVG_ZERO* = (1 shl 0).cint
  NVG_ONE* = (1 shl 1).cint
  NVG_SRC_COLOR* = (1 shl 2).cint
  NVG_ONE_MINUS_SRC_COLOR* = (1 shl 3).cint
  NVG_DST_COLOR* = (1 shl 4).cint
  NVG_ONE_MINUS_DST_COLOR* = (1 shl 5).cint
  NVG_SRC_ALPHA* = (1 shl 6).cint
  NVG_ONE_MINUS_SRC_ALPHA* = (1 shl 7).cint
  NVG_DST_ALPHA* = (1 shl 8).cint
  NVG_ONE_MINUS_DST_ALPHA* = (1 shl 9).cint
  NVG_SRC_ALPHA_SATURATE* = (1 shl 10).cint

type
  NVGcompositeOperation* = enum
    NVG_SOURCE_OVER
    NVG_SOURCE_IN
    NVG_SOURCE_OUT
    NVG_ATOP
    NVG_DESTINATION_OVER
    NVG_DESTINATION_IN
    NVG_DESTINATION_OUT
    NVG_DESTINATION_ATOP
    NVG_LIGHTER
    NVG_COPY
    NVG_XOR

type
  NVGcompositeOperationState* = object
    srcRGB: cint
    dstRGB: cint
    srcAlpha: cint
    dstAlpha: cint

  NVGglyphPosition* = object
    str*: cstring             # Position of the glyph in the input string.
    x*: cfloat                # The x-coordinate of the logical glyph position.
    minx*: cfloat
    maxx*: cfloat             # The bounds of the glyph shape.

  NVGtextRow* = object
    start*: cstring           # Pointer to the input text where the row starts.
    `end`*: cstring           # Pointer to the input text where the row ends (one past the last character).
    next*: cstring            # Pointer to the beginning of the next row.
    width*: cfloat            # Logical width of the row.
    minx*: cfloat
    maxx*: cfloat             # Actual bounds of the row. Logical with and bounds can differ because of kerning and some parts over extending.

  NVGimageFlags* = enum
    NVG_IMAGE_GENERATE_MIPMAPS = 1 shl 0 # Generate mipmaps during creation of the image.
    NVG_IMAGE_REPEATX = 1 shl 1          # Repeat image in X direction.
    NVG_IMAGE_REPEATY = 1 shl 2          # Repeat image in Y direction.
    NVG_IMAGE_FLIPY = 1 shl 3            # Flips (inverses) image in Y direction when rendered.
    NVG_IMAGE_PREMULTIPLIED = 1 shl 4    # Image data has premultiplied alpha.


# Begin drawing a new frame
# Calls to nanovg drawing API should be wrapped in nvgBeginFrame() & nvgEndFrame()
# nvgBeginFrame() defines the size of the window to render to in relation currently
# set viewport (i.e. glViewport on GL backends). Device pixel ration allows to
# control the rendering on Hi-DPI devices.
# For example, GLFW returns two dimension for an opened window: window size and
# frame buffer size. In that case you would set windowWidth/Height to the window size
# devicePixelRatio to: frameBufferWidth / windowWidth.
proc nvgBeginFrame*(ctx: NVGContext; windowWidth, windowHeight: cint; devicePixelRatio: cfloat) {.nvg.}

# Cancels drawing the current frame.
proc nvgCancelFrame*(ctx: NVGContext) {.nvg.}

# Ends drawing flushing remaining render state.
proc nvgEndFrame*(ctx: NVGContext) {.nvg.}


# Composite operation
#
# The composite operations in NanoVG are modeled after HTML Canvas API, and
# the blend func is based on OpenGL (see corresponding manuals for more info).
# The colors in the blending state have premultiplied alpha.

# Sets the composite operation. The op parameter should be one of NVGcompositeOperation.
proc nvgGlobalCompositeOperation*(ctx: NVGContext, op: cint) {.nvg.}

# Sets the composite operation with custom pixel arithmetic. The parameters should be one of NVGblendFactor.
proc nvgGlobalCompositeBlendFunc*(ctx: NVGContext, sfactor, dfactor: cint) {.nvg.}

# Sets the composite operation with custom pixel arithmetic for RGB and alpha components separately. The parameters should be one of NVGblendFactor.
proc nvgGlobalCompositeBlendFuncSeparate*(ctx: NVGContext, srcRGB, dstRGB, srcAlpha, dstAlpha: cint) {.nvg.}

# Color utils
#
# Colors in NanoVG are stored as unsigned ints in ABGR format.
# Returns a color value from red, green, blue values. Alpha will be set to 255 (1.0f).
proc nvgRGB*(r, g, b: cuchar): NVGcolor {.nvg.}

# Returns a color value from red, green, blue values. Alpha will be set to 1.0f.
proc nvgRGBf*(r, g, b: cfloat): NVGcolor {.nvg.}

# Returns a color value from red, green, blue and alpha values.
proc nvgRGBA*(r, g, b, a: uint8): NVGcolor {.nvg.}

# Returns a color value from red, green, blue and alpha values.
proc nvgRGBAf*(r, g, b, a: cfloat): NVGcolor {.nvg.}

# Linearly interpolates from color c0 to c1, and returns resulting color value.
proc nvgLerpRGBA*(c0: NVGcolor; c1: NVGcolor; u: cfloat): NVGcolor {.nvg.}

# Sets transparency of a color value.
proc nvgTransRGBA*(c0: NVGcolor; a: cuchar): NVGcolor {.nvg.}

# Sets transparency of a color value.
proc nvgTransRGBAf*(c0: NVGcolor; a: cfloat): NVGcolor {.nvg.}

# Returns color value specified by hue, saturation and lightness.
# HSL values are all in range [0..1], alpha will be set to 255.
proc nvgHSL*(H, S, L: cfloat): NVGcolor {.nvg.}

# Returns color value specified by hue, saturation and lightness and alpha.
# HSL values are all in range [0..1], alpha in range [0..255]
proc nvgHSLA*(H, S, L: cfloat; a: cuchar): NVGcolor {.nvg.}


# State Handling
#
# NanoVG contains state which represents how paths will be rendered.
# The state contains transform, fill and stroke styles, text and font styles,
# and scissor clipping.
# Pushes and saves the current render state into a state stack.
# A matching nvgRestore() must be used to restore the state.
proc nvgSave*(ctx: NVGContext) {.nvg.}

# Pops and restores current render state.
proc nvgRestore*(ctx: NVGContext) {.nvg.}

# Resets current render state to default values. Does not affect the render state stack.
proc nvgReset*(ctx: NVGContext) {.nvg.}


# Render styles
#
# Fill and stroke render style can be either a solid color or a paint which is a gradient or a pattern.
# Solid color is simply defined as a color value, different kinds of paints can be created
# using nvgLinearGradient(), nvgBoxGradient(), nvgRadialGradient() and nvgImagePattern().
#
# Current render style can be saved and restored using nvgSave() and nvgRestore().

# Sets whether to draw antialias for nvgStroke() and nvgFill(). It's enabled by default.
proc nvgShapeAntiAlias*(ctx: NVGcontext, enabled: cint) {.nvg.}

# Sets current stroke style to a solid color.
proc nvgStrokeColor*(ctx: NVGContext; color: NVGcolor) {.nvg.}

# Sets current stroke style to a paint, which can be a one of the gradients or a pattern.
proc nvgStrokePaint*(ctx: NVGContext; paint: NVGpaint) {.nvg.}

# Sets current fill style to a solid color.
proc nvgFillColor*(ctx: NVGContext; color: NVGcolor) {.nvg.}

# Sets current fill style to a paint, which can be a one of the gradients or a pattern.
proc nvgFillPaint*(ctx: NVGContext; paint: NVGpaint) {.nvg.}

# Sets the miter limit of the stroke style.
# Miter limit controls when a sharp corner is beveled.
proc nvgMiterLimit*(ctx: NVGContext; limit: cfloat) {.nvg.}

# Sets the stroke width of the stroke style.
proc nvgStrokeWidth*(ctx: NVGContext; size: cfloat) {.nvg.}

# Sets how the end of the line (cap) is drawn,
# Can be one of: NVG_BUTT (default), NVG_ROUND, NVG_SQUARE.
proc nvgLineCap*(ctx: NVGContext; cap: cint) {.nvg.}

# Sets how sharp path corners are drawn.
# Can be one of NVG_MITER (default), NVG_ROUND, NVG_BEVEL.
proc nvgLineJoin*(ctx: NVGContext; join: cint) {.nvg.}

# Sets the transparency applied to all rendered shapes.
# Already transparent paths will get proportionally more transparent as well.
proc nvgGlobalAlpha*(ctx: NVGContext; alpha: cfloat) {.nvg.}


# Transforms
#
# The paths, gradients, patterns and scissor region are transformed by an transformation
# matrix at the time when they are passed to the API.
# The current transformation matrix is a affine matrix:
#   [sx kx tx]
#   [ky sy ty]
#   [ 0  0  1]
# Where: sx,sy define scaling, kx,ky skewing, and tx,ty translation.
# The last row is assumed to be 0,0,1 and is not stored.
#
# Apart from nvgResetTransform(), each transformation function first creates
# specific transformation matrix and pre-multiplies the current transformation by it.
#
# Current coordinate system (transformation) can be saved and restored using nvgSave() and nvgRestore().

# Resets current transform to a identity matrix.
proc nvgResetTransform*(ctx: NVGContext) {.nvg.}

# Premultiplies current coordinate system by specified matrix.
# The parameters are interpreted as matrix as follows:
#   [a c e]
#   [b d f]
#   [0 0 1]
proc nvgTransform*(ctx: NVGContext; a, b, c, d, e, f: cfloat) {.nvg.}

# Translates current coordinate system.
proc nvgTranslate*(ctx: NVGContext; x, y: cfloat) {.nvg.}

# Rotates current coordinate system. Angle is specified in radians.
proc nvgRotate*(ctx: NVGContext; angle: cfloat) {.nvg.}

# Skews the current coordinate system along X axis. Angle is specified in radians.
proc nvgSkewX*(ctx: NVGContext; angle: cfloat) {.nvg.}

# Skews the current coordinate system along Y axis. Angle is specified in radians.
proc nvgSkewY*(ctx: NVGContext; angle: cfloat) {.nvg.}

# Scales the current coordinate system.
proc nvgScale*(ctx: NVGContext; x, y: cfloat) {.nvg.}

# Stores the top part (a-f) of the current transformation matrix in to the specified buffer.
#   [a c e]
#   [b d f]
#   [0 0 1]
# There should be space for 6 floats in the return buffer for the values a-f.
proc nvgCurrentTransform*(ctx: NVGContext; xform: ptr cfloat) {.nvg.}

# The following functions can be used to make calculations on 2x3 transformation matrices.
# A 2x3 matrix is represented as float[6].
# Sets the transform to identity matrix.
proc nvgTransformIdentity*(dst: ptr cfloat) {.nvg.}

# Sets the transform to translation matrix matrix.
proc nvgTransformTranslate*(dst: ptr cfloat; tx: cfloat; ty: cfloat) {.nvg.}

# Sets the transform to scale matrix.
proc nvgTransformScale*(dst: ptr cfloat; sx: cfloat; sy: cfloat) {.nvg.}

# Sets the transform to rotate matrix. Angle is specified in radians.
proc nvgTransformRotate*(dst: ptr cfloat; a: cfloat) {.nvg.}

# Sets the transform to skew-x matrix. Angle is specified in radians.
proc nvgTransformSkewX*(dst: ptr cfloat; a: cfloat) {.nvg.}

# Sets the transform to skew-y matrix. Angle is specified in radians.
proc nvgTransformSkewY*(dst: ptr cfloat; a: cfloat) {.nvg.}

# Sets the transform to the result of multiplication of two transforms, of A = A*B.
proc nvgTransformMultiply*(dst: ptr cfloat; src: ptr cfloat) {.nvg.}

# Sets the transform to the result of multiplication of two transforms, of A = B*A.
proc nvgTransformPremultiply*(dst: ptr cfloat; src: ptr cfloat) {.nvg.}

# Sets the destination to inverse of specified transform.
# Returns 1 if the inverse could be calculated, else 0.
proc nvgTransformInverse*(dst: ptr cfloat; src: ptr cfloat): cint {.nvg.}

# Transform a point by given transform.
proc nvgTransformPoint*(dstx, dsty, xform: ptr cfloat; srcx, srcy: cfloat) {.nvg.}

# Converts degrees to radians and vice versa.
proc nvgDegToRad*(deg: cfloat): cfloat {.nvg.}
proc nvgRadToDeg*(rad: cfloat): cfloat {.nvg.}

# Images
#
# NanoVG allows you to load jpg, png, psd, tga, pic and gif files to be used for rendering.
# In addition you can upload your own image. The image loading is provided by stb_image.
# The parameter imageFlags is combination of flags defined in NVGimageFlags.
# Creates image by loading it from the disk from specified file name.

# Returns handle to the image.
proc nvgCreateImage*(ctx: NVGContext; filename: cstring; imageFlags: cint): cint {.nvg.}

# Creates image by loading it from the specified chunk of memory.
# Returns handle to the image.
proc nvgCreateImageMem*(ctx: NVGContext; imageFlags: cint; data: ptr cuchar;  ndata: cint): cint {.nvg.}

# Creates image from specified image data.
# Returns handle to the image.
proc nvgCreateImageRGBA*(ctx: NVGContext; w, h, imageFlags: cint; data: ptr cuchar): cint {.nvg.}

# Updates image data specified by image handle.
proc nvgUpdateImage*(ctx: NVGContext; image: cint; data: ptr cuchar) {.nvg.}

# Returns the dimensions of a created image.
proc nvgImageSize*(ctx: NVGContext; image: cint; w: var cint; h: var cint) {.nvg.}

# Deletes created image.
proc nvgDeleteImage*(ctx: NVGContext; image: cint) {.nvg.}


# Paints
#
# NanoVG supports four types of paints: linear gradient, box gradient, radial gradient and image pattern.
# These can be used as paints for strokes and fills.
# Creates and returns a linear gradient. Parameters (sx,sy)-(ex,ey) specify the start and end coordinates
# of the linear gradient, icol specifies the start color and ocol the end color.
# The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
proc nvgLinearGradient*(ctx: NVGContext; sx, sy, ex, ey: cfloat; icol, ocol: NVGcolor): NVGpaint {.nvg.}

# Creates and returns a box gradient. Box gradient is a feathered rounded rectangle, it is useful for rendering
# drop shadows or highlights for boxes. Parameters (x,y) define the top-left corner of the rectangle,
# (w,h) define the size of the rectangle, r defines the corner radius, and f feather. Feather defines how blurry
# the border of the rectangle is. Parameter icol specifies the inner color and ocol the outer color of the gradient.
# The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
proc nvgBoxGradient*(ctx: NVGContext; x, y, w, h, r, f: cfloat; icol, ocol: NVGcolor): NVGpaint {.nvg.}

# Creates and returns a radial gradient. Parameters (cx,cy) specify the center, inr and outr specify
# the inner and outer radius of the gradient, icol specifies the start color and ocol the end color.
# The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
proc nvgRadialGradient*(ctx: NVGContext; cx, cy, inr, outr: cfloat; icol, ocol: NVGcolor): NVGpaint {.nvg.}

# Creates and returns an image patter. Parameters (ox,oy) specify the left-top location of the image pattern,
# (ex,ey) the size of one image, angle rotation around the top-left corner, image is handle to the image to render.
# The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
proc nvgImagePattern*(ctx: NVGContext; ox, oy, ex, ey, angle: cfloat; image: cint; alpha: cfloat): NVGpaint {.nvg.}

# Scissoring
#
# Scissoring allows you to clip the rendering into a rectangle. This is useful for various
# user interface cases like rendering a text edit or a timeline.
# Sets the current scissor rectangle.
# The scissor rectangle is transformed by the current transform.
proc nvgScissor*(ctx: NVGContext; x, y, w, h: cfloat) {.nvg.}

# Intersects current scissor rectangle with the specified rectangle.
# The scissor rectangle is transformed by the current transform.
# Note: in case the rotation of previous scissor rect differs from
# the current one, the intersection will be done between the specified
# rectangle and the previous scissor rectangle transformed in the current
# transform space. The resulting shape is always rectangle.
proc nvgIntersectScissor*(ctx: NVGContext; x, y, w, h: cfloat) {.nvg.}

# Reset and disables scissoring.
proc nvgResetScissor*(ctx: NVGContext) {.nvg.}

# Paths
#
# Drawing a new shape starts with nvgBeginPath(), it clears all the currently defined paths.
# Then you define one or more paths and sub-paths which describe the shape. The are functions
# to draw common shapes like rectangles and circles, and lower level step-by-step functions,
# which allow to define a path curve by curve.
#
# NanoVG uses even-odd fill rule to draw the shapes. Solid shapes should have counter clockwise
# winding and holes should have counter clockwise order. To specify winding of a path you can
# call nvgPathWinding(). This is useful especially for the common shapes, which are drawn CCW.
#
# Finally you can fill the path using current fill style by calling nvgFill(), and stroke it
# with current stroke style by calling nvgStroke().
#
# The curve segments and sub-paths are transformed by the current transform.

# Clears the current path and sub-paths.
proc nvgBeginPath*(ctx: NVGContext) {.nvg.}

# Starts new sub-path with specified point as first point.
proc nvgMoveTo*(ctx: NVGContext; x, y: cfloat) {.nvg.}

# Adds line segment from the last point in the path to the specified point.
proc nvgLineTo*(ctx: NVGContext; x, y: cfloat) {.nvg.}

# Adds cubic bezier segment from last point in the path via two control points to the specified point.
proc nvgBezierTo*(ctx: NVGContext; c1x, c1y, c2x, c2y, x, y: cfloat) {.nvg.}

# Adds quadratic bezier segment from last point in the path via a control point to the specified point.
proc nvgQuadTo*(ctx: NVGContext; cx, cy, x, y: cfloat) {.nvg.}

# Adds an arc segment at the corner defined by the last path point, and two specified points.
proc nvgArcTo*(ctx: NVGContext; x1, y1, x2, y2, radius: cfloat) {.nvg.}

# Closes current sub-path with a line segment.
proc nvgClosePath*(ctx: NVGContext) {.nvg.}

# Sets the current sub-path winding, see NVGwinding and NVGsolidity.
proc nvgPathWinding*(ctx: NVGContext; dir: cint) {.nvg.}

# Creates new circle arc shaped sub-path. The arc center is at cx,cy, the arc radius is r,
# and the arc is drawn from angle a0 to a1, and swept in direction dir (NVG_CCW, or NVG_CW).
# Angles are specified in radians.
proc nvgArc*(ctx: NVGContext; cx, cy, r, a0, a1: cfloat; dir: NVGwinding) {.nvg.}

# Creates new rectangle shaped sub-path.
proc nvgRect*(ctx: NVGContext; x, y, w, h: cfloat) {.nvg.}

# Creates new rounded rectangle shaped sub-path.
proc nvgRoundedRect*(ctx: NVGContext; x, y, w, h, r: cfloat) {.nvg.}

# Creates new rounded rectangle shaped sub-path with varying radii for each corner.
proc nvgRoundedRectVarying*(ctx: NVGcontext, x, y, w, h, radTopLeft, radTopRight, radBottomRight, radBottomLeft: cfloat) {.nvg.}

# Creates new ellipse shaped sub-path.
proc nvgEllipse*(ctx: NVGContext; cx, cy, rx, ry: cfloat) {.nvg.}

# Creates new circle shaped sub-path.
proc nvgCircle*(ctx: NVGContext; cx, cy, r: cfloat) {.nvg.}
# Fills the current path with current fill style.

proc nvgFill*(ctx: NVGContext) {.nvg.}
# Fills the current path with current stroke style.

proc nvgStroke*(ctx: NVGContext) {.nvg.}

proc nvgStroke*(ctx: NVGContext, r, g, b, a, strokeWidth: cfloat) =
  ctx.nvgStrokeWidth(strokeWidth)
  ctx.nvgStrokeColor(nvgRGBAf(r, g ,b ,a))
  ctx.nvgStroke()

# Text
#
# NanoVG allows you to load .ttf files and use the font to render text.
#
# The appearance of the text can be defined by setting the current text style
# and by specifying the fill color. Common text and font settings such as
# font size, letter spacing and text align are supported. Font blur allows you
# to create simple text effects such as drop shadows.
#
# At render time the font face can be set based on the font handles or name.
#
# Font measure functions return values in local space, the calculations are
# carried in the same resolution as the final rendering. This is done because
# the text glyph positions are snapped to the nearest pixels sharp rendering.
#
# The local space means that values are not rotated or scale as per the current
# transformation. For example if you set font size to 12, which would mean that
# line height is 16, then regardless of the current scaling and rotation, the
# returned line height is always 16. Some measures may vary because of the scaling
# since aforementioned pixel snapping.
#
# While this may sound a little odd, the setup allows you to always render the
# same way regardless of scaling. I.e. following works regardless of scaling:
#
#   const char* txt = "Text me up.";
#   nvgTextBounds(vg, x,y, txt, NULL, bounds);
#   nvgBeginPath(vg);
#   nvgRoundedRect(vg, bounds[0],bounds[1], bounds[2]-bounds[0], bounds[3]-bounds[1]);
#   nvgFill(vg);
#
# Note: currently only solid color fill is supported for text.
# Creates font by loading it from the disk from specified file name.

# Returns handle to the font.
proc nvgCreateFont*(ctx: NVGContext; name: cstring; filename: cstring): cint {.nvg.}

# Creates image by loading it from the specified memory chunk.
# Returns handle to the font.
proc nvgCreateFontMem*(ctx: NVGContext; name: cstring; data: ptr cuchar; ndata, freeData: cint): cint {.nvg.}

# Finds a loaded font of specified name, and returns handle to it, or -1 if the font is not found.
proc nvgFindFont*(ctx: NVGContext; name: cstring): cint {.nvg.}

# Adds a fallback font by handle.
proc nvgAddFallbackFontId*(ctx: NVGcontext, baseFont, fallbackFont: cint): cint {.nvg.}

# Adds a fallback font by name.
proc nvgAddFallbackFont*(ctx: NVGcontext, baseFont, fallbackFont: cstring): cint {.nvg.}

# Sets the font size of current text style.
proc nvgFontSize*(ctx: NVGContext; size: cfloat) {.nvg.}

# Sets the blur of current text style.
proc nvgFontBlur*(ctx: NVGContext; blur: cfloat) {.nvg.}

# Sets the letter spacing of current text style.
proc nvgTextLetterSpacing*(ctx: NVGContext; spacing: cfloat) {.nvg.}

# Sets the proportional line height of current text style. The line height is specified as multiple of font size.
proc nvgTextLineHeight*(ctx: NVGContext; lineHeight: cfloat) {.nvg.}

# Sets the text align of current text style, see NVGalign for options.
proc nvgTextAlign*(ctx: NVGContext; align: cint) {.nvg.}

# Sets the font face based on specified id of current text style.
proc nvgFontFaceId*(ctx: NVGContext; font: cint) {.nvg.}

# Sets the font face based on specified name of current text style.
proc nvgFontFace*(ctx: NVGContext; font: cstring) {.nvg.}

# Draws text string at specified location. If end is specified only the sub-string up to the end is drawn.
proc nvgText*(ctx: NVGContext; x, y: cfloat; str, strEnd: cstring): cfloat {.nvg.}

# Draws multi-line text string at specified location wrapped at the specified width. If end is specified only the sub-string up to the end is drawn.
# White space is stripped at the beginning of the rows, the text is split at word boundaries or when new-line characters are encountered.
# Words longer than the max width are slit at nearest character (i.e. no hyphenation).
proc nvgTextBox*(ctx: NVGContext; x, y, breakRowWidth: cfloat; str, strEnd: cstring) {.nvg.}

# Measures the specified text string. Parameter bounds should be a pointer to float[4],
# if the bounding box of the text should be returned. The bounds value are [xmin,ymin, xmax,ymax]
# Returns the horizontal advance of the measured text (i.e. where the next character should drawn).
# Measured values are returned in local coordinate space.
proc nvgTextBounds*(ctx: NVGContext; x, y: cfloat; str, strEnd: cstring; bounds: ptr cfloat): cfloat {.nvg.}

# Measures the specified multi-text string. Parameter bounds should be a pointer to float[4],
# if the bounding box of the text should be returned. The bounds value are [xmin,ymin, xmax,ymax]
# Measured values are returned in local coordinate space.
proc nvgTextBoxBounds*(ctx: NVGContext; x, y, breakRowWidth: cfloat; str, strEnd: cstring; bounds: ptr cfloat) {.nvg.}

# Calculates the glyph x positions of the specified text. If end is specified only the sub-string will be used.
# Measured values are returned in local coordinate space.
proc nvgTextGlyphPositions*(ctx: NVGContext; x, y: cfloat; str, strEnd: cstring;
                            positions: ptr NVGglyphPosition; maxPositions: cint): cint {.nvg.}

# Returns the vertical metrics based on the current text style.
# Measured values are returned in local coordinate space.
proc nvgTextMetrics*(ctx: NVGContext; ascender, descender, lineh: var cfloat) {.nvg.}

# Breaks the specified text into lines. If end is specified only the sub-string will be used.
# White space is stripped at the beginning of the rows, the text is split at word boundaries or when new-line characters are encountered.
# Words longer than the max width are slit at nearest character (i.e. no hyphenation).
proc nvgTextBreakLines*(ctx: NVGContext; str, strEnd: cstring;
                        breakRowWidth: cfloat; rows: ptr NVGtextRow;
                        maxRows: cint): cint {.nvg.}


# Internal Render API
#
type
  NVGtexture* = enum
    NVG_TEXTURE_ALPHA = 0x00000001, NVG_TEXTURE_RGBA = 0x00000002

  NVGscissor* = object
    xform*: array[6, cfloat]
    extent*: array[2, cfloat]

  NVGvertex* = object
    x*: cfloat
    y*: cfloat
    u*: cfloat
    v*: cfloat

  NVGpath* = object
    first*: cint
    count*: cint
    closed*: cuchar
    nbevel*: cint
    fill*: ptr NVGvertex
    nfill*: cint
    stroke*: ptr NVGvertex
    nstroke*: cint
    winding*: cint
    convex*: cint

  NVGparams* = object
    userPtr*: pointer
    edgeAntiAlias*: cint
    renderCreate*: proc (uptr: pointer): cint
    renderCreateTexture*: proc (uptr: pointer; typ, w, h, imageFlags: cint; data: ptr cuchar): cint
    renderDeleteTexture*: proc (uptr: pointer; image: cint): cint
    renderUpdateTexture*: proc (uptr: pointer; image, x, y, w, h, data: ptr cuchar): cint
    renderGetTextureSize*: proc (uptr: pointer; image: cint; w, h: var cint): cint
    renderViewport*: proc (uptr: pointer; width, height: cint)
    renderCancel*: proc (uptr: pointer)
    renderFlush*: proc (uptr: pointer)
    renderFill*: proc (uptr: pointer; paint: ptr NVGpaint;
                       scissor: ptr NVGscissor; fringe: cfloat;
                       bounds: ptr cfloat; paths: ptr NVGpath; npaths: cint)
    renderStroke*: proc (uptr: pointer; paint: ptr NVGpaint;
                         scissor: ptr NVGscissor; fringe: cfloat;
                         strokeWidth: cfloat; paths: ptr NVGpath; npaths: cint)
    renderTriangles*: proc (uptr: pointer; paint: ptr NVGpaint;
                            scissor: ptr NVGscissor; verts: ptr NVGvertex;
                            nverts: cint)
    renderDelete*: proc (uptr: pointer)

# Constructor and destructor, called by the render back-end.
proc nvgCreateInternal*(params: ptr NVGparams): NVGcontext {.nvg.}
proc nvgDeleteInternal*(ctx: NVGContext) {.nvg.}
proc nvgInternalParams*(ctx: NVGContext): ptr NVGparams {.nvg.}

# Debug function to dump cached path data.
proc nvgDebugDumpPathCache*(ctx: NVGContext) {.nvg.}
