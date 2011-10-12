################################################################################
# Copyright 2011 by the Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in README.h
# Chip Overclock <coverclock@diag.com>
# http://www.diag.com/navigation/downloads/Biscuit
################################################################################

PROJECT=biscuit
MAJOR=0
MINOR=0
FIX=0

SVN_URL=svn://graphite/biscuit/trunk/Biscuit
HTTP_URL=http://www.diag.com/navigation/downloads/Biscuit.html

################################################################################
# PREREQUISITES
################################################################################

BUILD_TOOLCHAIN_DIR=/usr/bin
HOST_TOOLCHAIN_DIR=/opt/arm-2011.03#https://sourcery.mentor.com/sgpp/lite/arm/portal/package8739/public/arm-none-linux-gnueabi/arm-2011.03-41-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
SOURCE_DIR=$(HOME)/src/gnupg-1.4.11#ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-1.4.11.tar.bz2

################################################################################
# PARAMETERS
################################################################################

# We adopt the GNU nomenclature here: BUILD is the server side on which the
# software is all built and biscuit binary packages are encrypted. HOST is the
# target side on which the biscuit binary packages are decrypted and executed.
# The values below are for building and encrypting on a i686 Linux/GNU server,
# and decrypting on an ARM Linux/GNU embedded target.

BUILD=i686-pc-linux-gnu
HOST=arm-linux-gnu

# The values of these will depend on your toolchain. In particular, the
# HOST_CROSS_COMPILE value will be the GCC prefix for your cross compiler.
# The HOST_CROSS_COMPILE value below works for the CodeSourcery ARM GCC
# toolchain.

BUILD_CROSS_COMPILE=
HOST_CROSS_COMPILE=arm-none-linux-gnueabi-

# This identifies the product line for which the HOST keys is being built.
# All devices in this product line will be able to decrypt and execute the
# same biscuits, although the biscuits themselves may be able to make a finer
# distinction of product type and adjust their actions accordingly.

PRODUCT=example

# You can (and should) use your own name, recipient, comment, and passphrase
# files, and use different ones for different products or versions of the same
# product. That prevents a biscuit for product A or version N from being used
# on product B or version M. These are kept in files instead of passed as
# parameter values to accomodate keeping them in different places than the
# biscuit Makefile, and to prevent the passphrases from showing up in commands
# like ps.

HOST_NAME_FILE=host_name.txt
HOST_EMAIL_FILE=host_email.txt
HOST_COMMENT_FILE=host_comment.txt
HOST_PASSPHRASE_FILE=host_passphrase.txt

BUILD_NAME_FILE=build_name.txt
BUILD_EMAIL_FILE=build_email.txt
BUILD_COMMENT_FILE=build_comment.txt
BUILD_PASSPHRASE_FILE=build_passphrase.txt

# Set these for using the various utility make targets like encrypt, decrypt,
# package, and manifest.

INPUTFILE=/dev/null
OUTPUTFILE=/dev/null
INPUTDIRECTORY=/dev/null

################################################################################
# ALGORITHMS
################################################################################

# The intent here is to choose EIGamal asymetric key encryption (which is not
# patent encumbered) of 1024 bits in length (to accomodate slower embedded
# systems) with no expiration date. But creating an expiration date for the
# HOST side would be a possible strategy too, resulting in an embedded system
# that could not run biscuits after a certain date. Note that we build keys
# for both the HOST and BUILD sides, even though biscuit never uses the BUILD
# side key. So the HOST and BUILD sides probably don't actually need to use the
# same algorithms for generating their keys (although I haven't tested this).

HOST_KEY_TYPE=DSA
HOST_KEY_LENGTH=1024
HOST_SUBKEY_TYPE=ELG-E
HOST_SUBKEY_LENGTH=1024
HOST_EXPIRATION_DATE=0

BUILD_KEY_TYPE=DSA
BUILD_KEY_LENGTH=1024
BUILD_SUBKEY_TYPE=ELG-E
BUILD_SUBKEY_LENGTH=1024
BUILD_EXPIRATION_DATE=0

################################################################################
# PROJECT
################################################################################

CWD:=$(shell pwd)
PROJECT_DIR=$(CWD)/artifacts

