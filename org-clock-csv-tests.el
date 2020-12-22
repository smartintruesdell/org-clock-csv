;; -*- lexical-binding: t -*-

(require 'org-clock-csv)

;;; Helper Code:

(defun org-clock-csv-should-match (input output &optional consolidate)
  "Test that clock entries in INPUT match the .csv OUTPUT file."
  (let* ((in (with-current-buffer (org-clock-csv input 'no-switch consolidate)
               (buffer-string)))
         (out (with-temp-buffer
                (insert-file-contents output)
                (buffer-string))))
    (should (equal in out))))

(defvar org-clock-csv-header-all-props
  "task,headline,parents,category,start,end,duration,effort,ishabit,tags,title")

(defun org-clock-csv-all-props-row-fmt (plist)
  "Formatting function including all properties."
  (mapconcat #'identity
             (list (org-clock-csv--escape (plist-get plist ':task))
                   (org-clock-csv--escape
                    (org-element-property :raw-value (plist-get plist ':headline)))
                   (org-clock-csv--escape
                    (s-join org-clock-csv-headline-separator
                            (plist-get plist ':parents)))
                   (org-clock-csv--escape (plist-get plist ':category))
                   (plist-get plist ':start)
                   (plist-get plist ':end)
                   (plist-get plist ':duration)
                   (plist-get plist ':effort)
                   (plist-get plist ':ishabit)
                   (plist-get plist ':tags)
                   (plist-get plist ':title))
             ","))

;;; Tests:

(ert-deftest test-sample ()
  "Docs."
  (org-clock-csv-should-match "tests/sample.org" "tests/sample.csv"))

(ert-deftest test-all-props ()
  "Test all available properties."
  (let ((org-clock-csv-header org-clock-csv-header-all-props)
        (org-clock-csv-row-fmt #'org-clock-csv-all-props-row-fmt))
    (org-clock-csv-should-match "tests/sample.org" "tests/all-props.csv")))

(ert-deftest test-issue-2 ()
  "Test tasks with commas in them, as in issue #2."
  (org-clock-csv-should-match "tests/issue-2.org" "tests/issue-2.csv"))

(ert-deftest test-issue-3 ()
  "Test tasks with headline ancestors, as in issue #3."
  (org-clock-csv-should-match "tests/issue-3.org" "tests/issue-3.csv"))

(ert-deftest test-issue-5 ()
  "Test file level category."
  (org-clock-csv-should-match "tests/issue-5.org" "tests/issue-5.csv"))

(ert-deftest test-issue-26 ()
  "Test file without title."
  (let ((org-clock-csv-header org-clock-csv-header-all-props)
        (org-clock-csv-row-fmt #'org-clock-csv-all-props-row-fmt))
    (org-clock-csv-should-match "tests/issue-26.org" "tests/issue-26.csv")))

(ert-deftest test-issue-23 ()
  "Test custom properties."
  (let ((org-clock-csv-header "task,CUSTOM_1,CUSTOM_2,start,end")
        (org-clock-csv-row-fmt
         (lambda (plist)
           (mapconcat #'identity
                      (list (org-clock-csv--escape (plist-get plist ':task))
                            (org-clock-csv--escape
                             (org-clock-csv--read-property plist "CUSTOM_1" "defaultvalue"))
                            (org-clock-csv--escape
                             (org-clock-csv--read-property plist "CUSTOM_2"))
                            (plist-get plist ':start)
                            (plist-get plist ':end))
                      ","))))
    (org-clock-csv-should-match "tests/issue-23.org" "tests/issue-23.csv")))

(ert-deftest test-task-consolidation ()
  "Test consolidating clock entries for a task/day into a single start/end/duration for accounting or time entry"
  (let ((org-clock-csv-header org-clock-csv-header-all-props)
        (org-clock-csv-row-fmt #'org-clock-csv-all-props-row-fmt))
    (org-clock-csv-should-match "tests/task-consolidation.org" "tests/task-consolidation.csv" t)))

;; Local Variables:
;; coding: utf-8
;; End:

;;; org-clock-csv-tests.el ends here
