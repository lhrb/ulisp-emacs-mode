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

(provide 'ulisp)
;;; ulisp.el ends here