# The BUILD_DIR and HOST_DIR in which the GNUPG software is configured and
# build may be the same directory iff the HOST and BUILD are the same GNU
# architecture. If that's the case, then we only build one set of binary
# executables and use them on both the HOST and the BUILD machines.

BUILD_DIR=$(PROJECT_DIR)/arch/$(BUILD)
HOST_DIR=$(PROJECT_DIR)/arch/$(HOST)

# The only binary executable we really need is gpg, although other GNUPG
# software is built and installed in the bin directory. More to the point,
# it is only the gpg executable that needs to be installed on the embedded
# HOST (providing the requisite shared libraries are also on the HOST).
# The various biscuit scripts assume /usr/local/bin on the HOST but can be
# overridden using the environmental variable BISCUITBIN.

BUILD_BIN_DIR=$(BUILD_DIR)/bin
HOST_BIN_DIR=$(HOST_DIR)/bin

# Although different product lines that have the same architecture may use the
# same GNUPG executable binaries, they will probably have different keys. So
# we separate the product lines into different directories. The BUILD
# side can import and contain the HOST public keys for all product lines.
# The various biscuit scripts assume /usr/local/etc/gnupg on the HOST. but can
# be overridden by the environmental variable BISCUITETC.

BUILD_ETC_DIR=$(PROJECT_DIR)/build/$(BUILD)/etc
HOST_ETC_DIR=$(PROJECT_DIR)/host/$(PRODUCT)/$(HOST)/etc

################################################################################
# LISTS
################################################################################

PHONY=

TARGETS=

ARTIFACTS=

HOST_BIN=

HOST_ETC=

BUILD_BIN=

BUILD_ETC=

################################################################################
# DEFAULT
################################################################################

PHONY+=default

default:	all

################################################################################
# HOST/bin
################################################################################

PHONY+=host

host:	$(HOST_DIR) $(HOST_BIN_DIR)/gpg

TARGETS+=$(HOST_DIR)

$(HOST_DIR):
	mkdir -p $(HOST_DIR)

TARGETS+=$(HOST_BIN_DIR)/gpg

$(HOST_BIN_DIR)/gpg:	$(HOST_DIR)/config.h
	( \
		export PATH=$(HOST_TOOLCHAIN_DIR)/bin:$$PATH; \
		cd $(HOST_DIR); \
		make install-strip; \
	)

$(HOST_DIR)/config.h:	$(SOURCE_DIR)/configure
	( \
		export PATH=$(HOST_TOOLCHAIN_DIR)/bin:$$PATH; \
		cd $(HOST_DIR); \
		$(SOURCE_DIR)/configure \
			CC=$(HOST_CROSS_COMPILE)gcc \
			AR=$(HOST_CROSS_COMPILE)ar \
			RANLIB=$(HOST_CROSS_COMPILE)ranlib \
			STRIP=$(HOST_CROSS_COMPILE)strip \
			ac_cv_sys_symbol_underscore=no \
			ac_cv_type_mode_t=yes \
			--host=$(HOST) \
			--build=$(BUILD) \
			--prefix=$(HOST_DIR) \
			--exec-prefix=$(HOST_DIR) \
			--enable-minimal \
			--enable-aes \
			--enable-blowfish \
			--enable-idea \
			--enable-rsa \
			--enable-sha256 \
			--enable-sha512 \
			--enable-twofish \
		; \
	)

################################################################################
# BUILD/bin
################################################################################

PHONY+=build

build:	$(BUILD_DIR) $(BUILD_BIN_DIR)/gpg

TARGETS+=$(BUILD_DIR)/

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

TARGETS+=$(BUILD_BIN_DIR)/gpg

$(BUILD_BIN_DIR)/gpg:	$(BUILD_DIR)/config.h
	( \
		export PATH=$(BUILD_TOOLCHAIN_DIR)/bin:$$PATH; \
		cd $(BUILD_DIR); \
		make install-strip; \
	)

