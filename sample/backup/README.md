# IIJ GIO ストレージ&アナリシスサービス バックアップスクリプトサンプル
本リポジトリには、IIJ GIO ストレージ&アナリシスサービス バックアップスクリプトサンプルが格納されています。
[dagtools](https://docs.dag.iijgio.com/storage/dagtools.html) とシェルスクリプトを組み合わせ、バックアップ処理を実現するサンプルです。

# 注意事項&免責事項
十分な試験を実施しておりますが本スクリプトはサンプルです。

- 本スクリプトはサンプルであり、動作を保証するものではありません。
- 本スクリプトの実行に伴う損害に対し、株式会社インターネットイニシアティブは責を負いません。

# 動作環境
動作確認はCentOS 7.2で実施しました。
dagtoolsは事前にセットアップされている必要があります。dagtoolsのセットアップは[こちら](https://docs.dag.iijgio.com/storage/dagtools.html)をご覧ください。
実行にはインターネット接続が必須です。

# サンプルスクリプトの説明
本スクリプトでは、(1)バックアップの実施、(2)一定数をこえたローカルディレクトリの削除 の2つを実施します。

サンプルの想定するディレクトリ構成を以下に示します。
```
./backup-test
           +- /20180101
           +- /20180102
           +- /20180103 
           +- /sample-config.txt
           +- .....
```

./backup-testというディレクトリの直下にあるファイルがアップロードされます。
さらに、サブディレクトリとそのディレクトリの中にあるファイルもストレージ&アナリシスサービスにアップロードされます。

本サンプルでは、ローカルディレクトリの世代管理を実装しています。
デフォルト設定では、数字8桁のディレクトリは世代管理の対象です。
デフォルトではディレクトリの保持数、つまりローカルに残すディレクトリ数は10個です。
11個目のディレクトリが作成された状態で本スクリプトが実行されると、その時点でlsの結果が最も上位にくるディレクトリが削除されます。

ただし本サンプルではデータの消失を防ぐため頭にdel_の接頭辞を付け、ディレクトリをリネームします。

**ファイルはこの処理の対象になりません。**

## サンプルスクリプトの設定値
[sample/backup/sample-backup.conf](sample-backup.conf)を変更することでスクリプトの動作を変更することが出来ます。

| 変数名 | 意味 | デフォルト値 | 備考 |
|:-----------|:------------|:------------|:------------|
| backup_root_dir | バックアップ対象のファイル、ディレクトリが格納される位置 | ./backup-test | |
| local_generation | ローカルディレクトリの保持数 | 10 | |
| gen_manager_target_dir_pattern | 世代管理の対象とするディレクトリのパターンを正規表現で記載する | "^[0-9]{8}" | |
| dagtools_command | dagtoolsのコマンド| dagtools | デフォルト設定値はdagtoolsにパスが通っている場合の設定値です。パスが通っていない場合は本設定値にフルパスを書くことでスクリプトを実行できます。 |
| bucket_name | データバックアップ先のバケット名 | "!test" | バケットはお客様にて作成ください。 dagtools putコマンドや、管理コンソールから作成することができます。 |

# サンプル実行手順
1. dagtoolsをダウンロード&インストールする
1. データを保存するバケットを作成する

    ```
    $ dagtools put <バケット名>
    ```

1. バックアップデータを保存するためのローカルディレクトリをmkdirコマンドで作成する

    以下の例では/var/tmp/backupをバックアップターゲットにしています。以後、この手順の中ではこのディレクトリを利用して説明しますが、任意のディレクトリ変更して頂いてもかまいません。その場合は適宜読みかえをお願いします。

        ```
        $ mkdir /var/tmp/backup-test
        ```

1. バックアップ用のサンプルスクリプトをダウンロードする

    リポジトリの[トップページ](※あとから直す※)の右上の「Clone or Download」ボダンをクリックします。
    
    zipをダウンロードする場合、さらに「Download ZIP」をクリックして任意のディレクトリにダウンロードし展開してください。
    
    gitコマンドを使う場合は任意のディレクトリにgit cloneしてください。
    
1. 設定の変更

    1. スクリプトをダウンロードしたディレクトリの直下（/tmpにダウンロードした場合であれば/tmp/dagtools-sample）に移動(cd)する
    
    2. エディタで[sample/backup/sample-backup.conf](sample-backup.conf)を開いて、設定を編集する
        
        本手順ではバックアップ対象ディレクトリ(backup_root_dir)とバケット名（bucket_name）を編集します。編集例を以下に示します。

        ````
        local_generation=10
        
        gen_manager_target_dir_pattern="^[0-9]{8}"
        
        backup_root_dir=/var/tmp/backup-test
        
        dagtools_command="dagtools"
        
        bucket_name="<2.で作ったバケット>"
        ````
    
1. データをディレクトリ(ローカル)に置く

    バックアップ対象のファイル、ディレクトリを/var/tmp/backup-testへコピーしてください。

    簡単に試す場合であればcreate-data.shを以下のように実行することで、日付ディレクトリと試験データを配置することが出来ます。
    
    1. スクリプトをダウンロードしたディレクトリの直下（/tmpにダウンロードした場合であれば/tmp/dagtools-sample）に移動(cd)します。

    1. テストデータを作成するスクリプトcreate-data.shを実行します。 

        ```
        $ sample/backup/create-data.sh /var/tmp/backup-test
        ```

1. バックアップスクリプトを実行する
    
    スクリプトをダウンロードしたディレクトリの直下（/tmpにダウンロードした場合であれば/tmp/dagtools-sample）に移動(cd)します。
    
    そのうえで以下のコマンドを実行してください。

    ```
    $ sample/backup/sample-backup.sh
    ```

    　　実行結果イメージ
    
    ```
    $ sample/backup/sample-backup.sh
    start sync ...
    put: /var/tmp/backup/20180520/testfile.dat -> iij-test-bucket:20180520/testfile.dat
    put: /var/tmp/backup/20180521/testfile.dat -> iij-test-bucket:20180521/testfile.dat
    put: /var/tmp/backup/20180522/testfile.dat -> iij-test-bucket:20180522/testfile.dat
    put: /var/tmp/backup/20180523/testfile.dat -> iij-test-bucket:20180523/testfile.dat
    put: /var/tmp/backup/20180524/testfile.dat -> iij-test-bucket:20180524/testfile.dat
    put: /var/tmp/backup/20180525/testfile.dat -> iij-test-bucket:20180525/testfile.dat
    put: /var/tmp/backup/20180526/testfile.dat -> iij-test-bucket:20180526/testfile.dat
    put: /var/tmp/backup/20180527/testfile.dat -> iij-test-bucket:20180527/testfile.dat
    put: /var/tmp/backup/20180528/testfile.dat -> iij-test-bucket:20180528/testfile.dat
    put: /var/tmp/backup/20180529/testfile.dat -> iij-test-bucket:20180529/testfile.dat
    put: /var/tmp/backup/20180530/testfile.dat -> iij-test-bucket:20180530/testfile.dat
    put: /var/tmp/backup/20180531/testfile.dat -> iij-test-bucket:20180531/testfile.dat
    put: /var/tmp/backup/20180601/testfile.dat -> iij-test-bucket:20180601/testfile.dat
    put: /var/tmp/backup/20180602/testfile.dat -> iij-test-bucket:20180602/testfile.dat
    put: /var/tmp/backup/20180603/testfile.dat -> iij-test-bucket:20180603/testfile.dat
    put: /var/tmp/backup/20180604/testfile.dat -> iij-test-bucket:20180604/testfile.dat
    put: /var/tmp/backup/20180605/testfile.dat -> iij-test-bucket:20180605/testfile.dat
    put: /var/tmp/backup/20180606/testfile.dat -> iij-test-bucket:20180606/testfile.dat
    put: /var/tmp/backup/20180607/testfile.dat -> iij-test-bucket:20180607/testfile.dat
    put: /var/tmp/backup/20180608/testfile.dat -> iij-test-bucket:20180608/testfile.dat
    put: /var/tmp/backup/20180609/testfile.dat -> iij-test-bucket:20180609/testfile.dat
    done.
    total direcries in backup dir: 21
    deleting old backup data on local directories....
    Delete /var/tmp/backup/20180520 ### This script is sample. This script execute mv(rename) command instead of rm(delete).
    Delete /var/tmp/backup/20180521 ### This script is sample. This script execute mv(rename) command instead of rm(delete).
    Delete /var/tmp/backup/20180522 ### This script is sample. This script execute mv(rename) command instead of rm(delete).
    Delete /var/tmp/backup/20180523 ### This script is sample. This script execute mv(rename) command instead of rm(delete).
    Delete /var/tmp/backup/20180524 ### This script is sample. This script execute mv(rename) command instead of rm(delete).
    Delete /var/tmp/backup/20180525 ### This script is sample. This script execute mv(rename) command instead of rm(delete).
    Delete /var/tmp/backup/20180526 ### This script is sample. This script execute mv(rename) command instead of rm(delete).
    Delete /var/tmp/backup/20180527 ### This script is sample. This script execute mv(rename) command instead of rm(delete).
    Delete /var/tmp/backup/20180528 ### This script is sample. This script execute mv(rename) command instead of rm(delete).
    Delete /var/tmp/backup/20180529 ### This script is sample. This script execute mv(rename) command instead of rm(delete).
    Delete /var/tmp/backup/20180530 ### This script is sample. This script execute mv(rename) command instead of rm(delete).
    done!
    ```

1. ストレージ&アナリシスサービスを確認し、バックアップされていることを確認する

    dagtools lsを使って、バックアップが実施されたことを確認します。

    ```
    $ dagtools ls -r <2.で作ったバケット>
    ```

    実行イメージ

    ```
    $ dagtools ls -r iij-test-bucket
    [iij-test-bucket:]
                owner              size         last-modified   name
                    -                 -                     -   20180520/
                    -                 -                     -   20180521/
                    -                 -                     -   20180522/
                    -                 -                     -   20180523/
                    -                 -                     -   20180524/
                    -                 -                     -   20180525/
                    -                 -                     -   20180526/
                    -                 -                     -   20180527/
                    -                 -                     -   20180528/
                    -                 -                     -   20180529/
                    -                 -                     -   20180530/
                    -                 -                     -   20180531/
                    -                 -                     -   20180601/
                    -                 -                     -   20180602/
                    -                 -                     -   20180603/
                    -                 -                     -   20180604/
                    -                 -                     -   20180605/
                    -                 -                     -   20180606/
                    -                 -                     -   20180607/
                    -                 -                     -   20180608/
                    -                 -                     -   20180609/
    [iij-test-bucket:20180520/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:52   testfile.dat
    [iij-test-bucket:20180521/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:52   testfile.dat
    [iij-test-bucket:20180522/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:53   testfile.dat
    [iij-test-bucket:20180523/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:53   testfile.dat
    [iij-test-bucket:20180524/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:54   testfile.dat
    [iij-test-bucket:20180525/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:54   testfile.dat
    [iij-test-bucket:20180526/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:55   testfile.dat
    [iij-test-bucket:20180527/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:55   testfile.dat
    [iij-test-bucket:20180528/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:55   testfile.dat
    [iij-test-bucket:20180529/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:56   testfile.dat
    [iij-test-bucket:20180530/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:56   testfile.dat
    [iij-test-bucket:20180531/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:57   testfile.dat
    [iij-test-bucket:20180601/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:57   testfile.dat
    [iij-test-bucket:20180602/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:58   testfile.dat
    [iij-test-bucket:20180603/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:58   testfile.dat
    [iij-test-bucket:20180604/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:58   testfile.dat
    [iij-test-bucket:20180605/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:59   testfile.dat
    [iij-test-bucket:20180606/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:17:59   testfile.dat
    [iij-test-bucket:20180607/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:18:00   testfile.dat
    [iij-test-bucket:20180608/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:18:00   testfile.dat
    [iij-test-bucket:20180609/]
                owner              size         last-modified   name
    dag-support@iij.ad.j              1024   2018-06-26 15:18:00   testfile.dat

    ```

# バックアップデータのレストアについて

データのレストア(ダウンロード)はdagtoolsコマンドで実行します。

例としてiij-test-bucketのデータのうち、/20180520/～のパスのデータをレストアします。

1. レストア先のディレクトリを作る

    ```
    mkdir /tmp/test/20180520 
   ```
1. syncでレストアする

   ```
   $dagtools sync iij-test-bucket:20180520/ /var/tmp/backup-test/ 
   get:iij-test-bucket:20180520/testfile.dat -> /var/tmp/backup-test/20180520/testfile.dat
   ```


