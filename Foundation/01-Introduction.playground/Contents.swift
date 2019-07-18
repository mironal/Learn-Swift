import Cocoa

/*
 # Introduction
 
 ## ここで学ぶこと
 
 Swift で配列型や辞書型などを扱う場合に避けては通れない以下のプロトコルについて説明します.
 
 - IteratorProtocol
 - Sequence
 - Collection
 
 それぞれのプロトコルが何を示しているのか、またなぜそのようなものが定義されているのかを理解することでこのあとの学習の助けになるようにします.
 
 ここでは簡単な例しか説明しませんが、あとに進むに連れて具体的な例が沢山出てくるのでそれらを通して理解を深めていければいいと思うので、ここで完全に理解する必要はありません.
 
 またなぜ最初にコレクションに関することに関して学ぶかと言うと、これらの考え方は非常に応用範囲が広く、 `Optional` や `String`, `RxSwift` などもコレクションという考え方抜きには語ることができないからです.
 
 ## コレクション基礎
 
 Swift のコレクション(注: 型として宣言されている Collection のことではなく一般的な意味でのコレクションはカタカナで表記します)は以下のような階層構造になっています.
 
 
 また代表的な protocol の右側に簡単な説明を書いておきますが、後ほど詳しく説明します.
 
 ```
 | Element  |
 |
 | Iterator | コレクションの次の値を生成するための protocol
 |
 | Sequence | ある特定の Itelator を生成するための protocol
 |
 | Collection | 有限コレクション
 |       |
 | Mutable Collection | |BidirectionalCollection |
 |
 | RandomAccessCollection|
 ```
 
 一般的に以下のようなことが言えます.
 
 - 上のにあるほど成約が少なく、できること(メソッド数)が少ない.
 - 下のにあるほど成約が多く、できること(メソッド数)が多い.
 
 迷子になったらここに戻ってきましょう. この関係は重要なので覚えてしまっても損はないです.
 
 ### 有限/無限リスト
 
 コレクションにはその要素数が有限のものもあれば無限のものもあります. それぞれ `有限リスト`、 `無限リスト` と呼びます.
 
 有限リストは Swift の Array などの形でよく使われるので馴染みがあると思います.
 
 一方で `無限リスト` はあまり馴染みが無いかもしれません.
 
 一つの例として、すべての自然数が入った配列があります. 自然数は無限にあるので `[1,2,3,4,5....., ∞]` のような表現になり、実際に Swift の Sequence を使って表現することができます(すごい！).
 
 でもこれだとメモリが足りなくなりそうですよね？ でも実際は大丈夫です. なぜなのかは読み進めたあとにじっくりと考えてみてください.
 
 ### 片方向/双方向リスト
 
 コレクションには先頭から最後まで順番にたどることができるものと、それに加えて最後から先頭までだどることができるものがあります. 前者を `片方向リスト`, `単方向リスト`、`シーケンス` などと呼び、後者を`双方向リスト`、`リンクドリスト`、`連結リスト` などと呼びます.
 
 それぞれ、要素の参照時の計算コスト、要素の挿入、削除の計算コスト、メモリコストなどがよく話題になるので知っている人も多いと思います.
 
 ## IteratorProtocol
 
 `IteratorProtocol` は普段はあまり目にしない protocol ですがこのあとで説明する `Sequence` で出てくるので最初に説明しておきます.
 
 https://developer.apple.com/documentation/swift/iteratorprotocol によれば
 
 > A type that supplies the values of a sequence one at a time.
 
 と書かれており、その定義は以下のようになっています.
 
 ```swift
 public protocol IteratorProtocol {
 associatedtype Element
 
 /// Advances to the next element and returns it, or nil if no next element exists.
 mutating func next() -> Self.Element?
 }
 ```
 
 これらのことからこの protocol は以下のように読むことができます.
 
 1. `IteratorProtocol` という名前
 1. 何らかの型 `Element` と関連付けられている
 1. 次の要素に進む `next()` というメソッドを持っている
 - `next()` は次の要素があれば `Element` をなければ `nil` を返す
 
 `進む` というのは `Advances to the next element` と言うコメントから読み取れます.ここで言っている進むというのは例えば以下のような配列があった場合に現在の位置が `1` だとすると `next() ` を呼び出したあとは現在の位置が `2` になるというイメージです.
 
 ```
 [1,2,3,4] -> next() -> [1,2,3,4] -> next() -> [1,2,3,4]
 ↑                        ↑                        ↑
 ```
 
 ### 要点のまとめ
 
 `IteratorProtocol` は
 
 - `Element` という任意の型に関連付けることができる
 - `Element` のコレクションの次の値に進む `next()` というメソッドを持っている
 - 要素数は不明(有限かもしれないし無限かもしれない)
 - 前の要素に戻ることはできない => 一度しかイテレーションできない.
 
 ### Sequence
 
 > https://developer.apple.com/documentation/swift/sequence
 
 によれば
 
 > A type that provides sequential, iterated access to its elements.
 
 と書かれています.これは日本語に訳すと 「その要素への順次の反復アクセスを提供する型」となりこのままだと意味不明かもしれません. こういうものは後々の学習のためにも日本語訳して頑張って理解するのではなく英語が何を言っているのかをしっかり理解してしまうことが重要です. まずは前半について説明します.
 
 ###  Tips:
 `A type that provides sequential` は直訳すると `連続的な type` という意味です. よく `A type that provides ~~.` という表現が出てくるのでパターンとして覚えましょう. `~~` に `どんな` という表現が入ります.
 
 さて Sequence の定義は以下のようになっています.
 
 ```swift
 public protocol Sequence {
 associatedtype Element where Self.Element == Self.Iterator.Element
 associatedtype Iterator : IteratorProtocol
 func makeIterator() -> Iterator
 }
 ```
 
 `Itelator` を作るための `makeIterator` というのが定義されていることがわかります. つまり `Sequence` は `Iterator` を作ることができる型ということを示しています.
 
 こういう型は `Int` などの具体的な値を示す型ではなく構造を表す(今回の場合は `Iterator` を作ることができるという構造)ものなので直感的にイメージしにくいですが、とりあえず今の段階ではそういう構造なんだなということだけ理解しておいてください.
 
 ### 特徴
 
 `Sequence` には以下のような特徴があります.
 
 #### for で loop できる
 
 `Sequence` に準拠していると for で loop できます.
 
 ```swift
 for item in sequence  {
 print(item)
 }
 ```
 
 この性質から `contains`、 `min`, `map`, `filter`, `reduce` などのよく使う便利なメソッドが定義できます.
 
 #### 繰り返し loop できるかはわからない
 
 以下のような処理を書いた場合2回目の for では `print` 部分が実行される保証はありません. なぜなら `Sequence` は先頭の要素にに戻る方法が定義されていないからです.
 
 このようなイテレーションを `destructively iteration` (破壊的なイテレーション)と呼び、その反対の性質を持つものを `nondestructive iteration` と呼び、次に出てくる `Collection` がそれです.
 
 ```swift
 for item in sequence  {
 print(item)
 }
 
 for item in sequence  {
 print(item) // 実行されない
 }
 ```
 
 #### 加算
 
 `Sequence` 同士は足し算することができます.
 
 `[1,2,3,4] + [6,7,8]`
 
 ### 要点のまとめ
 
 `Sequence` は
 
 - `makeIterator()` で Iterator を作ることができる -> つまり先頭からやり直すことができる.
 - `Iterator` の 実態は `IteratorProtocol` なので
 - 要素数は不明(有限かもしれないし無限かもしれない)
 - 前の要素に戻ることはできない => 一度しかイテレーションできない
 - `IteratorProtocol` の特性を利用して様々な演算を定義できる
 */

