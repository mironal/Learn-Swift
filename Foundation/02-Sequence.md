# `Sequence`

`Sequence` が持つメソッドについて詳しく見ていきましょう.

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

この定義から引数として `transform: (Self.Element) throws -> T` を受け取り、 `[T]` を返すことが読み取れる. つまり、 `map` の前後で型は変わらないの前後で型が変わる.

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

## compactMap

// TODO

## flatMap

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
