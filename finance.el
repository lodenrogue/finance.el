(setq auto-save-default nil)

(define-derived-mode finance-mode org-mode "Finance Mode"
  "A major mode for tracking finances and budgeting."
  (define-key finance-mode-map (kbd "n") #'finance-add-new-subaccount)
  (define-key finance-mode-map (kbd "e") #'finance-edit-account)
  (define-key finance-mode-map (kbd "d") #'finance-delete-account)
  (define-key finance-mode-map (kbd "a") #'finance-add-transaction))


(defun finance--prompt-for-transaction (account-name account-buffer account-eol-pos)
  "Prompt the user for transaction details and return the transaction data."
  (let ((transaction-window (split-window-below))
	(transaction-buffer (get-buffer-create (format "*%s Transaction*" account-name))))
    (select-window transaction-window)
    (switch-to-buffer transaction-buffer)
    (erase-buffer)
    (insert "Description: \n")))


(defun finance-add-transaction ()
  "Add a transaction to the account at point.

If the account has children it is not allowed to have transactions"
  (interactive)
  (finance--do-to-account
   (save-excursion
     (if (org-goto-first-child)
	 (user-error "Accounts with children cannot have transactions.")
       (progn
	 (end-of-line)
	 (finance--prompt-for-transaction
	  (finance-get-account-name)
	  (buffer-name)
	  (point)))))))


(defun finance-delete-account ()
  "Delete the account at point"
  (interactive)
  (if (y-or-n-p
       (format "Delete %s account and all of its sub-accounts?"
	       (finance-get-account-name)))
      (finance--do-to-account
       (finance--edit-buffer
	(org-cut-subtree)
	(pop kill-ring)))))


(defun finance-edit-account ()
  "Edit the account at point"
  (interactive)
  (finance--do-to-account
   (let* ((account-name (finance-get-account-name))
	  (new-name (read-string "Account name: " account-name)))
     (finance--edit-buffer (org-edit-headline new-name)))))


(defun finance-add-new-subaccount ()
  "Create a new child account of the account at point."
  (interactive)
  (finance--do-to-account
   (let ((parent-account-name (finance-get-account-name))
	 (parent-level (org-current-level))
	 (subaccount-name (read-string "New account name: ")))
     (if (and subaccount-name
	      (not (string-empty-p subaccount-name)))
	 (save-excursion
	   (finance--edit-buffer
	    (end-of-line)
	    (org-insert-subheading nil)
	    (insert subaccount-name)))
       (user-error "Account name cannot be empty.")))))


(defun finance-get-account-name ()
  "Return the name of account at point"
  (interactive)
  (finance--do-to-account
   (org-no-properties (org-get-heading t t t t))))

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
