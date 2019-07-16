#  Share

はじめに断っておきますが、 `Share` は様々な動きをするので今までより難しいです. しかしコードを動かしながらしっかりと動きを理解することで混乱は避けられます.

突然ですが以下のコードではどのような出力が得られるでしょうか？

```swift
let observable = Observable<Int>.create { observer in
    DispatchQueue.main.async {
        print("created !!")
        observer.onNext(1)
        observer.onCompleted()
    }
    return Disposables.create()
}

_ = observable.subscribe { print($0)}
_ = observable.subscribe { print($0)}
```

<details>
<summary>答え</summary>

```
created !!
next(1)
completed
created !!
next(1)
completed
```

</details>

想像通りでしたか？ `created !!` が2回実行されることを予想できましたでしょうか？ 僕は最初1度だけ実行されると思っていました.

実は `Observable` (厳密には Cold な Observable) は subscribe するたびにそのコピーが作られます.

これは以前説明した `Observable.subscribe` は `Sequence.makeIterator` と等価」 というところからもイメージ可能な動きです. イメージがつかない場合は振り返ってみてくださいね.

さて、この動作は嬉しくない場面もあります. 例えば以下のようなコードの場合です.

```swift
let observable = Observable<Int>.create { observer in
    // とてつもなくリソースを消費する処理
    return Disposables.create()
}

_ = double.subscribe { print($0)}
_ = double.subscribe { print($0)}
```

この場合、 `observable` は `subscribe` されるたびに複製されるのでその数だけリソースを消費してしまいパフォーマンス的にあまり嬉しくありません.

そこで何回 `subscribe` してもただ一つの `Observable` が共有されるようにするために `share` を使う方法を紹介します.

```swift
let observable = Observable<Int>.create { observer in
    DispatchQueue.main.async {
        print("created !!")
        observer.onNext(1)
        observer.onCompleted()
    }
    return Disposables.create()
}.share() // ここが大事

_ = observable.subscribe { print($0)}
_ = observable.subscribe { print($0)}
// created !!
// next(1)
// next(1)
// completed
// completed
```

`share` を使うと `created !!` が一度しか表示されていないことが確認できます.

さてここでもう一つ興味深いことを確認するために先程のコードから `async` の部分を取り除いたらどのような出力が得られると思いますか？

```swift
let observable = Observable<Int>.create { observer in
    print("created !!")
    observer.onNext(1)
    observer.onCompleted()
    return Disposables.create()
}.share()

_ = observable.subscribe { print($0)}
_ = observable.subscribe { print($0)}
```

<details>
<summary>答え</summary>

```
created !!
next(1)
completed
created !!
next(1)
completed
```

</details>

なんとまた `subscribe` するたびに `Observable` が生成されるようになってしまいました... なぜでしょうか？

まず `share()` は `share(replay: 0, scope: .whileConnected)` の省略形です.

`replay` の部分は以前に紹介したとおり新しく `subscribe` してきた subscriber にどのように以前のイベントを伝えるかの指定です.

では `scope` は何でしょうか？ まずは定義のコメントを読んでみましょう.

> https://github.com/ReactiveX/RxSwift/blob/master/RxSwift/Observables/ShareReplayScope.swift

の `SubjectLifetimeScope` にある以下の記述が参考になります.

```md
**Each connection will have it's own subject instance to store replay events.**
**Connections will be isolated from each another.**
```

`whileConnected` な scope の場合は

 - 各接続には replay イベントを格納するためにそれぞれの Subject のインスタンスがあります
    - 補足: replay = 0 の場合はイベントを格納しません
 - 接続は互いに分離されています.

と書かれています. 更に読み進めましょう. `This has the following consequences:` は `これは以下のような影響があります.` という意味なのでいよいよ核心に迫りそうな雰囲気です.

```md
* `retry` or `concat` operators will function as expected because terminating the sequence will clear internal state.
* Each connection to source observable sequence will use it's own subject.
* When the number of subscribers drops from 1 to 0 and connection to source sequence is disposed, subject will be cleared.
```

この3番目の文(When ths number 〜)が原因です. これは接続がなくなったとき(1 -> 0 に変化したとき)には subject は clear されると書いてありますので、これを踏まえて先程の出力を眺めてみましょう.

```
created !! <- このとき接続は1つ
next(1)
completed <- このとき接続は1つだが直後に dispose される. なぜなら onComplated が呼ばれたから.
// <- このとき接続は0. つまり開放される.
created !! <- このとき接続は1つ
next(1)
completed
```

わかりましたでしょうか？ つまり最初の接続(subscribe)が開放されたときに `Observable<Int>.create` から始まる一連の計算結果が開放されたために、再び接続があったときに subject が再度生成されたので `created !!` が2回呼ばれたのです.

ではなぜ前のバージョンでは1回しか呼ばれなかったのでしょうか？ 詳しく説明するためにコードの中にコメントをしながら説明します.

```swift
let observable = Observable<Int>.create { observer in
    DispatchQueue.main.async { // <- この async が重要
        print("created !!")
        observer.onNext(1)
        observer.onCompleted()
    }
    return Disposables.create()
}.share()

// 接続は0
_ = observable.subscribe { print($0) } // このときまだ onNext も onComplate も呼ばれていない
// 接続は1
_ = observable.subscribe { print($0) } // このときまだ onNext も onComplate も呼ばれていない
// 接続は2

// .... この辺りで onNext と onComplated が呼ばれる.

// created !! <- 接続は2つ
// next(1) <- 接続は2つ
// next(1) <- 接続は2つ
// completed <- この直後に接続数が1になる.
// completed <- この直後に接続数が0になる
```

わかりましたでしょうか？ `async` を使ったバージョンのときは接続数が途中で0にならず、かつ `subscribe` 後にイベントが発生しているので `Observable<Int>.create` の一連の計算は一度しか行われません.

※ 「`subscribe` 後にイベントが発生している」という条件がいきなり登場しましたが、この例では `replay = 0` なのでその前提が必要です.

## 課題

### 課題 1

`share` メソッドの `replay` を変えるとどのようになるか説明してみましょう.
またその違いがわかるサンプルコードを書いてみましょう.

###  課題 2

もう一つの scope の`forever` はどのような特徴があるか説明してみましょう.

## 参考文献

以下の RxSwift の公式ドキュメントの `Sharing subscription and share operator` の章に `share` の説明が書かれています.

> https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md


以下のページの `Going deeper` 以降の部分がわかりやすいです.

> https://medium.com/gett-engineering/rxswift-share-ing-is-caring-341557714a2d