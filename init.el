;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Copyrights (C) 2015
;;;;; All Rights Reserved Hiroki Tachiyama
;;;;;
;;;;; init.el
;;;;; Edittor       Hiroki Tachiyama
;;;;; Written       2015/03/31 14:00
;;;;; Last Modified 2015/06/03 12:00
;;;;;
;;;;; ・設定についての説明もしっかり残しておくこと！
;;;;; ・どの環境でもこのファイルとその他ディレクトリ（elise等）を入れれば
;;;;; 使えるようする
;;;;; ・一々init.elを用意しなくても良いようにする
;;;;; ・セクション（色、各種モード等）はタイトルを;;;;;;;;;;で挟む
;;;;; ・サブセクションは;;で始める
;;;;; ・一行コメントは;で始める
;;;;; ・勿論、短く簡潔な読みやすいクリアコードを心がける！
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;Using-Operating-System変数の設定;;;;;;;;;;
;;;;;;;;;;使っている環境のinit.el毎に、この変数を設定し
;;;;;;;;;;環境固有の設定(フォントなど)時に
;;;;;;;;;;when文などで場合分けする。
;;;;;;;;;;defvarでconst変数
;;(defvar *Using-Operating-System* "Arch Linux VaioL")
(defvar *Using-Operating-System* "Arch Linux VaioZ")
;;(defvar *Using-Operating-System* "Arch Linux KatLab")
;;(defvar *Using-Operating-System* "Windows VaioL")
;;(defvar *Using-Operating-System* "Windows VaioZ")
;;(defvar *Using-Operating-System* "Windows KatLab")
;;;;;;;;;;Using-Operating-Systemおわり;;;;;;;;;;



