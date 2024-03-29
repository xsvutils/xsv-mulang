
build: mulang

test: test1

test1: FORCE mulang
	cd test/1; rm -rf var/build-* var/target* var/out.sh
	cd test/1; ../../mulang
	./test/1/var/out.sh > test/1/var/result.txt
	diff -u test/1/etc/expected.txt test/1/var/result.txt
	echo OK

test4: FORCE var/out-devel.3.sh
	cd test/1; rm -rf var/build-* var/target* var/out-devel.sh
	cd test/1; ../../var/out-devel.3.sh --devel
	./test/1/var/out-devel.sh > test/1/var/result.txt
	diff -u test/1/etc/expected.txt test/1/var/result.txt
	echo OK

mulang: var/out.3.sh
	cp var/out.3.sh mulang

var/out.0.sh: ./etc/mulang-last
	mkdir -p var
	cp ./etc/mulang-last var/out.0.sh

var/out.1.sh: FORCE var/out.0.sh
	./var/out.0.sh
	if [ ! -e $@ ] || ! cmp -s var/out.sh $@; then mv var/out.sh $@; else rm var/out.sh; fi

var/out.2.sh: var/out.1.sh
	./var/out.1.sh
	if [ ! -e $@ ] || ! cmp -s var/out.sh $@; then mv var/out.sh $@; else rm var/out.sh; fi

var/out.3.sh: var/out.2.sh
	./var/out.2.sh
	cmp -s var/out.sh var/out.2.sh
	if [ ! -e $@ ] || ! cmp -s var/out.sh $@; then mv var/out.sh $@; else rm var/out.sh; fi

var/out-devel.3.sh: var/out.3.sh
	./var/out.3.sh --devel
	if [ ! -e $@ ] || ! cmp -s var/out-devel.sh $@; then mv var/out-devel.sh $@; else rm var/out-devel.sh; fi

FORCE:

