# `List`

リスト (主に `Sequence`) が持つメソッドについて詳しく見ていきましょう.

## filter

**関心:** `Element` がある条件を満たすかどうか.

**詳細:**

このメソッドは `protocol Sequence` に

`func filter(_ isIncluded: (Self.Element) throws -> Bool) -> [Self.Element]`

という形で定義されている.

この定義から引数として `isIncluded: (Self.Element) throws -> Bool` を受け取り、 `[Self.Element]` を返すことが読み取れる.つまり、 `filter` の前後で型は変わらない.

引数 `isIncluded: (Self.Element) throws -> Bool` は `Element` がある条件を満たすかどうかを示す関数であると読み取れる.

またメソッド名が `filter` なので条件に当てはまるものを残すことが推測できる(仮に `reject` だったら除去すると推測できる).

つまり `filter` の機能はある条件を満たす `Element` の配列を返すメソッドであることがわかる.

### 課題

`filter` を自分で実装してみよう.

```swift
extension Array {
    // filter だと名前が被るので `myFilter` にする
    func myFilter(_ isIncluded: (Self.Element) throws -> Bool) -> [Self.Element] {}
        // ここを実装してみよう
    }
}
```

## map

**関心:** `Element` を別の型(T)に変えることに関心がある.

**詳細:**

このメソッドは `protocol Sequence` に

`func map<T>(_ transform: (Self.Element) throws -> T) rethrows -> [T]`

という形で定義されている.

この定義から引数として `transform: (Self.Element) throws -> T` を受け取り、 `[T]` を返すことが読み取れる. つまり、 `map` の前後で型が変わる.

引数 `transform: (Self.Element) throws -> T` は `Element` を別の型 `T` に変換する関数であることが読み取れる.

またメソッド名が `map` なことからある集合を別の集合に写す写像であることが読み取れることから要素数が変化しないことが読み取れる.

> これを読み取るには単語としての map (地図)では無く数学用語としての map に写像という意味があり、写像はある要素を別の集合の特定の要素に結びつける操作のことで、この操作の前後では要素数が変わらない性質があるという前提知識が必要.

つまり `map` は `Element` を `T` に変換した配列を返すメソッドであることがわかる.

### 課題

`map` を自分で実装してみよう.

```swift
extension Array {
    // map だと名前が被るので `myMap` にする
    func myMap<T>(_ transform: (Self.Element) throws -> T) rethrows -> [T] {
        // ここを実装してみよう
    }
}
```

## flatMap

**関心: 構造のネストが深くならないように map する** <- 我ながら超難しいと思う.

**詳細**

このメソッドは `protocol Sequence` に

`func flatMap<SegmentOfResult>(_ transform: (Self.Element) throws -> SegmentOfResult) rethrows -> [SegmentOfResult.Element] where SegmentOfResult : Sequence`

という形で定義されている(長くて難しそうだ！).

`Optinal` に定義されている `func flatMap<U>(_ transform: (Wrapped) throws -> U?) rethrows -> U?` という形のほうがわかりやすいかもしれない.

はっきり言って `flatMap` を説明するのはめちゃ難しい. 文字で書いてみたけど下のようになって全然うまく説明できない(うまく行かなかったので details で囲んで折りたたんでおいた).

<details>

`Sequence` に定義されている方のメソッドを読むと `flatMap` は`transform: (Self.Element) -> SegmentOfResult` を受け取り、 `[SegmentOfResult.Element]` を返すことがわかる.

さらに `where` 以降の部分から `SegmentOfResult` は `Sequence` であると読める.

つまり `transform` は1つの `値` を受け取って `Sequence` を返すのである(map のときは値を受け取って値を返していた).

[ドキュメント](https://developer.apple.com/documentation/swift/sequence/2905332-flatmap)の `Parameters` の部分を見ると同じことが書いてある

> A closure that accepts an element of this sequence as its argument and returns a sequence or collection.

とあるので

> シーケンス(Self のこと)の値を1つ引数として受け入れて、sequence または collection を返すクロージャー

という事を言っている.

そしてもうひとつ重要なことが同じページの `Return Value` にかかれている.

> The resulting flattened array.

とは

> flatten された配列を返す.

`flatten` とは `[[1,2], [3]]` となっているものを `[1,2,3]` とすることだ. 日本語にすると平坦化と訳せるけど日本語でも `flatten` あるいは `flat にする` という言い方をするので覚えておこう.

説明がすごく長くなったが `flatMap` が行っていることは以下のようになる.

1. ある `Sequence` があるとする. ex) [1,2,3]
2. それを `transoform` を使って別の `Sequence` にする. ex) [[1], [2,2], [3,3,3]]
3. それを flatten して return する. ex) [1,2,2,3,3,3]

動きはわかったかな？ でもなんでこんなメソッドが必要なんだ！！！！！

</details>

色々書いてて思ったんだけど、どんなに `flatMap` の動作を説明してもなんでこんなメソッドがあるのか分からなければ使い所が分から理解が難しいと思った.

なのでここからは具体的に `flatMap` があってよかったと思える場面を例に出しながら説明しようと思う.

まずは以下のように `maybeOne()` と `maybeDouble()` というメソッドがある. それぞれの処理は File I/O だったりネットワークリクエストとかと同じようにときどき失敗して値が取れないときがあるとする(ここでは説明を簡単にするために常に値を返しています).

```swift
func maybeOne() -> Int? {
    return .some(1)
}

func maybeDouble(_ value: Int) -> Int? {
    return .some(value * 2)
}
```

ここで `maybeOne` で取得した値を `maybeDouble` で処理した結果の値が欲しいとしよう. 今まで勉強した知識を使うと `map` を使って以下のようにかっこよく書ける.

※ 現実の世界ではネットワークリクエストの結果をファイルに保存するみたいなよくある場面だと想像してほしい.

```swift
let result = maybeOne().map { maybeDouble($0) }
print(result)
// Optional(Optional(2))
```

でも得られた結果は `Optional(Optional(2))` というネストした構造ですごい使いにくそう.

`Optional(Optional(2))` は `Optional(2)` と同じ意味だし、もしも `Optional(Optional(nil))` なら `nil` になってほしい.

そこで便利なのが `flatMap` だ.

```swift
let result = maybeOne().flatMap { maybeDouble($0) }
print(result)
// Optional(2)
```

超すごい.

これが `flatMap` が関心を持っている `構造のネストが深くならないように map する` ということだ.

### 課題 1

`[1,2,3,4,5]` を `[1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5]` に変換するコードを `flatMap` を使って書いてみよう.

```swift
let result = [1,2,3,4,5].flatMap {
    // ここに書く
}

print(result)
// [1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5]
```

### 課題 2

`flatMap` を使わずに↑と同じ処理を行ってみよう.

### 課題 3

`Result` にも `map` や `flatMap` が宣言されていることをドキュメントを読んで確認してみよう.

また、何かそれらを使ったサンプルコードを書いてみよう.

## compactMap

// TODO

## コラム

`filter`, `map`, `flatMap`, `compactMap` の適用前後で要素数がどう変化するかの表.

適用後の要素数とは

```swift
let src = [1,2,3,4]
let dest = array.map(f)
```

したときの `src` の要素数(`src.count`)に対して `dest` の要素数(`dest.count`)がどうなっているかのことである.

以下の表では簡単に示すために `src.count` は N, `dest.count` は N' と表現する.

|関数|適用後の要素数| 説明 |
|---|---|---|
| filter | N >= N'| 元の数より減ることはあるが増えることはない. |
| map | N = N' | 要素数は変わらない |
| compactMap | N => N' | 元の数より減ることはあるが増えることはない. filter と同じ. `compactMap` は `map + filter` と等価なのでそこからも推測できる. |
| flatMap | N = N' \| N != N' | 要素数は変わらないかもしれないし、減るかもしれないし、増えるかもしれない. 何でも起こりうる. `Array(s.map(transform).joined())` と等価. |