$(BUILD_DIR)/config.h:	$(SOURCE_DIR)/configure
	( \
		export PATH=$(BUILD_TOOLCHAIN_DIR)/bin:$$PATH; \
		cd $(BUILD_DIR); \
		$(SOURCE_DIR)/configure \
			CC=$(BUILD_CROSS_COMPILE)gcc \
			AR=$(BUILD_CROSS_COMPILE)ar \
			RANLIB=$(BUILD_CROSS_COMPILE)ranlib \
			STRIP=$(BUILD_CROSS_COMPILE)strip \
			ac_cv_sys_symbol_underscore=no \
			ac_cv_type_mode_t=yes \
			--host=$(BUILD) \
			--build=$(BUILD) \
			--prefix=$(BUILD_DIR) \
			--exec-prefix=$(BUILD_DIR) \
			--enable-minimal \
			--enable-aes \
			--enable-blowfish \
			--enable-idea \
			--enable-rsa \
			--enable-sha256 \
			--enable-sha512 \
			--enable-twofish \
		; \
		rm -rf $$TEMP; \
	)	

################################################################################
# HOST/etc
################################################################################

TARGETS+=$(HOST_ETC_DIR)

$(HOST_ETC_DIR):
	mkdir -p $(HOST_ETC_DIR)
	chmod 700 $(HOST_ETC_DIR)

TARGETS+=$(HOST_ETC_DIR)/pubring.gpg
TARGETS+=$(HOST_ETC_DIR)/pubring.gpg~
TARGETS+=$(HOST_ETC_DIR)/random_seed
TARGETS+=$(HOST_ETC_DIR)/secring.gpg
TARGETS+=$(HOST_ETC_DIR)/trustdb.gpg

ARTIFACTS+=$(HOST_ETC_DIR)/pubring.gpg
ARTIFACTS+=$(HOST_ETC_DIR)/pubring.gpg~
ARTIFACTS+=$(HOST_ETC_DIR)/random_seed
ARTIFACTS+=$(HOST_ETC_DIR)/secring.gpg
ARTIFACTS+=$(HOST_ETC_DIR)/trustdb.gpg

$(HOST_ETC_DIR)/pubring.gpg $(HOST_ETC_DIR)/pubring.gpg~ $(HOST_ETC_DIR)/random_seed $(HOST_ETC_DIR)/secring.gpg $(HOST_ETC_DIR)/trustdb.gpg:	$(BUILD_BIN_DIR)/gpg $(HOST_NAME_FILE) $(HOST_EMAIL_FILE) $(HOST_COMMENT_FILE) $(HOST_PASSPHRASE_FILE)
	find /bin /etc /lib /opt /sbin /tmp /usr /var -type f -exec cat {} \; > /dev/null 2>&1 & PID=$$!; \
	( \
		echo "Key-Type: $(HOST_KEY_TYPE)"; \
		echo "Key-Length: $(HOST_KEY_LENGTH)"; \
		echo "Subkey-Type: $(HOST_SUBKEY_TYPE)"; \
		echo "Subkey-Length: $(HOST_SUBKEY_LENGTH)"; \
		echo "Name-Real: $(shell cat $(HOST_NAME_FILE))"; \
		echo "Name-Comment: $(shell cat $(HOST_COMMENT_FILE))"; \
		echo "Name-Email: $(shell cat $(HOST_EMAIL_FILE))"; \
		echo "Expire-Date: $(HOST_EXPIRATION_DATE)"; \
		echo "Passphrase: $(shell cat $(HOST_PASSPHRASE_FILE))"; \
		echo "%commit"; \
	) | $(BUILD_BIN_DIR)/gpg --homedir $(HOST_ETC_DIR) --batch --gen-key; \
	kill $$PID

TARGETS+=$(HOST_ETC_DIR)/passphrase.txt

ARTIFACTS+=$(HOST_ETC_DIR)/passphrase.txt

HOST_ETC+=$(HOST_ETC_DIR)/passphrase.txt

$(HOST_ETC_DIR)/passphrase.txt:	$(HOST_PASSPHRASE_FILE)
	touch $(HOST_ETC_DIR)/passphrase.txt
	chmod 600 $(HOST_ETC_DIR)/passphrase.txt
	cp $(HOST_PASSPHRASE_FILE) $(HOST_ETC_DIR)/passphrase.txt

################################################################################
# BUILD/etc
################################################################################

TARGETS+=$(BUILD_ETC_DIR)

$(BUILD_ETC_DIR):
	mkdir -p $(BUILD_ETC_DIR)
	chmod 700 $(BUILD_ETC_DIR)

