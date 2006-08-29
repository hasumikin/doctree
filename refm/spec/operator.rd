###nonref

= 演算子式

  * ((<演算子式/代入>))
    * ((<演算子式/自己代入>))
    * ((<演算子式/多重代入>))
  * ((<演算子式/範囲式>))
  * ((<演算子式/and>))
  * ((<演算子式/or>))
  * ((<演算子式/not>))
  * ((<演算子式/条件演算子>))

例:

          1+2*3/4

プログラミングの利便のために一部のメソッド呼び出しと制御構造は演算子形
式をとります。Rubyには以下にあげる演算子があります。

          高い   ::
                 []
                 +(単項)  !  ~
                 **
                 -(単項)
                 *  /  %
                 +  -
                 << >>
                 &
                 |  ^
                 > >=  < <=
                 <=> ==  === !=  =~  !~
                 &&
                 ||
                 ..  ...
                 ?:(条件演算子)
                 =(+=, -= ... )
                 not
          低い   and or

左の「高い」「低い」は演算子の優先順位です。
例えば「&&」は「||」より優先順位が高いので、以下のように
解釈されます。

    a && b || c   #=> (a && b) || c
    a || b && c   #=>  a || (b && c)

ほとんどの演算子は特別な形式のメソッド呼び出しですが、一部の
ものは言語に組み込みで、再定義できません。

* 再定義できる演算子(メソッド):

  (({+@})), (({-@})) は単項演算子 (({+})), (({-})) を表しメソッド定義
  などではこの記法を利用します。

  ((-このマニュアルの分類では ((<リテラル/コマンド出力>)) (({`...`})) 
  は演算子ではありませんが説明の都合上再定義できる演算子の一覧にあげて
  います-))

    |  ^  &  <=>  ==  ===  =~  >   >=  <   <=   <<  >>
    +  -  *  /    %   **   ~   +@  -@  []  []=  `

  これらの演算子式の定義方法については((<クラス／メソッドの定義/演算子式の定義>))を参照してください。

* 再定義できない演算子(制御構造):

  演算子の組合せである自己代入演算子と (({!=})), (({!~}))
  も再定義できません。

    =  ?:  ..  ...  !  not  &&  and  ||  or  ::

== 代入

例:

          foo = bar
          foo[0] = bar
          foo.bar = baz

文法:

          変数 '=' 式
          定数 '=' 式
          式`['expr..`]' '=' 式
          式`.'識別子 '=' 式

代入式は変数などに値を設定するために用いられます。代入はロー
カル変数や定数の宣言としても用いられます。代入式の左辺は以
下のいずれかでなければなりません。

* 変数

            変数 `=' 式

  左辺値が変数の場合、式を評価した値が変数に代入されます。


* 配列参照

            式1`[' 式2 ... `]' `=' 式n

  式1を評価して得られるオブジェクトに対しての、式 2 から式 n までを
  引数とする (({[]=})) メソッド呼び出しに変換されます。

  例:

            class C
              def initialize
                @ary = [0,1,2,3,4,5,6,7]
              end
              def [](i)
                @ary[i * 2]
              end
              def []=( i, v )
                @ary[i * 2] = v
              end
            end
            c = C.new
            p c[3]      # c.[]( 3 )  に変換され、その結果は 6
            p c[3] = 1  # c.[]=(3,1) に変換され、その結果は 1

* 属性参照

            式1 `.' 識別子 `=' 式2

  式 1 を評価して得られるオブジェクトに対して、
  (({識別子=})) というメソッドを、式 2 を引数にして呼び出します。

  例:

            class C
              def foo
                @foo
              end
              def foo=( v )
                @foo = v
              end
            end
            c = C.new
            c.foo = 5   # c.foo=( 5 ) のように変換される
            p c.foo     # => 5

  属性は ((<Module/attr>)) を使って同じように定義できます。

  例:

            class C
              attr :foo, true
            end
            c = C.new
            c.foo = 5   # c.foo=( 5 ) のように変換される
            p c.foo     # => 5

=== 自己代入

例:

          foo += 12       # foo = foo + 12
          a ||= 1         # a が偽か未定義ならば1を代入。初期化時のイディオムの一種。

文法:

          式1 op= 式2     # 式1は通常の代入の左辺のいずれか

op は以下のいずれかです。演算子と(({=}))の間にスペースを
空けてはいけません。

          +, -, *, /, %, **, &, |, ^, <<, >>, &&, ||

この形式の代入は
      式1 = 式1 op 式2
と評価されます。ただし、(({op})) が &&, || の場合には、
      式1 op (式1 = 式2)
と評価されます。この違いは属性参照のときに
      obj.foo ||= true
が、
      obj.foo = obj.foo || true
でなく
      obj.foo || (obj.foo = true)
と呼ばれることを示します。(obj.foo= は obj.foo の結果によって呼ばれな
いかも知れません)

=== 多重代入

例:

          foo, bar, baz = 1, 2, 3
          foo, = list()
          foo, *rest = list2()

文法:

          式 [`,' [式 `,' ... ] [`*' [式]]] = 式 [, 式 ... ][`*' 式]
          `*' [式] = 式 [, 式 ... ][`*' 式]

