(import scheme
        (chicken base)
        (chicken io)
        (chicken irregex))

(define *replacements*
  `(((: "/*" (*? any) "*/") . "")
    ("#pragma.*\n" . "")
    ("#if.*\n" . "")
    ("#ifndef.*\n" . "")
    ("#elif.*\n" . "")
    ("#else\n" . "")
    ("#endif.*\n" . "")
    ("ptrdiff_t" . ,(cond-expand
                      (x86-64 "int64_t")
                      (else "int32_t")))
    ("typedef unsigned char GLboolean" . "typedef bool GLboolean")
    ("GLAPIENTRY " . "")
    ("APIENTRY " . "")
    ("\n}\n" . "")
    ("#include.*\n" . "")
    ("#define GL_VERSION_.*\n" . "")
    ("#define GL_ES_VERSION_.*\n" . "")
    ("#define GL_SC_VERSION_.*\n" . "")
    ("#define [^G].*\n" . "")
    ("#define GL_.*_[[:lower:]].* 1\n" . "")
    ("KHRONOS_MAX_ENUM" . "0x7FFFFFFF")
    ((: "*const*") . "**")
    ((: newline (*? (or alpha numeric ("()*") space)) "PFNGL" (*? any) eol) . "")
    ("#endif .*\n" . "")
    ("\n\n" . "\n")
    ("EPOXY_PUBLIC " . "")
    ((: "(EPOXY_CALLSPEC *" ($ (+ (~ #\)))) ")") . 1)
    ("epoxy_gl" . "gl")))

(define (gl-translate file)
  (call-with-output-file "gl.h"
    (lambda (output)
      (call-with-input-file file
        (lambda (input)
          (let ([h (read-string #f input)])
            (let loop ((str h) (replacements *replacements*))
              (if (null? replacements)
                  (write-string str #f output)
                  (loop (irregex-replace/all (caar replacements) str
                                             (cdar replacements))
                        (cdr replacements))))))))))

(gl-translate "epoxy/gl_generated.h")
