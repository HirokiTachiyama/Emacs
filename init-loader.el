;;;  -*- coding: utf-8; mode: emacs-lisp; -*-
;;; init-loader.el ---

;;; 使い方
;; load-pathの通った場所に置いて
;; (require 'init-loader)
   	;; (init-loader-load "/path/to/init-directory")
27   	
28   	;;  デフォルト設定の場合,以下の順序で引数に渡したディレクトリ以下のファイルをロードする.
29   	;; 引数が省略された場合は,変数`init-loader-directory'の値を使用する.デフォルトは"~/.emacs.d/inits".
30   	
31   	;; 1. ソートされた,二桁の数字から始まるファイル. e.x, "00_utils.el" "01_ik-cmd.el" "21_javascript.el" "99_global-keys.el"
32   	;; 2. meadowの場合, meadow から始まる名前のファイル. e.x, "meadow-cmd.el" "meadow-config.el"
33   	;; 3. carbon-emacsの場合, carbon-emacs から始まる名前のファイル. e.x, "carbon-emacs-config.el" "carbon-emacs-migemo.el"
34   	;; 4. windowシステム以外の場合(terminal), nw から始まる名前のファイル e.x, "nw-config.el"
35   	
36   	;; ファイルロード後,変数`init-loader-show-log-after-init'の値がnon-nilなら,ログバッファを表示する関数を`after-init-hook'へ追加する.
37   	;; ログの表示は, M-x init-loader-show-log でも可能.
38   	
39   	(eval-when-compile (require 'cl))
40   	(require 'benchmark)
41   	
42   	;;; customize-variables
43   	(defgroup init-loader nil
44   	  "init loader"
45   	  :group 'init-loader)
46   	
47   	(defcustom init-loader-directory (expand-file-name "~/.emacs.d/inits")
48   	  "inits directory"
49   	  :type 'directory
50   	  :group 'init-loader)
51   	
52   	(defcustom init-loader-show-log-after-init t
53   	  "non-nilだと起動時にログバッファを表示する"
54   	  :type 'boolean
55   	  :group 'init-loader)
56   	
57   	(defcustom init-loader-default-regexp "\\(?:^[[:digit:]]\\{2\\}\\)"
58   	  "起動時に読み込まれる設定ファイルにマッチする正規表現.
59   	デフォルトは二桁の数字から始まるファイルにマッチする正規表現.
60   	e.x, 00_hoge.el, 01_huga.el ... 99_keybind.el"
61   	  :type 'regexp
62   	  :group 'init-loader )
63   	
64   	(defcustom init-loader-meadow-regexp "^meadow-"
65   	  "meadow 使用時に読み込まれる設定ファイルにマッチする正規表現"
66   	  :group 'init-loader
67   	  :type 'regexp)
68   	
69   	(defcustom init-loader-carbon-emacs-regexp "^carbon-emacs-"
70   	  "carbon-emacs 使用時に読み込まれる設定ファイルにマッチする正規表現"
71   	  :group 'init-loader
72   	  :type 'regexp)
73   	
74   	(defcustom init-loader-cocoa-emacs-regexp "^cocoa-emacs-"
75   	  "cocoa-emacs 使用時に読み込まれる設定ファイルにマッチする正規表現"
76   	  :group 'init-loader
77   	  :type 'regexp)
78   	
79   	(defcustom init-loader-nw-regexp "^nw-"
80   	  "no-window環境での起動時に読み込まれる設定ファイルにマッチする正規表現"
81   	  :group 'init-loader
82   	  :type 'regexp)
83   	
84   	;;; Code
85   	(defun* init-loader-load (&optional (init-dir init-loader-directory))
86   	  (let ((init-dir (init-loader-follow-symlink init-dir)))
87   	    (assert (and (stringp init-dir) (file-directory-p init-dir)))
88   	    (init-loader-re-load init-loader-default-regexp init-dir t)
89   	    ;; meadow
90   	    (and (featurep 'meadow)
91   	         (init-loader-re-load init-loader-meadow-regexp init-dir))
92   	    ;; carbon emacs
93   	    (and (featurep 'carbon-emacs-package)
94   	         (init-loader-re-load init-loader-carbon-emacs-regexp init-dir))
95   	    ;; cocoa emacs
96   	    (and (equal window-system 'ns)
97   	         (init-loader-re-load init-loader-cocoa-emacs-regexp init-dir))
98   	    ;; no window
99   	    (and (null window-system)
10   	         (init-loader-re-load init-loader-nw-regexp init-dir))
10   	
10   	    (when init-loader-show-log-after-init
10   	      (add-hook  'after-init-hook 'init-loader-show-log))))
10   	
10   	(defun init-loader-follow-symlink (dir)
10   	  (cond ((file-symlink-p dir)
10   	         (expand-file-name (file-symlink-p dir)))
10   	        (t (expand-file-name dir))))
10   	
11   	(lexical-let (logs)
11   	  (defun init-loader-log (&optional s)
11   	    (if s (and (stringp s) (push s logs)) (mapconcat 'identity (reverse logs) "\n"))))
11   	
11   	(lexical-let (err-logs)
11   	  (defun init-loader-error-log (&optional s)
11   	    (if s (and (stringp s) (push s err-logs)) (mapconcat 'identity (reverse err-logs) "\n"))))
11   	
11   	(defun init-loader-re-load (re dir &optional sort)
11   	  (let ((load-path (cons dir load-path)))
12   	    (dolist (el (init-loader--re-load-files re dir sort))
12   	      (condition-case e
12   	          (let ((time (car (benchmark-run (load (file-name-sans-extension el))))))
12   	            (init-loader-log (format "loaded %s. %s" (locate-library el) time)))
12   	        (error
12   	         (init-loader-error-log (error-message-string e)))))))
12   	
12   	(defun init-loader--re-load-files (re dir &optional sort)
12   	    (loop for el in (directory-files dir t)
12   	          when (string-match re (file-name-nondirectory el))
13   	          collect (file-name-nondirectory el) into ret
13   	          finally return (if sort (sort ret 'string<) ret)))
13   	
13   	(defun init-loader-show-log ()
13   	  "return buffer"
13   	  (interactive)
13   	  (let ((b (get-buffer-create "*init log*")))
13   	    (with-current-buffer b
13   	      (erase-buffer)
13   	      (insert "------- error log -------\n\n"
14   	              (init-loader-error-log)
14   	              "\n\n")
14   	      (insert "------- init log -------\n\n"
14   	              (init-loader-log)
14   	              "\n\n")
14   	      ;; load-path
14   	      (insert "------- load path -------\n\n"
14   	              (mapconcat 'identity load-path "\n"))
14   	      (goto-char (point-min)))
14   	    (switch-to-buffer b)))
15   	
15   	
15   	;;;; Test
15   	(defvar init-loader-test-files
15   	  '("00_utils.el"
15   	    "23_yaml.el"
15   	    "01_ik-cmd.el"
15   	    "96_color.el"
15   	    "20_elisp.el"
15   	    "21_javascript.el"
16   	    "25_perl.el"
16   	    "98_emacs-config.el"
16   	    "99_global-keys.el"
16   	    "carbon-emacs-config.el"
16   	    "carbon-emacs-migemo.el"
16   	    "nw-config.el"
16   	    "emacs-migemo.el"
16   	    "meadow-cmd.el"
16   	    "meadow-config.el"
16   	    "meadow-gnuserv.el"
17   	    "meadow-shell.el"
17   	    "meadow-w32-symlinks.el"))
17   	
17   	(dont-compile
17   	  (when (fboundp 'expectations)
17   	    (expectations
17   	      (desc "init-loader--re-load-files")
17   	      (expect  '("00_utils.el" "01_ik-cmd.el" "20_elisp.el" "21_javascript.el" "23_yaml.el" "25_perl.el" "96_color.el" "98_emacs-config.el" "99_global-keys.el")
17   	        (stub directory-files => init-loader-test-files)
17   	        (init-loader--re-load-files init-loader-default-regexp "" t))
18   	      (expect  '("meadow-cmd.el" "meadow-config.el" "meadow-gnuserv.el" "meadow-shell.el" "meadow-w32-symlinks.el")
18   	        (stub directory-files => init-loader-test-files)
18   	        (init-loader--re-load-files init-loader-meadow-regexp "" t))
18   	
18   	      (expect  '("carbon-emacs-config.el" "carbon-emacs-migemo.el")
18   	        (stub directory-files => init-loader-test-files)
18   	        (init-loader--re-load-files init-loader-carbon-emacs-regexp "" t))
18   	      (expect  '("nw-config.el")
18   	        (stub directory-files => init-loader-test-files)
18   	        (init-loader--re-load-files init-loader-nw-regexp "" t))
19   	      ;; 環境依存
19   	      (desc "follow symlink")
19   	      (expect "c/.emacs.d/inits"
19   	        (file-relative-name (file-symlink-p "~/tmp/el-inits"))) ; symlink
19   	      (desc "init-loader-follow-symlink")
19   	      (expect "c/.emacs.d/inits"
19   	        (file-relative-name (init-loader-follow-symlink "~/tmp/el-inits")))
19   	      (expect "c/.emacs.d/inits"
19   	        (file-relative-name (init-loader-follow-symlink "~/tmp/el-inits")))
19   	      )))
20   	
       (provide 'init-loader)