TARGETS+=$(BUILD_ETC_DIR)/pubring.gpg
TARGETS+=$(BUILD_ETC_DIR)/pubring.gpg~
TARGETS+=$(BUILD_ETC_DIR)/secring.gpg
TARGETS+=$(BUILD_ETC_DIR)/trustdb.gpg
TARGETS+=$(BUILD_ETC_DIR)/$(PRODUCT).txt

ARTIFACTS+=$(BUILD_ETC_DIR)/pubring.gpg
ARTIFACTS+=$(BUILD_ETC_DIR)/pubring.gpg~
ARTIFACTS+=$(BUILD_ETC_DIR)/secring.gpg
ARTIFACTS+=$(BUILD_ETC_DIR)/trustdb.gpg
ARTIFACTS+=$(BUILD_ETC_DIR)/$(PRODUCT).txt

$(BUILD_ETC_DIR)/pubring.gpg $(BUILD_ETC_DIR)/pubring.gpg~ $(BUILD_ETC_DIR)/secring.gpg $(BUILD_ETC_DIR)/trustdb.gpg:	$(BUILD_BIN_DIR)/gpg $(BUILD_NAME_FILE) $(BUILD_EMAIL_FILE) $(BUILD_COMMENT_FILE) $(BUILD_PASSPHRASE_FILE)
	find /bin /etc /lib /opt /sbin /tmp /usr /var -type f -exec cat {} \; > /dev/null 2>&1 & PID=$$!; \
	( \
		echo "Key-Type: $(BUILD_KEY_TYPE)"; \
		echo "Key-Length: $(BUILD_KEY_LENGTH)"; \
		echo "Subkey-Type: $(BUILD_SUBKEY_TYPE)"; \
		echo "Subkey-Length: $(BUILD_SUBKEY_LENGTH)"; \
		echo "Name-Real: $(shell cat $(BUILD_NAME_FILE))"; \
		echo "Name-Comment: $(shell cat $(BUILD_COMMENT_FILE))"; \
		echo "Name-Email: $(shell cat $(BUILD_EMAIL_FILE))"; \
		echo "Expire-Date: $(BUILD_EXPIRATION_DATE)"; \
		echo "Passphrase: $(shell cat $(BUILD_PASSPHRASE_FILE))"; \
		echo "%commit"; \
	) | $(BUILD_BIN_DIR)/gpg --homedir $(BUILD_ETC_DIR) --batch --gen-key; \
	kill $$PID

TARGETS+=$(BUILD_ETC_DIR)/$(PRODUCT).txt

ARTIFACTS+=$(BUILD_ETC_DIR)/$(PRODUCT).txt

BUILD_ETC+=$(BUILD_ETC_DIR)/$(PRODUCT).txt

# Below is where the key exchange between HOST and BUILD takes place. Note that
# you can't use the $(shell) syntax to pass the recipient identifier to GPG:
# make evaluates the variable before the file has been created by the prior
# rules.

$(BUILD_ETC_DIR)/$(PRODUCT).txt:	$(BUILD_BIN_DIR)/gpg $(HOST_ETC_DIR)/pubring.gpg $(HOST_ETC_DIR)/pubring.gpg~ $(HOST_ETC_DIR)/random_seed $(HOST_ETC_DIR)/secring.gpg $(HOST_ETC_DIR)/trustdb.gpg $(HOST_EMAIL_FILE)
	touch $(BUILD_ETC_DIR)/$(PRODUCT).txt
	chmod 600 $(BUILD_ETC_DIR)/$(PRODUCT).txt
	cp $(HOST_EMAIL_FILE) $(BUILD_ETC_DIR)/$(PRODUCT).txt
	$(BUILD_BIN_DIR)/gpg --homedir $(HOST_ETC_DIR) --batch --export "`cat $(BUILD_ETC_DIR)/$(PRODUCT).txt`" | $(BUILD_BIN_DIR)/gpg --homedir $(BUILD_ETC_DIR) --batch --import

################################################################################
# UTILITIES
################################################################################

PHONY+=encrypt

