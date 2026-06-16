(setq auto-save-default nil)

(define-derived-mode finance-mode org-mode "Finance Mode"
  "A major mode for tracking finances and budgeting."

  (define-key finance-mode-map (kbd "n") #'finance-create-new-subaccount)
  (define-key finance-mode-map (kbd "e") #'finance-edit-account))

(defun finance-create-new-subaccount ()
  "Create a new child account of the account at point"
  (interactive)
  (if (org-at-heading-p)
      (let* ((parent-account-name (org-get-heading t t t t))
	     (parent-level (org-current-level))
	     (subaccount-name (read-string "New account name: ")))
	(if (and subaccount-name
		 (not (string-empty-p subaccount-name)))
	    (save-excursion
	      (read-only-mode -1)
	      (end-of-line)
	      (org-insert-subheading nil)
	      (insert subaccount-name)
	      (read-only-mode 1))
	  (user-error "Account name cannot be empty.")))
    (message "Point must be on an account to create a subaccount.")))

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
