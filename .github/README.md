
# MatchSkeleton - Equivalent to MatchData with less memory use

This package provides the class {MatchSkeleton}. It behaves almost exactly
like `MatchData`, except it uses a greatly less and practically negligible
internal memory.

The built-in `MatchData` class holds a copy of the original `String`, from
which the matched data are derived, in a "freeze" state.  It is useful because
no one can by chance destructively modify the original string.  However, if is
memory-savvy.  Even if `MatchData` is the match of the first few characters of
a 1-GB string, it internally holds the entire 1-GB of the original string.  If
a code running holds 1000 of them, it needs a memory use of 1TB(!).

This class holds the same information of the matched data as `MatchData` but
as positional indices, and the original String object only. Therefore, as long
as the original String is not destructively modified by an external process,
any method of this class returns the equal result as `MatchData`.  Note that
while the instance of this class is kept, the original string is not
garbage-collected by the Ruby interpreter.

One additional function this class offers is the instance variable and method
`pos_begin`.  It can be set by a user and hold the information (`Integer`) at
which position the `Regexp` match has started to generate the matched data.

Note this library, when required, also modifies the operator +MatchData#==+ so
that it can be compared with {MatchSkeleton} objects. Now the operator is
simply based on duck-typing of `#string`, `regexp`, and `pre_match`.

## Install

The standard procedure to install a gem should work:
    gem install match_skeleton

Or, get it from {https://rubygems.org/gems/match_skeleton} or
{https://github.com/masasakano/match_skeleton}

Then just require as
    require 'match_skeleton'

Have fun!

## Simple Examples

Here are some simple examples.

    require 'match_skeleton'

    str = "Something_Big."
    pos = 3
    mtch = str.match(/(.)big/i, pos)
    mskn = MatchSkeleton.new(mtch, str, pos_begin: pos)

    mtch == mskn     # => true
    mskn.string      # => "Something_Big."
    mskn[1]          # => "_"
    mskn.pos_begin   # => 3

    mskn.post_match  # => "."
    mtch.post_match  # => "."
    str[-1,1] = '%'
    mskn.post_match  # => "%"  # The original string has been destructively modified.  Do not do that...
    mtch.post_match  # => "."
    mtch == mskn     # => false

## Known bugs

*   None.


This library has been tested in Ruby 2.0 or later only. It may work in Ruby
1.8, but has not been tested.

Extensive tests have been performed, as included in the package.

## Acknowledgement

This work is supported by [Wise Babel Ltd](http://www.wisebabel.com/).

{http://www.wisebabel.com/}

## Copyright etc

Author
:   Masa Sakano < imagine a_t sakano dot co dot uk >
License
:   MIT.
Warranty
:   No warranty whatsoever.
Versions
:   The versions of this package follow Semantic Versioning (2.0.0)
    http://semver.org/



# MatchSkeleton - MatchDataに等価でメモリを節約するクラス

クラス `MatchSkeleton` のGemです。 `MatchData`とほぼ完全に等価な動作をします。ただし、メモリ使用量は
比較してはるかに少なくなり、ほぼ無視できます。

組込`MatchData`クラスは、正規表現マッチした元の文字列(String)のコピーを
"freeze"した状態で保持します。おかげで、外部のプロセスが元文字列を 破壊的に変更して`MatchData`のオブジェクトも影響を受ける、ということは
ありません。しかし、それはメモリ使用量が巨大になり得ます。たとえば、 {MatchData}オブジェクトが1GBの文字列の最初の数文字だけのマッチだったと
しても、同オブジェクトは、その1GBの文字列を内部的に保持します。 もし動作中のコードがそんなオブジェクトを1000個保持していたら、 それだけで
1TB(!)のメモリを消費することになります。

このクラスは、`MatchData`と同じ情報を保持しますが、それは内部的に、 インデックスと(コピーではない)原文字列そのものだけです。したがって、
原文字列が外部のプロセスで破壊的に変更されない限り、このクラスの メソッドの返り値は、`MatchData`と同じです。念のため、このクラスの
インスタンスが生きている限り、原文字列がガーベージ・コレクトされる ことはありません。

一点、このクラス独自のパラメーターとして、インスタンス変数かつ メソッドの`pos_begin`が導入されています。正規表現マッチの
開始ポジション(`Integer`)を(ユーザーが設定することで)保持します。

なお、このライブラリを require した時、演算子 +MatchData#==+ が変更され、{MatchSkeleton}
と比較できるようになります。 結果、同演算子は、ダック・タイピングとして、 `#string`, `regexp`, および
`#pre_match`に依存するようになります。

## インストール

gem を使ってインストールできます。
    gem install match_skeleton

もしくは以下から入手して下さい。

{https://rubygems.org/gems/match_skeleton}

あとは、以下で一発です。
    require 'match_skeleton'

お楽しみあれ!

## 単純な使用例

以下に幾つかの基本的な使用例を列挙します。

    require 'match_skeleton'

    str = "Something_Big."
    pos = 3
    mtch = str.match(/(.)big/i, pos)
    mskn = MatchSkeleton.new(mtch, str, pos_begin: pos)

    mtch == mskn     # => true
    mskn.string      # => "Something_Big."
    mskn[1]          # => "_"
    mskn.pos_begin   # => 3

    mskn.post_match  # => "."
    mtch.post_match  # => "."
    str[-1,1] = '%'
    mskn.post_match  # => "%"  # 元文字列が破壊的に変更された結果。そんなことはしないように……。
    mtch.post_match  # => "."
    mtch == mskn     # => false

## 既知のバグ

*   なし。


このライブラリは Ruby 2.0 以上でのみ挙動試験されています。 1.8以前でも動くかもしれませんが、テストされていません。

パッケージに含まれている通り、網羅的なテストが実行されています。

## 謝辞

この開発は、ワイズバベル社([Wise Babel Ltd](http://www.wisebabel.com/en))に支援されています。

http://www.wisebabel.com/ja

## 著作権他情報

著者
:   Masa Sakano < imagine a_t sakano dot co dot uk >
利用許諾条項
:   MIT.
保証
:   一切無し。
バージョン
:   Semantic Versioning (2.0.0) http://semver.org/


