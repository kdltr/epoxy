(module epoxy *
(import (except scheme begin list?)
        (chicken base)
        (chicken foreign)
        (chicken platform)
        bind)

(foreign-declare "#include <epoxy/gl.h>")

(bind-rename/pattern "^GL_([A-Z_].+)$" "+\\1+")
(bind-rename/pattern "([^_])([123])D" "\\1-\\2d")
(bind-rename/pattern "^gl" "")
(bind-rename/pattern "^Is(.*)$" "\\1?")

(bind-options default-renaming: ""
              export-constants: #t)

(bind-file "gl.h")

(define has-gl-extension?
  (foreign-lambda bool "epoxy_has_gl_extension" c-string))

(define is-supported? has-gl-extension?) ;; compatibility with the opengl-glew egg

(define is-desktop-gl?
  (foreign-lambda bool "epoxy_is_desktop_gl"))

(define gl-version
  (foreign-lambda int "epoxy_gl_version"))

(define glsl-version
  (foreign-lambda int "epoxy_glsl_version"))

(let ((pointer->string (foreign-lambda* c-string ((c-pointer p))
                         "C_return((char*) p);"))
      (%get-string get-string)
      (%get-stringi get-stringi))
  (set! get-string
    (lambda (n) (pointer->string (%get-string n))))
  (set! get-stringi
    (lambda (n i) (pointer->string (%get-stringi n i)))))

) ; module end
