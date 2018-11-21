function global:git_push () {
    Param([switch]$all, [switch]$update, [string]$comment, [string]$branch)

    $commit_flag = $false
    $command_history = @()

    if ($all) {
        [void]$(git add --all)
        $command_history += "git add --all"
    } elseif ($update) {
        [void]$(git add -u)
        $command_history += "git add -u"
    } else {
        throw New-Object System.ArgumentException("git addの引数が正しくありません。")
    }

    if ($comment) {
        [void]$(git commit -m "$comment")
        $command_history += "git commit -m `"" + "$comment" + "`""
        $commit_flag = $true
    } else {
        throw New-Object System.ArgumentNullException("コミットメッセージがありません。")
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
                Write-Host -NoNewline "pushしますか？[y/n]"
                $input_line = $(Read-Host)
                echo($input_line)

                if ("n", "no" -contains $input_line) {
                    echo("中止し、コミットを取り消します。")
                    $(git reset --soft HEAD^)
                    break
                } elseif ("y", "yes" -contains $input_line) {
                    $return_string = $(git push origin $branch)
                    $return_string = $return_string -split "`n"
                    if ( $($return_string | foreach { $_ -replace " ", "" }) | Select-Object -Pattern "Connectiontimedout" ) {
                        echo("タイムアウトしました。")
                        continue
                    } elseif ( $($return_string | foreach { $_ -replace " ", "" }) | Select-Object -Pattern "fatal" ) {
                        echo("pushに失敗しました。")
                        echo($return_string)
                        break
                    }
                    echo($return_string)
                    $commit_flag = $false
                    break
                }
            }
        } else {
            throw New-Object System.ArgumentOutOfRangeException("ブランチの指定が間違っています。")
        }
    } else {
        throw New-Object System.ArgumentException("ブランチ名が指定されていません。")
    }

    trap {
        if ($commit_flag) {
            echo("pushするまでにエラーが発生したのでコミットを取り消します。")
            $(git reset --soft HEAD^)
        }
        break
    }
}
