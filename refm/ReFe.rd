= ReFe

ReFeについては
((<ReFe|URL:http://i.loveruby.net/ja/prog/refe.html>))
をご覧ください。

== Gems版

Gemsをお使いの方は、「((%gem install refe%))」でインストールできます。
(((<ruby-list:41478>)))

== Ruby リファレンスマニュアルの検索ツール ReFe のデータ構築について

最新 Ruby リファレンスマニュアル用に ReFe のデータを構築するには以下の
手順で行います。(詳細は ReFe の README を参照してください)

(1) ((<URL:http://i.loveruby.net/ja/prog/refe.html>)) から ReFe の基本セット
    を取って来てインストールします。

        tar xvzf refe-x.x.x.tar.gz
        cd refe-x.x.x
        ruby setup.rb config
        ruby setup.rb setup
        (必要に応じて root になってください)
        ruby setup.rb install

(2) ((<URL:http://www.ruby-lang.org/ja/man/man-rd-ja.tar.gz>))
    にあるのが最新のリファレンスマニュアルの tarball です。
    これを取得します。

(3) 取得した man-rd-ja.tar.gz を展開し、ReFeデータベースを構築します。
    /usr/local/share/refe は適宜環境に応じて変更してください(変更した場合は
    refe を実行するのに環境変数 REFE_DATA_DIR を設定する必要があります)

        gzip -dc man-rd-ja.tar.gz | tar xvf -
        cd man-rd-ja
        (必要に応じて root になってください)
        mkrefe_rubyrefm -d /usr/local/share/refe *.rd

    /usr/local/share/refe 下に以下のディレクトリとファイルができます。

        class_document/        method_document/
        class_document_comp    method_document_comp

(4) 後は使うだけです。

        refe IO puts
        IO#puts
        --- puts([obj[, ...]])

            各 obj を self に出力した後、改行します。
            引数の扱いは puts と同じです(詳細はこちらを参照し
            てください)。

            nil を返します。

== ReFe の Emacs インタフェースのインストール方法

(1) ((<refe.el|URL:http://ns103.net/~arai/ruby/refe.el>)) を取って来て
    /usr/local/share/emacs/site-lisp などの Emacs Lisp ライブラリの置き場所
    に置きます。

(2) .emacs に以下を書いておきます。

      (require 'refe)

(3) 引きたいメソッド名の位置に合わせて M-x refe を実行します。
