(setq auto-save-default nil)

(define-derived-mode finance-mode org-mode "Finance Mode"
  "A major mode for tracking finances and budgeting."
  (define-key finance-mode-map (kbd "n") #'finance-add-new-subaccount)
  (define-key finance-mode-map (kbd "e") #'finance-edit-account)
  (define-key finance-mode-map (kbd "d") #'finance-delete-account))


(defun finance-delete-account ()
  "Delete the account at point"
  (interactive)
  (finance--do-to-account
   (delete-line)))


(defun finance-edit-account ()
  "Edit the account at point"
  (interactive)
  (finance--do-to-account
   (let* ((account-name (org-no-properties (org-get-heading t t t t)))
	  (new-name (read-string "Account name: " account-name)))
     (finance--edit-buffer (org-edit-headline new-name)))))


(defun finance-add-new-subaccount ()
  "Create a new child account of the account at point."
  (interactive)
  (finance--do-to-account
   (let ((parent-account-name (org-get-heading t t t t))
	 (parent-level (org-current-level))
	 (subaccount-name (read-string "New account name: ")))
     (if (and subaccount-name
	      (not (string-empty-p subaccount-name)))
	 (save-excursion
	   (finance--edit-buffer
	    (read-only-mode -1)
	    (end-of-line)
	    (org-insert-subheading nil)
	    (insert subaccount-name)
	    (read-only-mode 1)))
       (user-error "Account name cannot be empty.")))))


(defmacro finance--do-to-account (&rest body)
  "Do the given BODY to an account."
  `(progn
     (if (org-at-heading-p)
	 ,@body
       (user-error "Point must be on an account to do that."))))


(defmacro finance--edit-buffer (&rest body)
  "Edit the buffer with the given BODY."
  `(unwind-protect
       (progn
	 (read-only-mode -1)
	 ,@body)
     (read-only-mode 1)))


(defun finance--create-finance-file ()
  "Creates the initial finance file."
  (erase-buffer)
  (insert
   "* Assets\n"
   "* Equity\n"
   "* Expenses\n"
   "* Income\n"
   "* Liabilities\n")
  (goto-char (point-min)))


(defun finance-create ()
  "Create a new ledger of accounts."
  (interactive)
  (let* ((file-path (read-file-name "Select location of finance file: ")))
    (if (and file-path
	     (not (string-empty-p file-path)))
	(progn
	  (find-file file-path)
	  (finance-mode)
	  (finance--create-finance-file)
	  (read-only-mode 1))
      (message "Invalid file name."))))
