;;; simple-demo.el --- zk_phi

(defvar simple-demo-highlight-regexp nil)
(defvar simple-demo-highlight-face 'highlight)

(defvar simple-demo-main-pane nil)
(defvar simple-demo-main-size 6)

(defvar simple-demo-echo-pane nil)
(defvar simple-demo-echo-size 5)

;;;###autoload
(defun simple-demo-set-up ()
  (interactive)
  ;; main pane
  (delete-other-windows)
  (switch-to-buffer (if (buffer-live-p simple-demo-main-pane)
                        simple-demo-main-pane
                      (setq simple-demo-main-pane
                            (generate-new-buffer "DEMO/main"))))
  (condition-case err
      (funcall
       (intern
        (concat (read-from-minibuffer "major-mode ? " "lisp-interaction")
                "-mode")))
    (error (message (cadr err))))
  (text-scale-set simple-demo-main-size)
  ;; add echo function to post-command hook
  (setq simple-demo-highlight-regexp
        (read-from-minibuffer "highlight regexp ? "))
  (unless (member 'demo-pre-command-function pre-command-hook)
    (add-hook 'pre-command-hook 'simple-demo-pre-command-function))
  ;; echo pane
  (split-window-vertically (floor (* (window-height) 0.8)))
  (other-window 1)
  (switch-to-buffer (if (buffer-live-p simple-demo-echo-pane)
                        simple-demo-echo-pane
                      (setq simple-demo-echo-pane
                            (generate-new-buffer "DEMO/echo"))))
  (fundamental-mode)
  (text-scale-set simple-demo-echo-size)
  ;; finish set-up
  (other-window -1))

(defun simple-demo-pre-command-function ()
  (let* ((str (format "%s (%s)\n"
                      this-command
                      (key-description (this-single-command-keys))))
         deactivate-mark) ; make "deactivate-mark" local and, save global value
    (when (and (eq (current-buffer) simple-demo-main-pane)
               (buffer-live-p simple-demo-echo-pane))
      (with-current-buffer simple-demo-echo-pane
        (let* ((beg (goto-char (point-min)))
               (end (progn (insert str) (point))))
          (when (and (not (string= simple-demo-highlight-regexp ""))
                     (string-match simple-demo-highlight-regexp str))
            (add-text-properties beg end
                                 `(face ,simple-demo-highlight-face))))))))

(provide 'simple-demo)