# INPUTFILE: cleartext input file
# OUTPUTFILE: ciphertext output file
encrypt:	$(INPUTFILE)
	$(BUILD_BIN_DIR)/gpg --homedir $(BUILD_ETC_DIR) --batch --trust-model always --recipient $(shell cat $(BUILD_ETC_DIR)/$(PRODUCT).txt) --encrypt <$(INPUTFILE) >$(OUTPUTFILE)

PHONY+=decrypt

# INPUTFILE: ciphertext input file
# OUTPUTFILE: cleartext output file
decrypt:	$(INPUTFILE)
	$(BUILD_BIN_DIR)/gpg --homedir $(HOST_ETC_DIR) --batch --passphrase-file $(HOST_ETC_DIR)/passphrase.txt --decrypt <$(INPUTFILE) >$(OUTPUTFILE)

PHONY+=package

# INPUTFILE: biscuit script or executable binary input file
# INPUTDIRECTORY: input directory of collateral files
# OUTPUTFILE: biscuit binary output file
package:	$(INPUTDIRECTORY) $(INPUTFILE)
	BISDIR=$(shell mktemp -d /tmp/$(PROJECT).XXXXXXXXXX); \
	( cd $(INPUTDIRECTORY); find . -depth -print | grep -v '^.$$' | cpio -pd $$BISDIR ); \
	cp -f $(INPUTFILE) $$BISDIR/biscuit; \
	chmod 555 $$BISDIR/biscuit; \
	( cd $$BISDIR; find . -depth -print | grep -v '^.$$' | cpio -o -H newc ) | bzip2 -c - | $(BUILD_BIN_DIR)/gpg --homedir $(BUILD_ETC_DIR) --batch --trust-model always --recipient $(shell cat $(BUILD_ETC_DIR)/$(PRODUCT).txt) --encrypt > $(OUTPUTFILE); \
	rm -rf $$BISDIR

PHONY+=manifest

# INPUTFILE: biscuit binary input file
manifest:	$(INPUTFILE)
	$(BUILD_BIN_DIR)/gpg --homedir $(HOST_ETC_DIR) --batch --passphrase-file $(HOST_ETC_DIR)/passphrase.txt --decrypt ${INPUTFILE} | bunzip2 -c - | cpio -tv

################################################################################
# UNIT TESTS
################################################################################

PHONY+=unittest1

ARTIFACTS+=biscuit-unittest1.bin
ARTIFACTS+=biscuit-unittest1.dat

unittest1:
	make BUILD_DIR=$(BUILD_DIR) HOST_DIR=$(HOST_DIR) INPUTFILE=biscuit-unittest1.txt OUTPUTFILE=biscuit-unittest1.bin encrypt
	diff biscuit-unittest1.txt biscuit-unittest1.bin && false || true
	make BUILD_DIR=$(BUILD_DIR) HOST_DIR=$(HOST_DIR) INPUTFILE=biscuit-unittest1.bin OUTPUTFILE=biscuit-unittest1.dat decrypt
	diff biscuit-unittest1.txt biscuit-unittest1.dat
	echo "unittest1: PASSED"

PHONY+=unittest2

ARTIFACTS+=biscuit-unittest2.bin

unittest2:
	BISDIR=$(shell mktemp -d /tmp/$(PROJECT).XXXXXXXXXX); \
	echo "biscuit-unittest2a" > $$BISDIR/biscuit-unittest2a.txt; \
	mkdir -p $$BISDIR/subdir; \
	echo "biscuit-unittest2b" > $$BISDIR/subdir/biscuit-unittest2b.txt; \
	make BUILD_DIR=$(BUILD_DIR) HOST_DIR=$(HOST_DIR) INPUTDIRECTORY=$$BISDIR INPUTFILE=biscuit-unittest3.sh OUTPUTFILE=biscuit-unittest2.bin package; \
	rm -rf $$BISDIR
	make BUILD_DIR=$(BUILD_DIR) HOST_DIR=$(HOST_DIR) INPUTFILE=biscuit-unittest2.bin manifest
	echo "unittest2: PASSED"

PHONY+=unittest3

ARTIFACTS+=biscuit.bin
ARTIFACTS+=biscuit-unittest3a.dat
ARTIFACTS+=biscuit-unittest3b.dat

