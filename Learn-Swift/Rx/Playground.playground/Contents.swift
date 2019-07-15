import UIKit
import RxSwift
import RxRelay
var str = "Hello, playground"

let subject = BehaviorSubject(value: 0)

_ = subject.subscribe {
    print("1", $0)
}

subject.accept(0)
subject.accept(1)


_ = subject.subscribe {
    print("2", $0)
}

subject.accept(2)