多重代入は複数の式または配列から同時に代入を行います。左辺の
各式はそれぞれ代入可能でなければなりません。右辺の式が一つし
か与えられなかった場合、式を評価した値は配列に変換されて、各
要素が左辺のそれぞれの式に代入されます。左辺の要素の数よりも
配列の要素の数の方が多い場合には、余った要素は無視されます。
配列の要素が足りない場合には対応する要素の無い左辺には
(({nil})) が代入されます。

左辺の最後の式の直前に (({*})) がついていると、対応する
左辺のない余った要素が配列として代入されます。余った要素が
無い時には空の配列が代入されます。

例:

          foo, bar = [1, 2]       # foo = 1; bar = 2
          foo, bar = 1, 2         # foo = 1; bar = 2
          foo, bar = 1            # foo = 1; bar = nil

          foo, bar, baz = 1, 2    # foo = 1; bar = 2; baz = nil
          foo, bar = 1, 2, 3      # foo = 1; bar = 2
          foo      = 1, 2, 3      # foo = [1, 2, 3]
          *foo     = 1, 2, 3      # foo = [1, 2, 3]
          foo,*bar = 1, 2, 3      # foo = 1; bar = [2, 3]

((- (({foo = 1, 2, 3})) という書き方は 1.6.2 あたりから可能なようです。
おそらくブロックパラメータの受渡しとの対称性からかと思います
(({proc {|a| p a}.call(1,2,3) #=> [1,2,3]}))
ただし、version 1.8 以降ブロックパラメータの受渡しの方は警告がでるよう
になりました。多重代入の方もversion 1.9 以降この記法はサポートされなく
なるかもしれません((<ruby-dev:20406>))。(({*foo = 1,2,3})) などと明示
的に書くのが無難です。-))

多重代入は括弧により、ネストした配列の要素を代入することもできます。

          (foo, bar), baz = [1, 2], 3       # foo = 1; bar = 2; baz = 3

特殊な形式の代入式も多重代入にすることができます。

            class C
              def foo=( v )
                @foo = v
              end
              def []=(i,v)
                @bar = ["a", "b", "c"]
                @bar[i] = v
              end
            end

            obj = C.new
            obj.foo, obj[2] = 1, 2     # @foo = 1; @bar = ["a", "b", 2]

左辺が `(({,}))' で終る場合や、`(({*}))' の直後の式を省略した場合にも
余った要素は無視されます。

例:

          foo,*    = 1, 2, 3      # foo = 1
          foo,     = 1, 2, 3      # foo = 1
          *        = 1, 2, 3

特に最後の単体の `(({*}))' はメソッド呼び出しにおいて引数を完全に無視
したいときに使用できます。(((<メソッド呼び出し>))の引数の受け渡しは
多重代入と((*ほぼ*))同じルールが適用されます)

例:
        def foo(*)
        end
        foo(1,2,3)

多重代入の値は配列に変換された右辺です。

== 範囲式

例:

          1 .. 20
          /first/  ...  /second/

文法:

          式1 `..' 式2
          式1 ` ... ' 式2

条件式以外の場所では式1から式2までの範囲オブジェクトを返しま
す。範囲オブジェクトは((<Range>))クラス
のインスタンスです。(({ ... }))で生成された範囲オブジェクトは
終端を含みません。

条件式として範囲式が用いられた場合には、式1が真になるま
では偽を返し、その後は式2が真を返すまでは真を返します。式2が
真になれば状態は偽に戻ります。(({..}))は式1が真になっ
た時にすぐに式2を評価し(awkのように)、(({ ... }))は次の
評価まで式2を評価しません(sedのように)。

== and

例:

          test && set
          test and set

文法:

          式 `&&' 式
          式 `and' 式

まず、左辺を評価して、結果が真であった場合には右辺も評価しま
す。(({and})) は同じ働きをする優先順位の低い演算子です。

(({and})) を伴う式をメソッドの引数に渡す場合は二重に括弧が必要となります。

        p(true && false)    #=> false
        p((true and false)) #=> false

== or

例:

          demo || die
          demo or die

文法:

          式 `||' 式
          式 or 式

まず左辺を評価して、結果が偽であった場合には右辺も評価します。
(({or})) は同じ働きをする優先順位の低い演算子です。

(({or})) を伴う式をメソッドの引数に渡す場合は二重に括弧が必要となります。

        p(false || true)    #=> true
        p((false or true)) #=> true

== not

例:

          ! me
          not me
          i != you

文法:

          `!' 式
          not 式

式の値が真である時偽を、偽である時真を返します。

          式 `!=' 式

(({!(式 == 式)}))と同じ。

          式 `!~' 式

(({!(式 =~ 式)}))と同じ。

(({not})) を伴う式をメソッドの引数に渡す場合は二重に括弧が必要となります。

        p(! false)      #=> true
        p((not false))  #=> true

== 条件演算子

例:

           obj == 1 ? foo : bar

文法:

           式1 ? 式2 : 式3

式1の結果によって式2または式3を返します。

           if 式1 then 式2 else 式3 end

とまったく同じです。