/*
 ### 課題 1
 
 以下のように 0〜5まで出力する `Sequence` を作ってみよう. このとき、`CountFiveSequence` は破壊的なイテレーションをができる `Sequence` として作ってみましょう.
 
 fork して PR を送ろう.
 
 ```swift
 struct CountFiveSequence: Sequence, IteratorProtocol {
 // ここを実装
 }
 
 let seq = CountFiveSequence()
 
 for item in seq {
 print(item)
 }
 // 0
 // 1
 // 2
 // 3
 // 4
 // 5
 ```
 */

/*
 ### 課題 2
 
 Int 型の無限リストを作ってみよう. ただし for で loop させないように！！(止まらなくなります)
 
 正解は何パターンもあるので思いついたやつで大丈夫です.
 
 ```swift
 struct InfList: Sequence, IteratorProtocol {
 // ここを実装
 }
 
 var list = InfList().makeIterator()
 
 for i in 0..<100 {
 print(list.next())
 }
 
 ```
 */

/*
 ## Collection
 
 > https://developer.apple.com/documentation/swift/collection
 
 によれば以下のように説明されています.
 
 > A sequence whose elements can be traversed multiple times, nondestructively, and accessed by an indexed subscript.
 
 `A sequence` と始まっているので `Sequence` の一種でそれに続く文にどういう特性があるかを説明しています.
 
 長いですが要点は `何回でも横断でき(traversed)、破壊されず、さらにインデックスを使ってアクセスできるシーケンス` という部分で、これらの特徴が `Sequence` に対して追加されている(= 成約が厳しくなった)ということになります.
 
 `traverse` は別の言葉でいうと `scan` のようなイメージです. `[1,2,3,4]` という配列があった場合、1から4まで順繰りに見ていくイメージで、 `Collection` ではそれが何回でもできると言っています.
 
 私達が普段使っている配列や辞書は `Collection` の一種です.
 
 さて、`Collection` の定義を見てみましょう(一部抜粋). `Sequence` と比較してプロパティやメソッドが増えていることから成約が多くなったことが読み取れます.
 
 
 ```swift
 public protocol Collection : Sequence {
 
 associatedtype Element
 associatedtype Index : Comparable
 
 var startIndex: Self.Index { get }
 var endIndex: Self.Index { get }
 
 func index(after: Self.Index) -> Self.Index
 
 subscript(position: Self.Index) -> Self.Element { get }
 }
 ```
 
 まず `Index` という型に注目しましょう. これは `Collection` の中のある要素の位置を示す型でドキュメントでは `A type that represents a position in the collection.` と書かれています. `represents` というのも頻出単語で `○○を表す` という意味で使われます. つまりコレクション内(in the collection)の位置を示す型(A type that represents a position)という意味です.
 
 具体的な例としては `Array` の `Index` は `Int` です.
 
 そしてそれらを使ったプロパティである `startIndex: Self.Index` と `endIndex: Self.Index` はコレクションの最初の位置と最後の位置を示しています.
 
 `subscript(position: Self.Index) -> Self.Element` です. これはある `Index` に対応する要素 `Element` を取得する関数です. 普段は配列などで `array[1]` と呼び出されます.
 
 ちなみに `{ get }` となっているので `Collection` では各要素は readonly です.
 
 `index(after: Self.Index) -> Self.Index` はある index の次の要素の index を返すメソッドです. `IteratorProtocol` の `next()` みたいなやつですね.
 
 以上をまとめて
 
 1. 開始/終了位置がある
 2. `subscript(position:)` を使って要素が取得できる
 3. `index(after:)` を使って次の要素の Index が取得できる
 
 というのが `Collection` になるための条件です. これはドキュメントには [`Conforming to the Collection Protocol`](https://developer.apple.com/documentation/swift/collection) の部分に書かれています. すなわちこれらのみ実装すれば他の多くのメソッドは自動的に実装されるということを示しています.
 
 こうしてみてみると、 `Sequence` はただ単純に次の値にアクセスする方法しか用意されていなかったのに対して `Collection` は `Index` を介してそれぞれの値にアクセスしているので値とインデックスが分離されたと考えることができますね.
 
 このように一つだった何かを、何かと何かに分離してより便利な構造で表現するという手法はプログラミングの様々な場面で出てくるので意識してみると良いと思います.
 
 ### 特徴
 
 
 #### それぞれの要素にアクセスできる
 
 例えば `Sequence` だと10番目の要素に直接アクセスすることはできず `next()` を繰り返し呼び出して取得する必要がありました.
 
 一方 `Collection` では `index(after:)` と `subscript(position:)` を使うことで10番目の値を直接取得できます.
 
 これはそれぞれの要素の値の生成に非常にコストがかかる場合に特に有利に働きます.
 
 #### 何度でも for loop できる (Traverse 可能)
 
 `Sequence` は二回目以降の loop に関しては動作が保証されていませんでしたが、 `Collection` は保証されています.
 
 ```swift
 for item in collection  {
 print(item) // 実行される
 }
 
 for item in collection  {
 print(item) // 実行される
 }
 ```
 
 #### 前の要素に戻ることができない
 
 `Collection` は `index(after:)` によって次の要素を知ることはできるが前の要素の `Index` を取得することはできない. つまり単方向リストである.
 */



/*
 ### 課題 1
 
 `Collection` は `Sequence` と比較してどのような特徴があるか自分の言葉でいくつか挙げてみよう.
 */

// ✏️ここに記載


/*
 ### 課題 2
 
 `CountFiveSequence` の `Collection` 版 `CountFiveCollection` を作ってみましょう.
 
 ```swift
 struct CountFiveCollection: Collection {
 // ここを実装
 }
 
 let col = CountFiveCollection()
 
 for item in col {
 print(item)
 }
 // 0
 // 1
 // 2
 // 3
 // 4
 // 5
 for item in col {
 print(item)
 }
 // 0
 // 1
 // 2
 // 3
 // 4
 // 5
 ```
 
 */

// ✏️ここに記載


/*
 ### 課題 3
 
 Swift には `Collection` の `前の要素に戻ることができない` という特徴を克服した `BidirectionalCollection` というものがあります.
 
 `BidirectionalCollection` には `Collection` と比べてどんなメソッドが必要なのか調べて説明してみよう.
 */

// ✏️ここに記載

