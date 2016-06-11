;;;;shitty code to try to run an xboard connected to fics from emacs:

(defun read-lines (filePath)
  "Return a list of lines of a file at filePath."
  (with-temp-buffer
    (insert-file-contents filePath)
    (split-string (buffer-string) "\n" t)))

(defun +enter (str)
  (concat str "\n"))

(defun fics ()
  (interactive)
  (let* ((conf (read-lines "~/.emacs.d/el-fics/fics_config"))
         (username (car conf))
         (password (cadr conf)))
    (progn (shell "*fics*")
           (process-send-string "*fics*" "xboard -ics -icshost freechess.org -icshelper /home/sam/zseal/zseal\n")
           (process-send-string "*fics*" (+enter username))
           (process-send-string "*fics*" (+enter password))
           (set-process-filter (get-buffer-process "*fics*") 'keep-output))))

(defun clean-message (message)
  )



;;(get-last-point)

(defun ordinary-insertion-filter (proc string)
  (when (buffer-live-p (process-buffer proc))
    (with-current-buffer (process-buffer proc)
      (let ((moving (= (point) (process-mark proc))))
        (save-excursion
          ;; Insert the text, advancing the process marker.
          (goto-char (process-mark proc))
          (insert string)
          (set-marker (process-mark proc) (point)))
        (if moving (goto-char (process-mark proc)))))))

(defun get-lines (start end)
  (progn
    (setq res '())
    (while (< start end)
      (with-current-buffer "*fics*" (line-beginning-position (+ 1 start)))
      (setq tmp-text (with-current-buffer "*fics*" (buffer-substring))))))

(defun keep-output (process output)
  (progn
    (ordinary-insertion-filter process (ansi-color-filter-apply output))
    (handle-message output)
    (setq kept output)))

(setq kept nil)




(defun handle-message (message)
  (let ((splt (split-string message " ")))
    (if (string= "tells" (nth 1 splt))
        (progn
          (handle-tell message)))))

(defun handle-tell (message)
  (let* ((formatted (ansi-color-filter-apply message))
         (splt (split-string formatted " "))
         (user-tmp  (nth 0 splt))
         (user (substring user-tmp 1 (length user-tmp)))
         (conversation-buffer (concat "fics:" user))
         (core-splt (cdddr splt))
         (rest-message (mapconcat 'identity core-splt " ")))
    (get-buffer-create conversation-buffer)
    (with-current-buffer conversation-buffer
      (fics-chat-mode)
      (insert (concat user ": " rest-message "\n")))))

(length "test")

;;creating fics-chat mode
(defvar fics-chat-mode-hook nil)

(defun my-function ()
  (interactive "*")
  (print "test"))

(defvar fics-chat-mode-map
  (let ((map (make-keymap)))
;    (define-key map "RET" 'my-function)
    map)
  "Keymap for fics-chat major mode")

(defun fics-chat-mode ()
  (interactive)
  (kill-all-local-variables)
  (use-local-map fics-chat-mode-map)
  (run-hooks 'fics-chat-mode-hook))

(defun get-current-line ()
  (save-excursion
    (back-to-indentation)
    (let ((start (point)))
      
      (let ((end (line-end-position)))
        (buffer-substring-no-properties  start end) ))))

(define-key fics-chat-mode-map
  (kbd "RET")
  (lambda ()
    (interactive)
    (let ((tmp (get-current-line))
          (name (nth 1  (split-string (buffer-name) ":"))))
      (process-send-string "*fics*" (concat "t " name " " tmp "\n")))
    (insert "\n")))







