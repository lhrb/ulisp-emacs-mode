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

(local-set-key (kbd "C-c C-e") 'ulisp-send-lisp-form-to-serial-process)

(defvar ulisp-keymap
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-e") 'ulisp-eval-sexp)
    map))

(defvar ulisp-font-lock-keywords
  `(
    (,(concat "\\("
              (regexp-opt '("nil"
                            "t"
                            "and"
                            "or"
                            "not"
                            "if"
                            "when"
                            "unless"
                            "cond"
                            "case"
                            "let"
                            "let*"
                            "letrec"
                            "setq"
                            "defvar"
                            "defconst"
                            "defun"
                            "lambda"
                            "destructuring-bind"
                            "progn"
                            "prog1"
                            "prog2"
                            "do"
                            "do*"
                            "do-all-symbols"
                            "do-external-symbols"
                            "do-symbols"
                            "dotimes"
                            "dolist"
                            "block"
                            "return"
                            "return-from"
                            "tagbody"
                            "go"
                            "catch"
                            "throw"
                            "unwind-protect"
                            "with-output-to-string"
                            "with-input-from-string"
                            "with-open-file"
                            "with-slots"
                            "with-accessors"))
              "\\)\\>")
     (1 font-lock-keyword-face)))
  "Syntax highlighting for uLisp code.")

(define-derived-mode ulisp-mode lisp-mode "uLisp Mode"
  "Major mode for editing ulisp."
  (setq-local font-lock-defaults '(ulisp-font-lock-keywords))
  (use-local-map ulisp-keymap))

(add-to-list 'auto-mode-alist '("\\.ulisp" . ulisp-mode))
(add-hook 'ulisp-mode-hook 'paredit-mode)

(provide 'ulisp)
;;; ulisp.el ends here
