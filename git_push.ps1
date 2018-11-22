function global:git_push () {
    Param([switch]$all, [switch]$update, [string]$comment, [string]$branch)

    $commit_flag = $false
    $command_history = @()
    $usage_text = @'
git_push [-a, -u] -comment [コミットメッセージ] -branch [ブランチ名]
-all , -update のどちらかと -comment -branch のパラメータは必須です。
'@

    if ($all) {
        [void]$(git add --all)
        $command_history += "git add --all"
    } elseif ($update) {
        [void]$(git add -u)
        $command_history += "git add -u"
    } else {
        throw New-Object System.ArgumentException("git addの引数が正しくありません。`n$usage_text")
    }

    if ($comment) {
        [void]$(git commit -m "$comment")
        $command_history += "git commit -m `"" + "$comment" + "`""
        $commit_flag = $true
    } else {
        throw New-Object System.ArgumentNullException("コミットメッセージがありません。`n$usage_text")
    }

    if ($branch) {
        $branchs = $(git branch -a)
        $branchs = $branchs -split "`n"
        if ($($branchs | foreach { $_ -replace " ", "" }) | Select-String -Pattern "\*$branch" ) {
            foreach ($command in $command_history) {
                echo($command)
            }
            echo("ブランチ:$branch")
            echo("ステータスを表示します。")
            $(git status)

            while ($true) {
                if ($input_line) {
                    echo("無効な文字列が入力されました。")
                }
                Write-Host -NoNewline "pushしますか？[y/n]＞"
                $input_line = $(Read-Host)
                echo($input_line)

                if ("n", "no" -contains $input_line) {
                    echo("中止し、コミットを取り消します。")
                    $(git reset --soft HEAD^)
                    break
                } elseif ("y", "yes" -contains $input_line) {

                    $(git push origin $branch)
                    
                    if ($LASTEXITCODE -ne 0) {
                        throw "pushに失敗しました。"
                    }

                    $commit_flag = $false
                    break
                }
            }
        } else {
            throw New-Object System.ArgumentOutOfRangeException("ブランチの指定が間違っています。")
        }
    } else {
        throw New-Object System.ArgumentException("ブランチ名が指定されていません。`n$usage_text")
    }

    trap {
        if ($commit_flag) {
            echo("pushするまでにエラーが発生したのでコミットを取り消します。")
            $(git reset --soft HEAD^)
        }
        break
    }
}
