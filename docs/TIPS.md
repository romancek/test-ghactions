# 概要

* GitHub Actionsで便利な設定や注意すべきことを残す

# リリースノートの自動生成

* `softprops/action-gh-release`を使う
  * `actions/create-release`や`actions/upload-release-asset`は古い
  * `generate_release_notes: true`でタグ間のGitログのリンクを自動生成してくれる

# セキュリティ

## サードパーティアクションの利用

* `actions/xxx`以外のやつ
* @v4などのタグではなくコミットハッシュHで@Hなどを指定したほうがより安全
  * ハッシュじゃわかりづらいので、コメントにバージョン情報を残しておく
  * `- uses: hoge/action@sha-1_hash # v4.x.y`

# デバッグ

* お手軽な方法
  * 次の変数をSecretsに登録すれば一括でデバッグ情報を残せる
    * `ACTIONS_STEP_DEBUG = true`
    * `ACTIONS_RUNNER_DEBUG = true`

* Bash
  * runでスクリプト実行する際にパイプエラーを拾えるようにする([参考](https://docs.github.com/ja/actions/writing-workflows/workflow-syntax-for-github-actions#defaultsrunshell))

```yaml
defaults:
  run:
    shell: bash --noprofile --norc -eo pipefail {0}
steps:
  - name: hoge
    run: true && false
```

# リソース

* 実行時間を減らす方法

* タイムアウト設定
  * デフォルトは6時間なので失敗しないで停止するバグが起きると6時間も消費されちゃう
  * ワークフローの想定するタイムアウト時間を設定したほうがいい
* ステップごとか、ジョブ全体のタイムアウト時間を設定できる

```yaml
jobs:
  hoge:
    timeout-minutes: 5
```

## キャッシュ

# 共通フロー

* reusable workflow

---
