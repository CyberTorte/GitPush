#!/bin/bash

function gitpush () {
  declare -i argc=0
  declare -a argv=()

  while (( $# > 0 ))
  do
    case "$1" in
      -*)
        if [[ "$1" =~ 'a' ]]; then
          aflag='-a'
        fi
        if [[ "$1" =~ 'u' ]]; then
          uflag='-u'
        fi
        if [[ "$1" =~ 'c' ]]; then
          cflag='-c'
        fi
        shift
        ;;
      *)
        ((++argc))
        argv=("${argv[@]}" "$1")
        shift
        ;;
    esac
  done

# add系のパラメータの指定があるかチェック
  if test -n "${aflag+set}" || test -n "${uflag+set}" || test -n "${cflag+set}"; then
    # commitメッセージ、ブランチ名があるか確認
    if test -n ${argv[0]} && test -n ${argv[1]}; then
      if test -n "${uflag+set}"; then
        echo "git add --update"
      elif test -n "${cflag+set}"; then
        echo "git add ."
      else
        echo "git add --all"
      fi
      
      echo "git commit -m ${argv[0]}"
      echo "git push origin ${argv[1]}"
      echo "現在のステータス"
      echo $(git fetch -p;git status)

      echo "この内容で実行しますか？ [Y/n]"
      read ANSWER

      ANSWER=$(echo $ANSWER | tr y Y)
      case $ANSER in
        ""|Y* )
          if test -n "${uflag+set}"; then
            echo $(git add --update)
          elif test -n "${cflag+set}"; then
            echo $(git add .)
          else
            echo $(git add --all)
          fi
          echo $(git commit -m "${argv[0]}")
          echo $(git push origin ${argv[1]})
          ;;
        * )
          echo "処理を中断し、終了します。"
          ;;
      esac
    else
      echo "コミットメッセージとブランチ名を入力してください。"
    fi
  else
    echo "-a, -c, -uのどれかを指定してください。"
  fi
}