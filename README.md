# GitPushについて

この.ps1ファイルはgit addからgit pushまでを1回の関数で済ませるものです。

さっさと使用方法に飛びたい方は[こちら](#使用方法について)へ

# 前提条件

## 目次

1. [.ps1ファイルが実行できる](#.ps1ファイルが実行できる)
2. [自動的に読み込む](#自動的に読み込む)
3. [.ps1ファイルの文字コードについて](#.ps1ファイルの文字コードについて)

## .ps1ファイルが実行できる

.ps1ファイルの実行が許可されている必要があります。

PowerShellのコンソールにて

```PowerShell:コンソール
Get-ExecutionPolicy
```

と実行して

`RemoteSigned`,`Unrestricted`,`Bypass`のいずれかであれば実行可能です。

ただ、前者以外はセキュリティ的に好ましくありませんが...

もしこの3つでない場合

```PowerShell:管理者で実行したコンソール
Set-ExecutionPolicy RemoteSigned
```

を管理者で実行したPowerShellにて実行してください。

警告が出ますので許可した上で

`実行ポリシーを変更しますか？`と表示されたら`y`と入力してください。

## 自動的に読み込む

これをcloneしただけでは使えないので

使用前に読み込む必要があります。

毎回毎回読み込む方はこの.ps1ファイルのフルパス(相対パスでも可)入れて

実行してみてください。

ここでは自動で読み込ませる方法を記しておきます。

`C:\Users\[ユーザ名]\Documents\GitPush\`の場所にあるものとします。

ファイルの場所等は[PowerShellでのプロファイル](https://qiita.com/bitnz/items/400bb6a0b124b8b3d398)をご覧ください。

※準備の部分は[前項](#.ps1ファイルが実行できる)で終わってます。

```PowerShell:Microsoft.PowerShell_profile.ps1
C:\Users\[ユーザ名]\Documents\GitPush\git_push.ps1
```

これをプロファイルに追記してください。

私は`git_push`と打つのが~~ダルいので~~大変なので

```PowerShell:Microsoft.PowerShell_profile.ps1
Set-Alias gitPush git_push
```

と追記してます。

## .ps1ファイルの文字コードについて

PowerShellでUTF-8を扱うと

なぜかしら文字化け~~起こしやがる~~してしまうので

PowerShellでもさばけるようにUTF-8 with BOMで書いています。

保存形式はお間違えなく。

# 使用方法について

```PowerShell:コンソール
git_push [-a, -uのどちらか] -c [コミットメッセージ] -b [ブランチ名]
```

まず、必須引数ですが

`-a`, `-all`もしくは`-u`, `-update`が必要です。

次に`-c`, `-comment`が必要です。

指定した後にコミットメッセージを入力します。

もし、スペースを含む場合は`"`でくくってください。

最後に`-b`, `-branch`を指定します。

指定した後にブランチ名を指定します。

# ライセンス

今のところ未設定です。
