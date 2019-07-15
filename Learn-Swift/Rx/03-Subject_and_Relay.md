# Subject and Relay

`Observable` は `subscribe` しかできませんが、`Subject` や `Relay` は `subscribe` 可能で、かつイベントを発生させることができます.

## Subject

`Subject` には `PublishSubject` と `ReplaySubject`、 `BehaviorSubject` があります. `AsyncSubject` というものもありますが今回は説明しません.


### PublishSubject

`PublishSubject` では全てのイベントが subscribe 済みの Observer に届きます.

**subscribe 済み** というのが重要で、 subscribe していなかったときのイベントに関しては subscribe しても受け取ることができません.

### ReplaySubject

`ReplaySubject` では全てのイベントが subscribe 済みの Observer に届き、さらに 指定した `bufferSize` の数だけ subscribe 以前に発生したイベントを新しい Observer に届けます.

`PublishSubject` と大きく異なるのは subscribe 以前に発生したイベントも受け取れる点です.

また初期値も必要ありません.

### BehaviorSubject

`BehaviorSubject` では全てのイベントが subscribe 済みの Observer に届き、さらに最も最近の値(または初期値)が新しく subscribe した Observer にも届きます.

この Subject を作る際には初期値が必要です.

### 課題

以下のコードで A〜E それぞれどのような出力が得られるでしょうか？

```swift

// A: let subject = PublishSubject<Int>()
// B: let subject = ReplaySubject<Int>.create(bufferSize: 1)
// C: let subject = ReplaySubject<Int>.create(bufferSize: 2)
// D: let subject = ReplaySubject<Int>.createUnbounded()
// E: let subject = BehaviorSubject(value: -1)

_ = subject.subscribe { print("1", $0) }

subject.onNext(0)
subject.onNext(1)

_ = subject.subscribe { print("2", $0) }

subject.onNext(2)
```

## Relay

`Relay` には `PublishRelay` と `BehaviorRelay` があります.

`Relay` は Error や Complated が発生しない `Subject` です.

### 課題

`PublishRelay` と `BehaviorRelay` を使ってそれぞれの違いがわかるサンプルコードを書いてみましょう.

## Rx 登場人物

- Publish が付くものは Replay されない
- Behavior が付くものは最新の値だけ Replay される
- Replay が付くものは任意の数 or すべての値が Replay される
- Relay が付くものは失敗や終了がない

| Package | Type            | subscribe できる？ | event を emit できる？ | onNext が発生する？ | onError が発生する？ | onComplate が発生する？    | Replayの挙動   |
|---------|-----------------|----------------|-------------------|---------------|----------------|----------------------|-------------|
| RxSwift | Observable      | ○              | ☓                 | 可能性がある        | 可能性がある         | 可能性がある               | 不明          |
|  | PublishSubject  | ○              | ○                 | ○             | ○              | ○                    | しない         |
|  | BehaviorSubject | ○              | ○                 | ○             | ○              | ○                    | 最新の値のみ      |
|  | ReplaySubject   | ○              | ○                 | ○             | ○              | ○                    | すべて/または任意の数 |
|  | AsyncSubject    | ○              | ○                 | ○             | ○              | ○                    | 最新の値のみ      |
| RxRelay | PublishRelay    | ○              | ○                 | ○             | ☓              | ☓                    | しない         |
|  | BehaviorRelay   | ○              | ○                 | ○             | ☓              | ☓                    | 最新の値のみ      |
|  | Single          | ○              | ☓                 | ○ (onSuccess) | ○              | ☓                    | しない         |
|  | Completable     | ○              | ☓                 | ☓             | ☓              | ○                    | しない         |
|  | Maybe           | ○              | ☓                 | ○             | ○              | ○                    | しない         |
| RxCocoa | Driver          | ○              | ○                 | ○             | ☓              | ○                    | 最新の値のみ      |
|  | Signal          | ○              | ○                 | ○             | ☓              | ○                    | しない         |
|  | ControlProperty | ○              | ○                 | ○             | ☓              | ○ (deallocate されるとき) | 最新の値のみ      |
|  | ControlEvent    | ○              | ○                 | ○             | ☓              | ○ (deallocate されるとき) | しない         |