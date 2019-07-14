#  Introduction


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
