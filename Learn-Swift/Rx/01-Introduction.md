# 01 Introduction

ここでは RxSwift でよく出てくる言葉について説明します.

## Observable の基本

- `Observable` (`ObservableType`) は `Sequence` と等価です.
- `Observable.subscribe` は `Sequence.makeIterator` と等価です.
    - より正確には `makeIterator` の返り値を使うのではなく直接ブロックを渡すので `makeIterator(onNext:)` という表現が近いです.

このような性質を持つので `Rx` の文脈で語られる生成(create)したり購読(subscribe)したりできるものを `Observable` な sequence と呼びます.

また

`Observable` は

- 0回以上の値を持つイベントが発生します
    - `next(element:)`
- 一回の Error または Complated というイベントが発生します
    - このイベントが発生すると他のイベントは発生しなくなります

これはコードで表すと以下のように表現できます. ここで `Disposable` は `subscribe` をキャンセルするための識別子です.

#### code 1

```swift
enum Event<Element>  {
    case next(Element)      // next element of a sequence
    case error(Swift.Error) // sequence failed with error
    case completed          // sequence terminated successfully
}

class Observable<Element> {
    func subscribe(_ observer: Observer<Element>) -> Disposable
}

protocol ObserverType {
    func on(_ event: Event<Element>)
}
```

## Marble Diagrams

`Observable` のシーケンスはしばしば以下のような文字の図で表現され、これらを Marble Diagrams と呼びます.

いくつかの例と説明を載せておきます.

`--1--2--3--4--5--|` // これは Int の値が流れるシーケンスで Complate で終了しています.

`--a--b--c--d--e--X` // これは Character が流れるシーケンスで Error で終了しています.

`--tap--------tap->` // これはボタンなどのタップのイベントが流れるシーケンスで終りがありません.


## 課題

### 課題 1

`code 1` で示した `Event`、 `Observable`、 `ObserverType` にそれぞれコードコメントを付けてみよう.

```swift
/**
    ここに追記
*/
enum Event<Element>  {}

/**
    ここに追記
*/
class Observable<Element> {}

/**
    ここに追記
*/
protocol ObserverType {}
```

### 課題 2

今回説明しなかった `DisposeBag` とは何か以下のページを参考に日本語で説明してみよう.

> https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md