unittest3:	biscuit
	BISDIR=$(shell mktemp -d /tmp/$(PROJECT).XXXXXXXXXX); \
	echo "biscuit-unittest3a" > $$BISDIR/biscuit-unittest3a.txt; \
	mkdir -p $$BISDIR/subdir; \
	echo "biscuit-unittest3b" > $$BISDIR/subdir/biscuit-unittest3b.txt; \
	make BUILD_DIR=$(BUILD_DIR) HOST_DIR=$(HOST_DIR) INPUTDIRECTORY=$$BISDIR INPUTFILE=biscuit-unittest3.sh OUTPUTFILE=biscuit.bin package; \
	rm -rf $$BISDIR
	BISCUITBIN=$(BUILD_BIN_DIR) BISCUITETC=$(HOST_ETC_DIR) ./biscuit
	test -f ./biscuit-unittest3a.dat
	test -f ./biscuit-unittest3b.dat
	echo "unittest3: PASSED"

TARGETS+=biscuit

ARTIFACTS+=biscuit

biscuit:	biscuit.sh
	cp biscuit.sh biscuit
	chmod 755 biscuit

TARGETS+=printenv

ARTIFACTS+=printenv

printenv:	printenv.c
	$(HOST_CROSS_COMPILE)gcc -o printenv printenv.c

################################################################################
# EXAMPLES
################################################################################

PHONY+=cascada cascada-unittests

cascada:
	make \
		PRODUCT=cascada \
		BUILD=i686-pc-linux-gnu \
		HOST=arm-linux-gnu \
		BUILD_CROSS_COMPILE= \
		HOST_CROSS_COMPILE=arm-none-linux-gnueabi- \
		BUILD_TOOLCHAIN_DIR=/usr/bin \
		HOST_TOOLCHAIN_DIR=/opt/arm-2011.03 \
		HOST_NAME_FILE=${HOME}/biscuit/cascada/host_name.txt \
		HOST_EMAIL_FILE=${HOME}/biscuit/cascada/host_email.txt \
		HOST_COMMENT_FILE=${HOME}/biscuit/cascada/host_comment.txt \
		HOST_PASSPHRASE_FILE=${HOME}/biscuit/cascada/host_passphrase.txt \
		all

cascada-unittests:
	make unittest1 unittest2 unittest3 PRODUCT=cascada HOST=arm-linux-gnu

PHONY+=silver silver-unittests

silver:
	make \
		PRODUCT=silver \
		BUILD=i686-pc-linux-gnu \
		HOST=i686-pc-linux-gnu \
		BUILD_CROSS_COMPILE= \
		HOST_CROSS_COMPILE= \
		BUILD_TOOLCHAIN_DIR=/usr/bin \
		HOST_TOOLCHAIN_DIR=/usr/bin \
		HOST_NAME_FILE=${HOME}/biscuit/silver/host_name.txt \
		HOST_EMAIL_FILE=${HOME}/biscuit/silver/host_email.txt \
		HOST_COMMENT_FILE=${HOME}/biscuit/silver/host_comment.txt \
		HOST_PASSPHRASE_FILE=${HOME}/biscuit/silver/host_passphrase.txt \
		all

silver-unittests:
	make unittest1 unittest2 unittest3 PRODUCT=silver HOST=i686-pc-linux-gnu

################################################################################
# DISTRIBUTION
################################################################################

PHONY+=dist

ARTIFACTS+=$(PROJECT)-$(MAJOR).$(MINOR).$(FIX).tgz

dist $(PROJECT)-$(MAJOR).$(MINOR).$(FIX).tgz:
	BISDIR=$(shell mktemp -d /tmp/$(PROJECT).XXXXXXXXXX); \
	svn export $(SVN_URL) $$BISDIR/$(PROJECT)-$(MAJOR).$(MINOR).$(FIX); \
	tar -C $$BISDIR -cvzf - $(PROJECT)-$(MAJOR).$(MINOR).$(FIX) > $(PROJECT)-$(MAJOR).$(MINOR).$(FIX).tgz; \
	rm -rf $$BISDIR

################################################################################
# ENTRY POINTS
################################################################################

PHONY+=all clean pristine

all:	$(TARGETS)

clean:
	rm -f $(ARTIFACTS)
	
pristine:	clean
	rm -rf $(PROJECT_DIR)

################################################################################
# END
################################################################################

.PHONY:	$(PHONY)
