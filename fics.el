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
           (process-send-string "*fics*" "xboard -ics -icshost freechess.org\n")
           (process-send-string "*fics*" (+enter username))
           (process-send-string "*fics*" (+enter password)))))
;; (with-current-buffer "*fics*" (insert-string "xboard -ics -icshost freechess.org\n "))
;; (with-current-buffer "*fics*" (insert-string "Slek\n"))
;; (with-current-buffer "*fics*" (insert-string "ounupf\n"))



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

;; (ordinary-insertion-filter "*fics*" "test")

;; (processp "*fics*")

;; (set-process-filter (get-buffer-process "*fics*")  (lambda (y x ) (progn (message "test") (process-send-string y x))))



;; (get-buffer-process "*fics*")
