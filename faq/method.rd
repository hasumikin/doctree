###nonref

= 5. メソッド

* ((<FAQ::メソッド/5.1 オブジェクトにメッセージを送った時に実行されるメソッドはどのように捜されますか>))
* ((<FAQ::メソッド/5.2 (({+}))や(({-}))は演算子ですか>))
* ((<FAQ::メソッド/5.3 関数はありますか>))
* ((<FAQ::メソッド/5.4 オブジェクトのインスタンス変数を外から参照できますか>))
* ((<FAQ::メソッド/5.5 (({private}))と(({protected}))の違いが分かりません>))
* ((<FAQ::メソッド/5.6 インスタンス変数をpublicにしたいのですが>))
* ((<FAQ::メソッド/5.7 メソッドの可視性を指定したいのですが>))
* ((<FAQ::メソッド/5.8 メソッド名に大文字で始まる識別子は使えますか>))
* ((<FAQ::メソッド/5.9 (({super}))が(({ArgumentError}))になりますが>))
* ((<FAQ::メソッド/5.10 2段階上の同名のメソッドを呼びたいのですが>))
* ((<FAQ::メソッド/5.11 組み込み関数を再定義した時に、元の関数を呼びたい時はどうしますか>))
* ((<FAQ::メソッド/5.12 破壊的メソッドとは何ですか>))
* ((<FAQ::メソッド/5.13 副作用が起こるのはどんな時ですか>))
* ((<FAQ::メソッド/5.14 メソッドから複数の戻り値を返すことはできますか>))
* ((<FAQ::メソッド/5.15 今実行中のメソッドの名前を知りたいのですが>))

== 5.1 オブジェクトにメッセージを送った時に実行されるメソッドはどのように捜されますか

特異メソッド、自クラスで定義されたメソッド、スーパークラス(Mix-inされた
モジュールを含む。クラス名.ancestorsで表示される。)で定義されたメソッドの順に
最初に見つかったメソッドが実行されます。メソッドが見つからなかった
場合には、(({method_missing}))が同じ順で捜されます。

  module Indexed
    def [](n)
      to_a[n]
    end
  end
  class String
    include Indexed
  end
  p String.ancestors # [String, Indexed, Enumerable, Comparable, Object, Kernel]
  p "abcde".gsub!(/./, "\\&\n")[1]

は、残念ながら期待するように"b\n"を返してくれず、10を返してきます。
[]がStringクラスで捜され、Indexedで定義されたものを捜し出す前に
マッチしてしまうからです。Class Stringで直接[]を再定義すれば、
期待どおりになります。

== 5.2 (({+}))や(({-}))は演算子ですか

(({+}))や(({-}))などは演算子ではなくメソッド呼び出しです。したがって
オーバーライド(再定義)することもできます。

  class MyString < String
    def +(other)
      print super(other)
    end
  end

ただし、以下のもの及びこれらを組み合わせたもの(!=、!~)は制御構造であり、
オーバーライドできません。

  =, .., ..., !, not, &&, and, |, or, ~, ::

単項演算子をオーバーライド(もしくは定義)するには、メソッド名として
(({+@}))や(({-@}))を使います。

(({=}))は、インスタンス変数へのアクセスメソッドとして,
クラス定義の中で次のようにメソッドを定義することができます。
また、(({+}))や(({-}))なども定義することにより、(({+=}))
などの自己代入演算も可能になります。

  def attribute=(val)
    @attribute = val
  end

== 5.3 関数はありますか

Rubyにおいて関数のように見えるものはすべてレシーバ(self)を省略した形の
メソッドです。例えば

  def writeln(str)
    print(str, "\n")
  end

  writeln("Hello, World!")

のように一見関数のように見えるものも、((<Object>))クラスに定義された
メソッドであり、隠されたレシーバー(({self}))に送られているというわけです。
したがってRubyを純粋なオブジェクト指向言語と呼ぶことができます。

組み込み関数のように、(({self}))が何であっても同じ結果を返すメソッドは、
レシーバーを意識する必要がありませんので、関数と考えてもいいという
ことになります。
 
== 5.4 オブジェクトのインスタンス変数を外から参照できますか

直接はできません。あらかじめそのオブジェクトにインスタンス変数を
参照するためのメソッド (アクセサと言います) を定義しておく必要が
あります。たとえば以下のようにします。

    class C
      def name
        @name
      end
      def name=(str)    # name の後に空白を入れてはいけない！
        @name = str
      end
    end

    c = C.new
    c.name = 'やまだたろう'
    p c.name                 #=> "やまだたろう"

