;; $Id: gears.ss,v 1.36 2002/12/10 06:19:48 neil Exp $
;;
;; This is a version of the venerable "gears" demo for PLT Scheme 200 using
;; Scott Owens' SGL OpenGL bindings.  It was ported from "glxgears.c" 1.3 from
;; XFree86, which had the following notices:
;;
;;     Copyright (C) 1999-2001  Brian Paul   All Rights Reserved.
;;
;;     Permission is hereby granted, free of charge, to any person obtaining a
;;     copy of this software and associated documentation files (the
;;     "Software"), to deal in the Software without restriction, including
;;     without limitation the rights to use, copy, modify, merge, publish,
;;     distribute, sublicense, and/or sell copies of the Software, and to
;;     permit persons to whom the Software is furnished to do so, subject to
;;     the following conditions:
;;
;;     The above copyright notice and this permission notice shall be included
;;     in all copies or substantial portions of the Software.
;;
;;     XFree86: xc/programs/glxgears/glxgears.c,v 1.3 2001/11/03 17:29:20 dawes
;;
;;     This is a port of the infamous "gears" demo to straight GLX (i.e. no
;;     GLUT).  Port by Brian Paul 23 March 2001.
;;
;; To run, evaluate this file in DrScheme, or execute "mred -r gears.ss"
;; from your OS shell.  If your version of SGL is missing "gl:End-list", then
;; add a line "void glEndList( void );" to file "collects/sgl/gl-specs/gl11.h",
;; and execute "setup-plt -l sgl".
;;
;; Scheme port by Neil W. Van Dyke <neil@neilvandyke.org>, 23 November 2002.
;; Originally called glxgears.ss.  Minor modifications since.
;; See "http://www.neilvandyke.org/opengl-plt/" for more information.
;;
;; Ported to Chicken by Felix L. Winkelmann
;; Ported for CHICKEN 5 and the epoxy egg by Adrien (Kooda) Ramos
;
; To compile:
;
; % csc sdl-gears.scm -C "`sdl-config --cflags`" -L "`sdl-config --libs`"


#>
#include <SDL.h>

static SDL_Surface *screen;
<#

(import chicken.foreign)
(import srfi-4 (prefix epoxy gl:))

(define pi 3.14)

(define rotation 0.0)

(define view-rotx 20.0)
(define view-roty 30.0)
(define view-rotz 0.0)

