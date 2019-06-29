#!/bin/bash

set -Ceu
# -C リダイレクトでファイルを上書きしない
# -e コマンドの終了コードが1つでも0以外になったら直ちに終了する
# -u 設定されていない変数が参照されたらエラー

: "${MULANG_SOURCE_PARENT_DIR_NAME:=.xsvutils/mulang}"

: "$MULANG_SOURCE_DIR"
# MULANG_SOURCE_DIR はmulangでビルド時に定義される。
# 未定義の場合にエラーとする。

mkdir -p var/target

target_sources1=$(cd src; ls)
target_sources2=$(echo $(cd src; ls | sed "s#^#var/target/#g"))

(

cat <<EOF
var/out.sh: var/TARGET_VERSION_HASH
	cat $MULANG_SOURCE_DIR/boot.sh | sed "s/XXXX_VERSION_HASH_XXXX/\$\$(cat var/TARGET_VERSION_HASH)/g" | sed "s#XXXX_MULANG_SOURCE_DIR_XXXX#$MULANG_SOURCE_PARENT_DIR_NAME#g" > var/out.sh.tmp
	(cd var/target; perl $MULANG_SOURCE_DIR/pack-dir.pl) > var/image.sh
	(cd var/target; perl $MULANG_SOURCE_DIR/pack-dir.pl) | gzip -n -c >> var/out.sh.tmp
	chmod 755 var/out.sh.tmp
	mv var/out.sh.tmp var/out.sh

EOF

for f in $target_sources1; do
    cat <<EOF
var/target/$f: src/$f var/target/.dir
	cp src/$f var/target/$f

EOF
done

cat <<EOF
var/target/.anylang: var/target/.dir
	curl -fsS https://raw.githubusercontent.com/xsvutils/xsv-anylang/master/anylang.sh > var/target/.anylang.tmp
	chmod +x var/target/.anylang.tmp
	mv var/target/.anylang.tmp var/target/.anylang

var/target/.dir:
	mkdir -p var/target
	touch var/target/.dir

var/TARGET_VERSION_HASH: $target_sources2 var/target/.anylang
	cat $target_sources2 var/target/.anylang | shasum | cut -b1-40 > var/TARGET_VERSION_HASH.tmp
	mv var/TARGET_VERSION_HASH.tmp var/TARGET_VERSION_HASH

EOF

) >| var/makefile.tmp
mv var/makefile.tmp var/makefile

make -f var/makefile "$@"

exit $?

