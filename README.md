## 概要

このドキュメントは以下のことを目的としています.

1. Swift の基本的な考え方について学ぶ
2. Apple のドキュメントを読めるようになる
3. メソッドの定義を読めるようになる
    - 例えば `func flatMap<SegmentOfResult>(_ transform: (Self.Element) throws -> SegmentOfResult) rethrows -> [SegmentOfResult.Element] where SegmentOfResult : Sequence` のようなもの

本文中には Apple のドキュメントや関数の定義が読めるようになるために Apple のドキュメントのページを度々参照して説明する形式にしています.

Apple のドキュメントなどを読むためにはある程度の英語/数学の知識が必要ですので適宜必要な情報については解説を入れていきます.

いくつか課題が用意してあるので、このリポジトリを fork して `Homework.playground` に書いて PR を出してみましょう.