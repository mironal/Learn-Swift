# 02 Create and Subscribe

`RxSwift` では様々な方法を使って `Observable` な sequence を作ることができます. また、作った `Observable` は `subscribe` を使って購読できます.

最も簡単な例としては `never` や `empty`, `just` を使ったものがあります.

```swift
_ = Observable<Int>
    .never() // 決してイベントを発生させない
    .subscribe {
        print($0)
    }

_ = Observable<Int>
    .empty() // Complate イベントのみを発生させる
    .subscribe {
        print($0)
    }
    // complated

_ = Observable<Int>
    .just(1) // next を1回と complated を発生させる
    .subscribe {
        print($0)
    }
    // next(1)
    // completed
```

複数回の next イベントを発生させたいときに便利な `of` や `from` もあります.

```swift
_ = Observable<Int>
    .of(1,2,3)
    .subscribe{
        print($0)
    }

_ = Observable<Int>
    .from([1,2,3])
    .subscribe{
        print($0)
    }
```

また完全にオリジナルの `Observable` を `create` を使って作ることができます. 今まで紹介してきたメソッドはすべてこれを元に作られています.

例えば `just` は以下のように実装することができます.

```swift
func just<E>(_ elem: E) -> Observable<E> in
    return Observable.create { observer in
        observer.on(.next(elem))
        observer.on(.complated)
        return Disposables.create()
    }
}
```

## 補足

まだ紹介していませんが、特殊な `Observable` である `Single` や `Maybe` なども以下のように、 `just` や `create` などを使って作ることができます.

```swift
Single.just(0)

Single<Int>.create { single in
    single(.success(1))
}
```

これについては別の機会に詳しく紹介します.

## 課題

### 課題 1

`Observable.create` を使って `empty`, `of`, `from` を作ってみましょう.

### 課題 2

`Observable.create` を使って今回説明しなかった ` Observable<E>.range(start:, count:)` を作ってみましょう.

> http://reactivex.io/documentation/operators/range.html