;;;;;;;;;;色についてのセクション;;;;;;;;;;
;;基本的な文字, 背景など
(set-background-color "black") ;背景色
(set-foreground-color "white")  ;文字色
(set-face-foreground 'font-lock-comment-face "orange") ;コメントの文字
(set-face-foreground 'font-lock-comment-delimiter-face "orange") ;コメントの記号(;とか//)
(add-to-list 'default-frame-alist '(cursor-color . "#7fffd4")) ;カーソル
(set-face-foreground 'mode-line "green") ;モードライン前景色
(set-face-background 'mode-line "blue") ;モードライン背景色
(set-face-background 'region "#345678") ;選択中のリージョン
(set-face-foreground 'mode-line-inactive "gray30") ;非アクティブのモードライン背景色
(set-face-background 'mode-line-inactive "gray85") ;非アクティブのモードライン前景色


;;括弧の中を強調表示
(setq show-paren-delay 0)
(show-paren-mode t)
(setq show-paren-style 'expression)
(set-face-background 'show-paren-match-face "#412323") ;括弧の範囲色

;;タブと全角スペース、行末の半角スペースの可視化
(defface my-face-b-1 '((t (:background "NavajoWhite4"))) nil) ; 全角スペース
(defface my-face-b-2 '((t (:background "gray10"))) nil) ; タブ
(defface my-face-u-1 '((t (:background "SteelBlue" :underline t))) nil) ; 行末空白
(defvar my-face-b-1 'my-face-b-1)
(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-u-1 'my-face-u-1)
(defadvice font-lock-mode (before my-font-lock-mode ())
 (font-lock-add-keywords
 major-mode
 '(("\t" 0 my-face-b-2 append)
 ("　" 0 my-face-b-1 append)
 ("[ \t]+$" 0 my-face-u-1 append)
 )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)
;;;;;;;;;;色のセクションおわり;;;;;;;;;;


;;;;;;;;;;*.elをロードする add-to-load-path;;;;;;;;;;
;;load-pathの追加関数
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

;;2つ以上指定する場合の形 -> (add-to-load-path "elisp" "xxx" "xxx")
(add-to-load-path "elisp")
;;;;;;;;;;*.elのロードおわり;;;;;;;;;;

;;;;;;;;;;各種機能;;;;;;;;;;
(server-start) ;テキストファイルやソースコードを開く関連付け
(setq inhibit-startup-screen t) ;スタートメニュー非表示
(setq kill-whole-line t) ;C-kで行全体を削除
(tool-bar-mode -1) ;ツールバーを非表示
(setq make-backup-files nil) ;バックアップを残さない
(setq delete-auto-save-files t) ;終了時にオートセーブファイルを消す
(global-linum-mode) ;;; 行の表示(バッファー)
(line-number-mode t) ;行の表示(モードライン)
(column-number-mode t) ;何文字目かを表示(モードライン)
(icomplete-mode t) ;バッファー移動時にミニウィンドウに候補を表示

;;ファイルのフルパスをタイトルバーに表示
(setq frame-title-format
      (format "%%f - Emacs@%s" (system-name)))

;;時計
(setq display-time-string-forms
      '((format "%s/%s/%s(%s) %s:%s "
		year month day dayname 24-hours minutes)
	load
	(if mail " Mail" "")))
(display-time)
(setq display-time-kawakami-form t)
(setq display-time-24hr-format t)

;; 改行コードを表示
(setq eol-mnemonic-dos "(CRLF)")
(setq eol-mnemonic-mac "(CR)")
(setq eol-mnemonic-unix "(LF)")

;; 選択範囲の情報表示
(defun count-lines-and-chars ()
(if mark-active
(format "[%3d:%4d]"
(count-lines (region-beginning) (region-end))
(- (region-end) (region-beginning)))
""))
(add-to-list 'default-mode-line-format
	     '(:eval (count-lines-and-chars)))

;;矩形選択モード C-x SPCで開始
(cua-mode t)
(setq cua-enable-cua-keys nil) ;デフォルトの矩形選択モードのキーバインドを無くす
(define-key global-map (kbd "C-x SPC") 'cua-set-rectangle-mark)

;;自動補完 auto-complete
(add-to-load-path "elpa/auto-complete") ;ロードパスの追加
(add-to-load-path "elpa/popup")
(require 'auto-complete-config)

(ac-config-default)

;;{とうつと}, "とうつと"のように対応する文字を自動入力
(electric-pair-mode t)
(add-to-list 'electric-pair-pairs '(?| . ?|))
(add-to-list 'electric-layout-rules '(?{ . after)) ;{の後に改行を挿入}


;;=や,の前後に自動でスペースを挿入
;; (add-to-load-path "elpa/key-combo")
;; (require 'key-combo)
;; (key-combo-mode 1)
;; (key-combo-load-default)

;;;;;;;;;;各種機能おわり;;;;;;;;;;

;;;;;;;;;;パッケージ管理;;;;;;;;;;

;;;;;package.el
;;Emacs 24から標準添付
;;リポジトリの登録により利用可能
(require 'package)

;;GNU ELPA 公式リポジトリ
;;登録されているパッケージ数は少ないが他のリポジトリに比べて
;;信頼度は高い.
;;デフォルトで利用可能.

;;Marmalade 非公式リポジトリ
;;MELPAにも登録されているパッケージの場合、安定版をMarmaladeに
;;アップロードするという使われ方が多い。
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))

;;MELPA 非公式リポジトリ
;;リポジトリに変更がある度に更新される為
;;パッケージの最新版をインストール可能
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))

;;;;;;;;;;パッケージ管理おわり;;;;;;;;;;


;;;;;;;;;;各種編集モード;;;;;;;;;;

;;Common Lisp開発環境SLIME
;;Superior Lisp Interaction Mode for Emacs
(add-to-load-path "elpa/slime")
(setf inferior-lisp-program "/usr/bin/sbcl") ;Lisp処理系のパス
(require 'slime-autoloads)
(slime-setup '(slime-repl))

;;ヘルプバッファや保管バッファをポップアップで表示するpopwin.el
(add-to-load-path "elpa/popwin")
(require 'popwin)
(popwin-mode 1)
;; Apropos
(push '("*slime-apropos*") popwin:special-display-config)
;; Macroexpand
(push '("*slime-macroexpansion*") popwin:special-display-config)
;; Help
(push '("*slime-description*") popwin:special-display-config)
;; Compilation
(push '("*slime-compilation*" :noselect t) popwin:special-display-config)
;; Cross-reference
(push '("*slime-xref*") popwin:special-display-config)
;; Debugger
(push '(sldb-mode :stick t) popwin:special-display-config)
;; REPL
(push '(slime-repl-mode) popwin:special-display-config)
;; Connections
(push '(slime-connection-list-mode) popwin:special-display-config)

;;オートコンプリート機能
(add-to-load-path "elpa/ac-slime")
(require 'ac-slime)
(add-hook 'slime-mode-hook 'set-up-slime-ac)
(add-hook 'slime-repl-mode-hook 'set-up-slime-ac)
(eval-after-load "auto-complete"
  '(add-to-list 'ac-modes 'slime-repl-mode))

;;野鳥 YaTeX
;;C-c t j でコンパイル
;;C-c t p でプレビュー

(add-to-load-path "elpa/yatex")
;;(require 'yatex)
(setq auto-mode-alist
  (cons (cons "\\.tex$" 'yatex-mode) auto-mode-alist))
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)

;; YaTeX が利用する内部コマンドを定義する
;; 自作したコマンド /binに置いてある
;;platexとdvipdfmxを実行
(setq tex-command "platex2pdf")
(cond
  ((eq system-type 'gnu/linux) ;; GNU/Linux なら
    (setq dvi2-command "evince")) ;; evince で PDF を閲覧
  ((eq system-type 'darwin) ;; Mac なら
    (setq dvi2-command "open -a Preview"))) ;; プレビューで
(add-hook 'yatex-mode-hook '(lambda () (setq auto-fill-function nil)))
(require 'auto-complete-latex)

(setq auto-mode-alist ;;拡張子をyatex-modeに関連付け
      (append '(("\\.tex$" . yatex-mode)
                ("\\.ltx$" . yatex-mode)
                ("\\.cls$" . yatex-mode)
                ("\\.sty$" . yatex-mode)
                ("\\.clo$" . yatex-mode)
                ("\\.bbl$" . yatex-mode)) auto-mode-alist))

;;Syntacs checking flycheck
(add-to-load-path "elpa/dash")
(add-to-load-path "elpa/flycheck")
;;(require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)
;;(add-hook 'after-init-hook 'flycheck-mode)



;;Ruby
;;構文チェッカー？ うまく動かなかったのでコメントアウト
;; (add-hook 'ruby-mode-hook
;; 	  '(labmda ()
;; 		   (setq flycheck-checker 'ruby-rubocop)
;; 		   (flycheck-mode 1)))
;;doやclass, defなどに反応してendを挿入
(add-to-load-path "elpa/ruby-end") ;ロードパスの追加
(require 'ruby-end)

;;;;;;;;;;各種編集モードおわり;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;以下、環境依存の可能性の有るもの！;;;;;;;;;;;
;;;;;;;;;;*Using-Operation-System*変数によって
;;;;;;;;;;場合分けする。
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;フォントの設定;;;;;;;;;;
;;01234567890123456789
;;あいうえおかきくけこ

(if (string-equal *Using-Operating-System* "Arch Linux VaioZ")
    (cond (window-system
	   (set-face-attribute 'default nil ;;フォントの設定
			       :family "Meiryo"
			       :height 180)
	   (set-fontset-font (frame-parameter nil 'font)
			     'japanese-jisx0208
			     '("Takaoゴシック" . "unicode-bmp")
			     )
	   (set-fontset-font (frame-parameter nil 'font)
			     'katakana-jisx0201
			     '("Takaoゴシック" . "unicode-bmp")
			     )
	   (setq face-font-rescale-alist
		 '((".*さざなみゴシック.*" . 1.5)
		   (".*Takaoゴシック.*"    . 2.0))))))

(if (or (string-equal *Using-Operating-System* "Arch Linux KatLab")
	(string-equal *Using-Operating-System* "Windows KatLab")
	(string-equal *Using-Operating-System* "Windows VaioL"))
    (set-face-attribute 'default nil
			:family "Meiryo"
			:height 120))
(if (string-equal *Using-Operating-System* "Windows VaioZ")
    (set-face-attribute 'default nil
			:family "Osaka－等幅"
			:height 100))
(if (string-equal *Using-Operating-System* "Arch Linux VaioZ")
    (set-face-attribute 'default nil
			:family "Osaka－等幅"
			:height 120))
(if (string-equal *Using-Operating-System* "Arch Linux VaioL")
    (set-face-attribute 'default nil
			:family "Ricty"
			:height 140))

;;;;;;;;;;フォントおわり;;;;;;;;;;

;;;;;;;;;;日本語入力;;;;;;;;;;
;;;;;Arch Linux Awesome      Ibus-Anthy
;;;;;Arch Linux KatLab&VaioL Mozc

;;(set-language-environment "Japanese")
;;(prefer-coding-system 'UTF-8)
(if (string-equal *Using-Operating-System* "Arch Linux VaioZ")
    (global-set-key [zenkaku-hankaku] 'ibus-toggle))

;or
(if (or (string-equal *Using-Operating-System* "Arch Linux KatLab")
	(string-equal *Using-Operating-System* "Arch Linux VaioL"))
    (progn (require 'mozc)
	   (setq default-input-method "japanese-mozc")
	   (global-set-key [zenkaku-hankaku] 'mozc-mode)))
;;;;;;;;;;日本語入力おわり;;;;;;;;;;

;;(unless (boundp '*hoge*)
;;  (defvar *hoge* (read)))

;;(toggle-frame-fullscreen)

(defun mycopyrights ()
  (print
   "Copyrights (C) 2015 All Rights ReservedHiroki Tachiyama"))


(put 'downcase-region 'disabled nil)
