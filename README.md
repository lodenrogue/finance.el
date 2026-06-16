# Finance

Emacs finance and budgeting package for personal and business use.

## Install

```elisp
(load-file "path/to/finance.el")
```

## Usage

### Create a new finance file with a ledger of accounts:

```elisp
(finance-create)
```

### Add an account

Put the point on an existing account and press n
(finance-add-new-subaccount). This will prompt you for an account
name.

### Edit an account

Put the point on an existing account and press e
(finance-edit-account). This will prompt you for a new account name.

### Delete an account

Put the point on an existing account and press d
(finance-delete-account). This will prompt you to confirm you want to
delete this account.
