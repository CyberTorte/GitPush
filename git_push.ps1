function global:git_push () {
    Param([switch]$all, [switch]$update, [switch]$current, [array]$files, [string]$message, [string]$branch)

    $commit_flag = $false
    $command_history = @()
    $usage_text = @"
git_push [-a, -u] -comment [コミットメッセージ] -branch [ブランチ名]
-all , -update のどちらかと -comment -branch のパラメータは必須です。
-a, --all`t: git add --all を実行します。
-u, -update`t: git add --update を実行します。
-c, -current`t: git add . を実行します。
-f, -files`t: git add [ファイル名] を実行します。
-m, -message`t: git commit -m [コミットメッセージ] を実行します。
-b, -branch`t: git push origin [ブランチ名] を実行します。
"@

    if ($all) {
        [void]$(git add --all)
        $command_history += "git add --all"
    } elseif ($update) {
        [void]$(git add -u)
        $command_history += "git add -u"

    #     if ($files) {
    #         $add_files = @()
    #         foreach ($file in $files) {
    #             if ($(Test-Path $file)) {
    #                 [void]$(git add $file)
    #                 $add_files += $file
    #             } else {
    #                 echo("ファイルパスが間違っています。")
    #             }
    #         }
    #         echo("addしたファイルを表示します。")
    #         foreach ($file in $add_files) {
    #             echo($file)
    #         }
    #     }
    # } elseif ($file) {
    #     $add_files = @()
    #     foreach ($file in $files) {
    #         if ($(Test-Path $file)) {
    #             [void]$(git add $file)
    #             $add_files += $file
    #         } else {
    #             echo("ファイルパスが間違っています。")
    #         }
    #     }
    #     echo("addしたファイルを表示します。")
    #     foreach ($file in $add_files) {
    #         echo($file)
    #     }
    } elseif ($current) {
        [void]$(git add .)
        $command_history += "git add ."
    } else {
        throw New-Object System.ArgumentException("git addの引数が正しくありません。`n$usage_text")
    }

    if ($message) {
        [void]$(git commit -m "$message")
        $command_history += "git commit -m `"" + "$message" + "`""
        $commit_flag = $true
    } else {
        throw New-Object System.ArgumentNullException("コミットメッセージがありません。`n$usage_text")
    }

    if ($branch) {
        $branches = $(git branch -a)
        $branches = $branches -split "`n"
        if ($($branches | foreach { $_ -replace " ", "" }) | Select-String -Pattern "\*$branch" ) {
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
                echo("")

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
