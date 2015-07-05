#

all:	jar/spongevanilla.jar

jar/spongevanilla.jar:	tmp/SpongeVanilla.setupDecompWorkspace.tmp
	cd SpongeVanilla && ./gradlew
	mkdir -p jar
	cp SpongeVanilla/build/libs/spongevanilla-*[0-9].jar $@

tmp/SpongeVanilla.setupDecompWorkspace.tmp:	tmp/SpongeVanilla.githook tmp/SpongeCommon.tmp
	cd SpongeVanilla && ./gradlew setupDecompWorkspace --refresh-dependencies
	touch $@

tmp/SpongeVanilla.tmp:
	git submodule update --init
	mkdir -p tmp
	touch $@

tmp/SpongeCommon.tmp:	tmp/SpongeVanilla.tmp
	cd SpongeVanilla && git submodule update --init --recursive
	touch $@

tmp/SpongeVanilla.githook:	tmp/SpongeVanilla.tmp SpongeVanilla/scripts/pre-commit
	cd SpongeVanilla && cp scripts/pre-commit "`git rev-parse --git-dir`/hooks/"
	touch $@

clean:
	rm -rf jar tmp