(define gear1 #f)
(define gear2 #f)
(define gear3 #f)

(define step? #f)

(define (refresh)
  (set! step? #t))

(define (move-left)
  (set! view-roty (+ view-roty 5.0)))

(define (move-right)
  (set! view-roty (- view-roty 5.0)))

(define (move-up)
  (set! view-rotx (+ view-rotx 5.0)))

(define (move-down)
  (set! view-rotx (- view-rotx 5.0)))

(define (build-gear inner-radius    ; radius of hole at center
		    outer-radius    ; radius at center of teeth
		    width           ; width of gear
		    teeth           ; number of teeth
		    tooth-depth)    ; depth of tooth
  (let* ((r0             inner-radius)
	 (r1             (- outer-radius (/ tooth-depth 2.0)))
	 (r2             (+ outer-radius (/ tooth-depth 2.0)))
	 (da             (/ (* 2.0 pi) teeth 4.0))
	 (da2            (* da 2))
	 (da3            (* da 3))
	 (half-width     (* width 0.5))
	 (neg-half-width (- half-width)))

    ;; TODO: Generalize away some more redundant program text.

    (gl:shade-model gl:+flat+)

    (gl:normal3f 0.0 0.0 1.0)

    ;; Draw front face.
    (gl:gl-begin gl:+quad-strip+)
    (do ((i 0 (+ 1 i))) ((> i teeth))
      (let* ((angle     (/ (* i 2.0 pi) teeth))
	     (cos-angle (cos angle))
	     (sin-angle (sin angle)))
	(gl:vertex3f (* r0 cos-angle) (* r0 sin-angle) half-width)
	(gl:vertex3f (* r1 cos-angle) (* r1 sin-angle) half-width)
	(when (< i teeth)
	  (gl:vertex3f (* r0 cos-angle)
		       (* r0 sin-angle)
		       (* half-width))
	  (gl:vertex3f (* r1 (cos (+ angle da3)))
		       (* r1 (sin (+ angle da3)))
		       half-width))))
    (gl:end)

    ;; Draw front sides of teeth.
    (gl:gl-begin gl:+quads+)
    (do ((i 0 (+ 1 i))) ((= i teeth))
      (let ((angle (/ (* i 2.0 pi) teeth)))
	(gl:vertex3f (* r1 (cos angle))
		     (* r1 (sin angle))
		     half-width)
	(gl:vertex3f (* r2 (cos (+ angle da)))
		     (* r2 (sin (+ angle da)))
		     half-width)
	(gl:vertex3f (* r2 (cos (+ angle da2)))
		     (* r2 (sin (+ angle da2)))
		     half-width)
	(gl:vertex3f (* r1 (cos (+ angle da3)))
		     (* r1 (sin (+ angle da3)))
		     half-width)))
    (gl:end)

    (gl:normal3f 0.0 0.0 -1.0)

    ;; Draw back face.
    (gl:gl-begin gl:+quad-strip+)
    (do ((i 0 (+ 1 i))) ((> i teeth))
      (let* ((angle     (/ (* i 2.0 pi) teeth))
	     (cos-angle (cos angle))
	     (sin-angle (sin angle)))
	(gl:vertex3f (* r1 cos-angle) (* r1 sin-angle) neg-half-width)
	(gl:vertex3f (* r0 cos-angle) (* r0 sin-angle) neg-half-width)
	(when (< i teeth)
	  (gl:vertex3f (* r1 (cos (+ angle da3)))
		       (* r1 (sin (+ angle da3)))
		       neg-half-width)
	  (gl:vertex3f (* r0 cos-angle)
		       (* r0 sin-angle)
		       neg-half-width))))
    (gl:end)

    ;; Draw back sides of teeth.
    (gl:gl-begin gl:+quads+)
    (do ((i 0 (+ 1 i))) ((= i teeth))
      (let ((angle (/ (* i 2.0 pi) teeth)))
	(gl:vertex3f (* r1 (cos (+ angle da3)))
		     (* r1 (sin (+ angle da3)))
		     neg-half-width)
	(gl:vertex3f (* r2 (cos (+ angle da2)))
		     (* r2 (sin (+ angle da2)))
		     neg-half-width)
	(gl:vertex3f (* r2 (cos (+ angle da)))
		     (* r2 (sin (+ angle da)))
		     neg-half-width)
	(gl:vertex3f (* r1 (cos angle))
		     (* r1 (sin angle))
		     neg-half-width)))
    (gl:end)

    ;; Draw outward faces of teeth.
    (gl:gl-begin gl:+quad-strip+)
    (do ((i 0 (+ 1 i))) ((= i teeth))
      (let* ((angle     (/ (* i 2.0 pi) teeth))
	     (cos-angle (cos angle))
	     (sin-angle (sin angle)))

	(gl:vertex3f (* r1 cos-angle) (* r1 sin-angle) half-width)
	(gl:vertex3f (* r1 cos-angle) (* r1 sin-angle) neg-half-width)

	(let* ((u   (- (* r2 (cos (+ angle da))) (* r1 cos-angle)))
	       (v   (- (* r2 (sin (+ angle da))) (* r1 sin-angle)))
	       (len (sqrt (+ (* u u) (* v v)))))
	  (gl:normal3f (/ v len) (- (/ u len)) 0.0))

	(gl:vertex3f (* r2 (cos (+ angle da)))
		     (* r2 (sin (+ angle da)))
		     half-width)
	(gl:vertex3f (* r2 (cos (+ angle da)))
		     (* r2 (sin (+ angle da)))
		     neg-half-width)
	(gl:normal3f cos-angle sin-angle 0.0)
	(gl:vertex3f (* r2 (cos (+ angle da2)))
		     (* r2 (sin (+ angle da2)))
		     half-width)
	(gl:vertex3f (* r2 (cos (+ angle da2)))
		     (* r2 (sin (+ angle da2)))
		     neg-half-width)

	(let ((u (- (* r1 (cos (+ angle da3)))
		    (* r2 (cos (+ angle da2)))))
	      (v (- (* r1 (sin (+ angle da3)))
		    (* r2 (sin (+ angle da2))))))
	  (gl:normal3f v (- u) 0.0))

	(gl:vertex3f (* r1 (cos (+ angle da3)))
		     (* r1 (sin (+ angle da3)))
		     half-width)
	(gl:vertex3f (* r1 (cos (+ angle da3)))
		     (* r1 (sin (+ angle da3)))
		     neg-half-width)
	(gl:normal3f cos-angle sin-angle 0.0)))

    (gl:vertex3f (* r1 (cos 0)) (* r1 (sin 0)) half-width)
    (gl:vertex3f (* r1 (cos 0)) (* r1 (sin 0)) neg-half-width)
    (gl:end)

    (gl:shade-model gl:+smooth+)

    ;; Draw inside radius cylinder.
    (gl:gl-begin gl:+quad-strip+)
    (do ((i 0 (+ 1 i))) ((> i teeth))
      (let* ((angle     (/ (* i 2.0 pi) teeth))
	     (cos-angle (cos angle))
	     (sin-angle (sin angle)))
	(gl:normal3f (- cos-angle) (- sin-angle) 0.0)
	(gl:vertex3f (* r0 cos-angle) (* r0 sin-angle) neg-half-width)
	(gl:vertex3f (* r0 cos-angle) (* r0 sin-angle) half-width)))
    (gl:end)))

(define (on-size width height)
  (gl:viewport 0 0 width height)
  (gl:matrix-mode gl:+projection+)
  (gl:load-identity)
  (let ((h (/ height width)))
    (gl:frustum -1.0 1.0 (- h) h 5.0 60.0))
  (gl:matrix-mode gl:+modelview+)
  (gl:load-identity)
  (gl:translatef 0.0 0.0 -40.0)

  (gl:lightfv gl:+light0+ gl:+position+ (f32vector 5.0 5.0 10.0 0.0))
  (gl:enable gl:+cull-face+)
  (gl:enable gl:+lighting+)
  (gl:enable gl:+light0+)
  (gl:enable gl:+depth-test+)

  (unless gear1

    (set! gear1 (gl:gen-lists 1))
    (gl:new-list gear1 gl:+compile+)
    (gl:materialfv gl:+front+
		   gl:+ambient-and-diffuse+
		   (f32vector 0.8 0.1 0.0 1.0))
    (build-gear 1.0 4.0 1.0 20 0.7)
    (gl:end-list)

    (set! gear2 (gl:gen-lists 1))
    (gl:new-list gear2 gl:+compile+)
    (gl:materialfv gl:+front+
		   gl:+ambient-and-diffuse+
		   (f32vector 0.0 0.8 0.2 1.0))
    (build-gear 0.5 2.0 2.0 10 0.7)
    (gl:end-list)

    (set! gear3 (gl:gen-lists 1))
    (gl:new-list gear3 gl:+compile+)
    (gl:materialfv gl:+front+
		   gl:+ambient-and-diffuse+
		   (f32vector 0.2 0.2 1.0 1.0))
    (build-gear 1.3 2.0 0.5 10 0.7)
    (gl:end-list)

    (gl:enable gl:+normalize+)) )

(define (on-paint)
  ;; TODO: Add FPS instrumentation.
  (when step?
    ;; TODO: Don't increment this infinitely.
    (set! rotation (+ 2.0 rotation)))

  (gl:clear (+ gl:+color-buffer-bit+ gl:+depth-buffer-bit+))
  
  (gl:push-matrix)
  (gl:rotatef view-rotx 1.0 0.0 0.0)
  (gl:rotatef view-roty 0.0 1.0 0.0)
  (gl:rotatef view-rotz 0.0 0.0 1.0)

  (gl:push-matrix)
  (gl:translatef -3.0 -2.0 0.0)
  (gl:rotatef rotation 0.0 0.0 1.0)
  (gl:call-list gear1)
  (gl:pop-matrix)

  (gl:push-matrix)
  (gl:translatef 3.1 -2.0 0.0)
  (gl:rotatef (- (* -2.0 rotation) 9.0) 0.0 0.0 1.0)
  (gl:call-list gear2)
  (gl:pop-matrix)

  (gl:push-matrix)
  (gl:translatef -3.1 4.2 0.0)
  (gl:rotatef (- (* -2.0 rotation) 25.0) 0.0 0.0 1.0)
  (gl:call-list gear3)
  (gl:pop-matrix)

  (gl:pop-matrix)
  ((foreign-lambda void "SDL_GL_SwapBuffers")) )

(foreign-code 
 "SDL_Init(SDL_INIT_VIDEO);
 screen = SDL_SetVideoMode(300, 300, 16, SDL_OPENGL|SDL_RESIZABLE);")

(on-size (foreign-value "screen->w" int) (foreign-value "screen->h" int))

(gl:clear-color 0.0 0.0 0.0 0)

(define poll
  (foreign-lambda* bool ()
    "SDL_Event event; return(SDL_PollEvent(&event) && event.type == SDL_QUIT);"))

(do () ((poll))
  (refresh)
  (on-paint) )

((foreign-lambda void "SDL_Quit"))

