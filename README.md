# epoxy

Bindings for the OpenGL and OpenGL ES APIs.

Every version and profile of these APIs are available out of the box thanks to the Epoxy library. The actual version used is automatically determined by the current GL context (which you can obtain from windowing libraries like SDL or GLFW).

This egg is based on Alex Charlton’s previous work on the opengl-glew egg and is a drop-in replacement for it. It also provides the functionnality of the old opengl egg (fixed pipeline).

## Requirements

- bind

## Documentation

All functions and constants from every version of the OpenGL specifications are exported. Scheme style names are provided (underscores and camelCase replaced with hyphens), the `gl` prefix is removed from names, functions starting with `is` instead end in question marks, and constants are bookended by `+`s (e.g. `delete-texture`, `enabled?`, `+arb-viewport-array+`). The terms `1D`, `2D` and `3D` are additionally hyphen separated in order to match their constant counterparts (e.g. `tex-image-2d` and `+texture-2d+`).

Functions whose C counterparts accept or return `GLboolean` accept or return a Scheme boolean value. *Do not* pass `+true+` or `+false+` to these functions.

### Epoxy specific procedures

    [procedure] (has-gl-extension? EXTENSION)

Query whether the OpenGL extension, given as a string, is supported.

    [procedure] (is-desktop-gl?)

Return whether the current context is a regular desktop OpenGL one (#t), or an OpenGL ES one (#f).

    [procedure] (gl-version)

Return the current context’s OpenGL version as an integer (eg. 20 for 2.0, 43 for 4.3…)

    [procedure] (glsl-version)

Return the current context’s GLSL supported version.

## Example
For numerous examples of this egg’s usage, look at the [gl-utils](https://wiki.call-cc.org/egg/gl-utils) egg, [glls](https://wiki.call-cc.org/egg/glls) egg, or the [noise](https://wiki.call-cc.org/egg/noise) egg.

## Version history
### Version 0.2.0
15 March 2019

* Documentation
* Fix some incorrect identifier renaming

### Version 0.1.0
4 November 2018

* Initial release based on libepoxy 1.5.3

## Source repository
Source available in [a git repository](https://www.upyum.com/cgit.cgi/epoxy).

Bug reports and patches welcome! Bugs can be reported to kooda@upyum.com

## Author
Adrien (Kooda) Ramos

Based on previous work by Alex Charlton.

## Licence
BSD
