import UIKit
import RxSwift
import RxRelay

_ = Observable<Int>.just(1).flatMap { v -> Observable<Int> in
    return .just(v * 2)
}
