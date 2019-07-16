# Operator

RxSwift には様々な Operator が実装されています. 全てを一つ一つ説明することは大変なので代表的ないくつかのみ説明します.

これらを通して学習することで Operator もドキュメントを読んだりサンプルコードを書いてみることで理解することができます.

## Custom operator の書き方

課題で Operator を書いて貰う予定なのではじめに Custom operator の書き方のサンプルコードを載せておきます.

```swift
extension ObservableType {
    // map と同じようなもの
    func f<R>(transform: @escaping (E) -> R) -> Observable<R> {
        return .create { observer in

            let subscription = self.subscribe { ev in

                switch ev {
                case .next(let value):
                    observer.onNext(transform(value))
                case .error(let error):
                    observer.onError(error)
                case .complated:
                    observer.onCompleted()
                }
            }
            return subscription
        }
    }
}
```

## map

RxSwift の `map` は `Sequence` の `map` と同様にある値を別の値に変換することに関心があります.

`map` の定義を見てみましょう

```swift
func map<Result>(_ transform: @escaping (Self.Element) throws -> Result) -> RxSwift.Observable<Result>
```

これは　`Observable<Element>` を `transform: Element -> Result` という Closure を使って `Observable<Result>` に変換していると読めます.

つまり、 `map` を使ってある値を別の値に変換する. `値` にのみ関心があり、 `Observable` には一切関心がありません.

これは `map` の前後でイベントの個数が変化しないことを示唆しています(`Sequence` のときもそうでしたね？).

### 課題

http://reactivex.io/documentation/operators/map.html にかかれている map の説明 `transform the items emitted by an Observable by applying a function to each item` を日本語訳しましょう.

※補足 `applying a function` とは関数を呼び出すということとほぼ同じですが、ラムダ計算などの学術的な領域では関数呼び出しのことを関数に特定の値を適用すると捉えそれを`関数適用` と呼び、適用した結果の値を得ることを`評価`すると呼びます.

## flatMap (TODO)

次はちょっと難しい `flatMap` です.

```swift
func flatMap<Source>(_ selector: @escaping (Self.Element) throws -> Source) -> RxSwift.Observable<Source.Element> where Source : ObservableConvertibleType
```

これは `Observable<Element>` を `selector: Element -> Source` という Closure を使って `Observable<Source.Element>` に変換していると読めます. ただし `Source : ObservableConvertibleType`.

いちばん大事なのは Closure の部分なので詳しく見ていきましょう.

`Source` は `Source: ObservableConvertibleType` という条件がついているので `Observable<Element'>` と置き換えることができます. ただし `Element'` は `Element` を変形して作った型.

これを踏まえると先の Closure は `selector: Element -> Observable<Element'>` と書くことができ `Element` を `Observable<Element'>` に変換していると読むことができます.

つまり

```swift
// observable は Observable<Element> な値
observable.flatMap {
    // Element を Observable<Element'> に変換
    // Element -> Observable<Elenent'>
}
```

です.

`flatMap` は非常に柔軟なのでいろいろな場面で使えます.



##
