; Flymake
(when (load "flymake" t)
  (defun flymake-pylint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
      (local-file (file-relative-name
                   temp-file
                   (file-name-directory buffer-file-name))))
      (list "epylint" (list local-file))))

  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pylint-init)))

  (add-hook 'find-file-hook 'flymake-find-file-hook)

  (delete '("\\.html?\\'" flymake-xml-init) flymake-allowed-file-name-masks)

  (defun my-flymake-show-help ()
    (when (get-char-property (point) 'flymake-overlay)
      (let ((help (get-char-property (point) 'help-echo)))
        (if help (message "%s" help)))))

(add-hook 'post-command-hook 'my-flymake-show-help)

(global-set-key (kbd "M-r") 'revert-buffer) ; Alt+r

(global-set-key
  (kbd "C-c ipdb")
  (lambda () (interactive)  (insert "import ipdb; ipdb.set_trace()")))

(global-set-key
  (kbd "C-c ifmain")
  (lambda () (interactive) (insert "if __name__ == '__main__':")))

;; Show line and column number by default
(line-number-mode 1)
(column-number-mode 1)

;; Install MELPA package archive
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)

;; Set up stuff for Python development
(ido-mode)
(global-set-key (kbd "C-c p") 'python-mode) ; Alt+r
(auto-complete)
