;;; ulisp.el --- Description -*- lexical-binding: t; -*-
;;
;; Author: Lukas Ottweiler
;; Created: March 06, 2023
;; Modified: March 06, 2023
;; Version: 0.0.1
;; Keywords: ulisp
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:

(require 'inf-lisp)

(defvar ulisp-port-name "/dev/ttyACM0")
(defvar ulisp-port-speed 9600 "Baudrate.")
(defvar ulisp-process-name "ulisp-serial-process")

(defun ulisp-connect (port speed)
  "Connects to a ulisp repl through a serial process.
Creates input and output buffer *ulisp*.
PORT: the serial port default /dev/ttyACM0
SPEED: baudrate default 9600"
  (interactive
   (list ulisp-port-name ulisp-port-speed))
  (with-current-buffer (make-comint-in-buffer "ulisp" "*ulisp*" nil)
    (setq-local inferior-lisp-buffer "*ulisp*")
    (inferior-lisp-mode))
  (make-serial-process
   :name ulisp-process-name
   :buffer "*ulisp*"
   :port port
   :speed speed
   :noquery t)
  (pop-to-buffer "*ulisp*"))

(defun ulisp-eval-sexp ()
  "Send the s-expression before the cursor to the repl."
  (interactive)
  (let ((bounds (bounds-of-thing-at-point 'sexp)))
    (if bounds
        (let ((process (get-process ulisp-process-name)))
          (if (and process (process-live-p process))
              (progn
                (process-send-region process (car bounds) (cdr bounds))
                (sleep-for 0.1)
                (with-current-buffer (process-buffer process)
                  (let ((output (buffer-string)))
                    (message "Received: %s" output)
                    (erase-buffer)
                    (insert output))))
            (message "Serial process not found or not running")))
      (message "No sexp found before the cursor."))))

(defvar ulisp-keymap
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-e") 'ulisp-eval-sexp)
    map))

(defvar ulisp-font-lock-built-in--functions
  '("*"
    "+"
    "-"
    "/"
    "/="
    "1+"
    "1-"
    "<"
    "<="
    "="
    ">"
    ">="
    "abs"
    "analogread"
    "analogreadresolution"
    "analogreference"
    "analogwrite"
    "analogwriteresolution"
    "append"
    "apply"
    "aref"
    "array-dimensions"
    "arrayp"
    "ash"
    "assoc"
    "atom"
    "boundp"
    "break"
    "caaar"
    "caadr"
    "caar"
    "cadar"
    "caddr"
    "cadr"
    "car"
    "cdaar"
    "cdadr"
    "cdar"
    "cddar"
    "cdddr"
    "cddr"
    "cdr"
    "char"
    "char-code"
    "characterp"
    "code-char"
    "concatenate"
    "cons"
    "consp"
    "delay"
    "digitalread"
    "digitalwrite"
    "documentation"
    "edit"
    "eq"
    "eval"
    "evenp"
    "first"
    "for-millis"
    "format"
    "funcall"
    "gc"
    "globals"
    "length"
    "length"
    "list"
    "list-library"
    "listp"
    "load-image"
    "logand"
    "logbitp"
    "logior"
    "lognot"
    "logxor"
    "make-array"
    "makunbound"
    "mapc"
    "mapcan"
    "mapcar"
    "max"
    "member"
    "millis"
    "min"
    "minusp"
    "mod"
    "not"
    "note"
    "nth"
    "null"
    "numberp"
    "oddp"
    "pinmode"
    "plusp"
    "pprint"
    "pprintall"
    "prin1"
    "prin1-to-string"
    "princ"
    "princ-to-string"
    "print"
    "random"
    "read"
    "read-byte"
    "read-from-string"
    "read-line"
    "register"
    "require"
    "rest"
    "restart-i2c"
    "reverse"
    "room"
    "save-image"
    "second"
    "set"
    "sleep"
    "sort"
    "streamp"
    "string"
    "string<"
    "string="
    "string>"
    "stringp"
    "subseq"
    "symbolp"
    "terpri"
    "third"
    "with-sd-card"
    "write-byte"
    "write-line"
    "write-string"
    "zerop"))

(defvar ulisp-font-lock-built-in--macros
  '("#'" "#*" "#." "#\\" "#(" "#nA" "#|" "#b" "#o" "#x"))

(defvar ulisp-font-lock-built-in--symbols
  '("nil" "t" "nothing"))

(defvar ulisp-font-lock-built-in--keywords
  '("?" "and" "case" "cond" "decf" "defun" "defvar" "dolist" "dotimes" "if"
    "incf" "lambda" "let" "let*" "loop" "or" "pop" "progn" "push" "quote"
    "return" "setf" "setq" "time" "trace" "unless" "untrace" "when" "with-i2c"
    "with-output-to-string" "with-serial" "with-spi"))

(defvar ulisp-font-lock-defaults
  (list (cons (regexp-opt ulisp-font-lock-built-in--functions 'words) font-lock-builtin-face)
        (cons (regexp-opt (append
                           ulisp-font-lock-built-in--symbols
                           ulisp-font-lock-built-in--keywords
                           ulisp-font-lock-built-in--macros) 'words) font-lock-keyword-face)))

;;;###autoload
(define-derived-mode ulisp-mode lisp-mode "uLisp Mode"
  "Major mode for editing ulisp."
  (font-lock-add-keywords nil ulisp-font-lock-defaults)
  (use-local-map ulisp-keymap))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.ulisp" . ulisp-mode))
(add-hook 'ulisp-mode-hook 'paredit-mode)

(provide 'ulisp)
;;; ulisp.el ends here
