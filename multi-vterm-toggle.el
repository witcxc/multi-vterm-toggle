;;; multi-vterm-toggle.el --- Toggle vterm dedicated to current project or directory  -*- lexical-binding: t; -*-

;; Copyright (C) 2024  User Name

;; Author: User Name <user@example.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1") (vterm "0.0.1") (multi-vterm "0.0.1") (project "0.8.1"))
;; Keywords: terminals, convenience, tools
;; URL: https://github.com/username/multi-vterm-toggle

;;; Commentary:

;; This package provides a command to toggle a vterm buffer dedicated to the
;; current context. The context is determined as follows:
;;
;; 1. Git Repository: If inside a project, use the project root.
;; 2. Regular File: Use the file's parent directory.
;; 3. Other: Use the user's home directory.
;;
;; If a vterm buffer for the context exists, it is reused and popped up
;; in a split window. If it is already visible, the window is closed.
;; If it doesn't exist, a new one is created.

;;; Code:

(require 'vterm)
(require 'multi-vterm)
(require 'project)
(require 'cl-lib)

(defgroup multi-vterm-toggle nil
  "Toggle vterm dedicated to current project/directory."
  :group 'tools)

(defcustom multi-vterm-toggle-height 0.4
  "The height of the vterm window when opened (fraction of frame height)."
  :type 'float
  :group 'multi-vterm-toggle)

(defcustom multi-vterm-toggle-use-dedicated-window t
  "If non-nil, set the window parameter to dedicated."
  :type 'boolean
  :group 'multi-vterm-toggle)

(defun multi-vterm-toggle--get-project-root ()
  "Return the current project root, file directory, or home directory."
  (let ((pr (project-current)))
    (expand-file-name
     (cond
      ;; 1. Project/Git root
      (pr (project-root pr))
      ;; 2. Regular file directory
      (buffer-file-name (file-name-directory buffer-file-name))
      ;; 3. Default fallback (Home)
      (t "~/")))))

(defun multi-vterm-toggle--buffer-name (path)
  "Generate a consistent buffer name for the vterm based on PATH."
  (let ((dir-name (file-name-nondirectory (directory-file-name path))))
    (format "*vterm-toggle: %s*" dir-name)))

(defun multi-vterm-toggle--find-existing-buffer (path)
  "Find a vterm buffer associated with PATH based on our naming convention."
  (get-buffer (multi-vterm-toggle--buffer-name path)))

(defun multi-vterm-toggle--create-new (path)
  "Create a new vterm buffer for PATH."
  (let ((default-directory path)
        (buf-name (multi-vterm-toggle--buffer-name path)))
    (save-window-excursion
      (with-current-buffer (vterm buf-name)
        (multi-vterm-internal) ;; Register with multi-vterm if needed
        (current-buffer)))))

;;;###autoload
(defun multi-vterm-toggle ()
  "Toggle a vterm buffer dedicated to the current context.

Context logic:
1. Git Repo -> Project Root
2. File -> Parent Directory
3. Other -> Home Directory

Behavior:
- If currently in a vterm buffer: Hide it.
- If target vterm exists and focused: Hide it (Redundant but safe).
- If target vterm exists but hidden: Show and focus it.
- If target vterm doesn't exist: Create and show it."
  (interactive)
  ;; Priority check: If we are already in a vterm buffer, close it.
  ;; This avoids calculating a new context (which might fallback to Home)
  ;; when the user simply wants to toggle the terminal off.
  (if (and (eq major-mode 'vterm-mode)
           (eq (selected-window) (get-buffer-window (current-buffer))))
      (delete-window)
    
    (let* ((path (multi-vterm-toggle--get-project-root))
           (buf-name (multi-vterm-toggle--buffer-name path))
           (buf (get-buffer buf-name))
           (window (and buf (get-buffer-window buf))))
      
      (cond
       ;; Case 1: Buffer is visible and we are already in it -> Hide it
       ;; (Note: The initial check usually catches this, but kept for robustness)
       ((and window (eq (selected-window) window))
        (delete-window window))
       
       ;; Case 2: Buffer is visible elsewhere -> Focus it
       (window
        (select-window window))
       
       ;; Case 3: Buffer exists but hidden, or needs creation -> Show it
       (t
        (let ((target-buf (or buf (multi-vterm-toggle--create-new path))))
          (let ((display-buffer-alist
                 (cons `(,(regexp-quote buf-name)
                         (display-buffer-below-selected)
                         (window-height . ,(floor (* (frame-height) multi-vterm-toggle-height))))
                       display-buffer-alist)))
            (pop-to-buffer target-buf))
          
          ;; Ensure correct directory for new buffers
          (unless buf
            (vterm-send-string (format "cd %s\n" (shell-quote-argument path))))
          
          (when multi-vterm-toggle-use-dedicated-window
            (set-window-dedicated-p (selected-window) t))))))))

(provide 'multi-vterm-toggle)
;;; multi-vterm-toggle.el ends here