またこのような単純なメソッド定義は (({Module#attr}))、(({attr_reader}))、
(({attr_writer}))、(({attr_accessor})) などを使って簡潔に行うことができます。
たとえば上にあったクラス定義は以下のように書き直せます。

    class C
      attr_accessor :name
    end

なんらかの理由でアクセスメソッドは作りたくないけれど参照はしたい場合は
(({Object#instance_eval})) を使って参照することもできます。

== 5.5 (({private}))と(({protected}))の違いが分かりません

(({private}))の意味は、メソッドを関数形式でだけ呼び出せるようにし、
レシーバー形式では呼び出せないようにするという意味です。したがって、
可視性が(({private}))なメソッドは、自クラス及びサブクラスからしか参照
できません。

(({protected}))も同様に、自クラス及びサブクラスからしか参照できませんが、
関数形式でもレシーバー形式でも呼び出せます。

メソッドのカプセル化に必要な機能です。

== 5.6 インスタンス変数をpublicにしたいのですが

変数を直接外から見えるようにすることはできません。Rubyではインスタンス
変数へのアクセスはアクセスメソッドを使って行います。例えば次のように
します。

  class Foo
    def initialize(str)
      @name = str
    end

    def name
      return @name
    end
  end

しかし毎回これを書くのは面倒です。そこで(({attr_reader}))、(({attr_writer}))、
(({attr_accessor}))と言ったメソッドを使うとこのような単純なメソッド定義を
簡単に書くことができます。

  class Foo
    def initialize(str)
      @name = str
    end

    attr_reader :name
    # 次のように書いたのと同じです。
    # def name
    #   return @name
    # end
  end

  foo = Foo.new("Tom")
  print foo.name, "\n"         # Tom

(({attr_accessor}))を使うと書き込み用のメソッドも同時に定義できます。

  class Foo
    def initialize(str)
      @name = str
    end

    attr_accessor :name
    # 次のように書いたのと同じです。
    # def name
    #   return @name
    # end
    # def name=(str)
    #   @name = str
    # end
  end

  foo = Foo.new("Tom")
  foo.name = "Jim"
  print foo.name, "\n"    # Jim

同様に書き込み用のメソッドだけ定義したければ(({attr_writer}))が使えます。

== 5.7 メソッドの可視性を指定したいのですが

まず、Rubyでは関数形式(レシーバを省略した形)でしか呼び出すことのできない
メソッドのことをprivateなメソッドと呼んでいます。C++やJavaのprivateとは
意味が違うので注意してください。

メソッドをprivateにすると、そのメソッドは別のオブジェクトからは
呼び出すことができなくなります。クラス内か、そのサブクラスからしか
使わないメソッドはprivateにしておきましょう。

次のようにすればメソッドをprivateにすることができます。

  class Foo
    def test
      print "hello\n"
    end
    private :test
  end

  foo = Foo.new
  foo.test
  #=> test.rb:9: private method `test' called for #<Foo:0x400f3eec>(Foo)

クラスメソッドをprivateにするには(({private_class_method}))を使います。

  class Foo
    def Foo.test
      print "hello\n"
    end
    private_class_method :test
  end

  Foo.test
  #=> test.rb:8: private method `test' called for Foo(Class)

同様に(({public}))、(({public_class_method}))を用いることでメソッドを
publicにすることができます。

デフォルトでは、クラス内でのメソッド定義はinitializeを除いてpublic、
トップレベルではprivateになっています。

== 5.8 メソッド名に大文字で始まる識別子は使えますか

使えます。ただし、引数の無いメソッド呼び出しに対して引数を括る括弧を
省略できなくなります。

== 5.9 (({super}))が((<ArgumentError>))になりますが

メソッド定義中で(({super}))と呼び出すと、引数がすべて渡されますので、
引数の数が合わないと((<ArgumentError>))になります。異なる数の引数を
指定するには、(({super}))に引数を指定してやります。

== 5.10 2段階上の同名のメソッドを呼びたいのですが

(({super}))は、1段上の同名のメソッドしか呼べません。それより上の同名の
メソッドを呼び出すには、あらかじめそのメソッドをaliasしておきます。

== 5.11 組み込み関数を再定義した時に、元の関数を呼びたい時はどうしますか

メソッド定義の中では(({super}))が使えます。再定義する前に(({alias}))
しておくと、元の定義が保たれます。
((<Kernel>))の特異メソッドとしても呼べます。

== 5.12 破壊的メソッドとは何ですか

オブジェクトの内容を変更してしまうメソッドで、文字列や配列、ハッシュ
などにあります。同名のメソッドがあって、一方はオブジェクトのコピーを
作って返し、もう一方は変更されたオブジェクトを返すようになっている場合、
!のついた方が破壊的メソッドです。ただし、!がつかないメソッドの中にも
String#concatのように破壊的なものはあります。

== 5.13 副作用が起こるのはどんな時ですか

実引数であるオブジェクトに対して、メソッドの中から破壊的メソッドを
適用した場合です.

  def foo(str)
    str.sub!(/foo/, "baz")
  end

  obj = "foo"
  foo(obj)
  print obj
  #=> "baz"

この場合、引数となったオブジェクトが変更されています。でも、これは、プログラム
の中で((*必要があって*))副作用のあるメッセージをオブジェクトに対し
て送っているので当たり前です。

== 5.14 メソッドから複数の戻り値を返すことはできますか

Rubyでは、メソッドの戻り値は一つしか指定できませんが、
配列を使うことによって、複数の戻り値を返すことができます。

  return 1, 2, 3

とするとreturnに与えたリストが配列として返されます。つまり上記のコードは
次のように書くのと全く同じ意味です。

  return [1, 2, 3]

さらに多重代入を利用すると、複数の戻り値を戻すのとほとんど同じことがで
きます。たとえば、

  def foo
    return 20, 4, 17
  end

  a, b, c = foo
  print "a:", a, "\n" #=> a:20
  print "b:", b, "\n" #=> b:4
  print "c:", c, "\n" #=> c:17

こんなことができるわけです。

== 5.15 今実行中のメソッドの名前を知りたいのですが
callerを使って調べることが出来ます。
((-((<今実行中のメソッドの名前は…|URL:http://www.rubyist.net/~nobu/t/20051013.html#p02>))より。-))
  def current_method
    caller.first[/:in \`(.*?)\'\z/, 1]
  end

  def some_method
    p current_method #=> "some_method"
  end
