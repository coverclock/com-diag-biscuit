################################################################################
# Copyright 2011 by the Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in README.h
# Chip Overclock <coverclock@diag.com>
# http://www.diag.com/navigation/downloads/Biscuit
################################################################################

PROJECT=biscuit
MAJOR=0
MINOR=0
BUILD=0

SVN_URL=svn://graphite/biscuit/trunk/Biscuit
HTTP_URL=http://www.diag.com/navigation/downloads/Biscuit.html

################################################################################
# PARAMETERS
################################################################################

# We adopt the GNU nomenclature here: BUILD is the server side on which the
# software is all built and biscuit binary packages are encrypted. HOST is the
# target side on which the biscuit binary packages are decrypted and executed.

BUILD=i686-pc-linux-gnu
HOST=arm-linux-gnu

# The intent here is to choose EIGamal asymetric key encryption (which is not
# patent encumbered) of 1024 bits in length (to accomodate slower embedded
# systems) with no expiration date. But creating an expiration date for the
# HOST side would be a possible strategy too, resulting in an embedded system
# that could not run biscuits after a certain date.

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

# You can (and should) use your own name, recipient, comment, and passphrase
# files, and use different ones for different projects or versions of the same
# project. That prevents a biscuit for project A or version N from being used
# on project B or version N+1.

HOST_NAME_FILE=host_name.txt
HOST_EMAIL_FILE=host_email.txt
HOST_COMMENT_FILE=host_comment.txt
HOST_PASSPHRASE_FILE=host_passphrase.txt

BUILD_NAME_FILE=build_name.txt
BUILD_EMAIL_FILE=build_email.txt
BUILD_COMMENT_FILE=build_comment.txt
BUILD_PASSPHRASE_FILE=build_passphrase.txt

# Set these for using the various utilities like encrypt, decrypt, and package.

INPUTFILE=/dev/null
OUTPUTFILE=/dev/null
INPUTDIRECTORY=/dev/null

################################################################################
# PREREQUISITES
################################################################################

TOOLCHAIN_DIR=/opt/arm-2011.03#https://sourcery.mentor.com/sgpp/lite/arm/portal/package8739/public/arm-none-linux-gnueabi/arm-2011.03-41-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
SOURCE_DIR=$(HOME)/src/gnupg-1.4.11#ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-1.4.11.tar.bz2

################################################################################
# TOOL CHAINS
################################################################################

CROSS_COMPILE=arm-none-linux-gnueabi-
ARCH=arm

################################################################################
# PROJECT
################################################################################

CWD:=$(shell pwd)
PROJECT_DIR=$(CWD)/project
BUILD_DIR=$(PROJECT_DIR)/$(BUILD)
HOST_DIR=$(PROJECT_DIR)/$(HOST)

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

host:	$(HOST_DIR) $(HOST_DIR)/bin/gpg

TARGETS+=$(HOST_DIR)

$(HOST_DIR):
	mkdir -p $(HOST_DIR)

TARGETS+=$(HOST_DIR)/bin/gpg

HOST_BIN+=$(HOST_DIR)/bin/gpg

$(HOST_DIR)/bin/gpg:	$(HOST_DIR)/config.h
	( \
		PATH=$(CODESOURCERY_DIR)/bin:$$PATH; \
		cd $(HOST_DIR); \
		make install-strip; \
	)

$(HOST_DIR)/config.h:	$(SOURCE_DIR)/configure
	( \
		PATH=$(TOOLCHAIN_DIR)/bin:$$PATH; \
		cd $(HOST_DIR); \
		$(SOURCE_DIR)/configure \
			CC=$(CROSS_COMPILE)gcc \
			AR=$(CROSS_COMPILE)ar \
			RANLIB=$(CROSS_COMPILE)ranlib \
			STRIP=$(CROSS_COMPILE)strip \
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

build:	$(BUILD_DIR) $(BUILD_DIR)/bin/gpg

TARGETS+=$(BUILD_DIR)/

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

TARGETS+=$(BUILD_DIR)/bin/gpg

BUILD_BIN+=$(BUILD_DIR)/bin/gpg

$(BUILD_DIR)/bin/gpg:	$(BUILD_DIR)/config.h
	( \
		cd $(BUILD_DIR); \
		make install-strip; \
	)

$(BUILD_DIR)/config.h:	$(SOURCE_DIR)/configure
	( \
		cd $(BUILD_DIR); \
		$(SOURCE_DIR)/configure \
			ac_cv_type_mode_t=yes \
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

TARGETS+=$(HOST_DIR)/etc

$(HOST_DIR)/etc:
	mkdir -p $(HOST_DIR)/etc
	chmod 700 $(HOST_DIR)/etc

TARGETS+=$(HOST_DIR)/etc/pubring.gpg
TARGETS+=$(HOST_DIR)/etc/pubring.gpg~
TARGETS+=$(HOST_DIR)/etc/random_seed
TARGETS+=$(HOST_DIR)/etc/secring.gpg
TARGETS+=$(HOST_DIR)/etc/trustdb.gpg

ARTIFACTS+=host.txt
ARTIFACTS+=$(HOST_DIR)/etc/pubring.gpg
ARTIFACTS+=$(HOST_DIR)/etc/pubring.gpg~
ARTIFACTS+=$(HOST_DIR)/etc/random_seed
ARTIFACTS+=$(HOST_DIR)/etc/secring.gpg
ARTIFACTS+=$(HOST_DIR)/etc/trustdb.gpg

HOST_ETC+=$(HOST_DIR)/etc/pubring.gpg
HOST_ETC+=$(HOST_DIR)/etc/pubring.gpg~
HOST_ETC+=$(HOST_DIR)/etc/random_seed
HOST_ETC+=$(HOST_DIR)/etc/secring.gpg
HOST_ETC+=$(HOST_DIR)/etc/trustdb.gpg

host.txt:	$(HOST_NAME_FILE) $(HOST_EMAIL_FILE) $(HOST_COMMENT_FILE) $(HOST_PASSPHRASE_FILE) 
	echo "Key-Type: $(HOST_KEY_TYPE)" > host.txt
	echo "Key-Length: $(HOST_KEY_LENGTH)" >> host.txt
	echo "Subkey-Type: $(HOST_SUBKEY_TYPE)" >> host.txt
	echo "Subkey-Length: $(HOST_SUBKEY_LENGTH)" >> host.txt
	echo "Name-Real: $(shell cat $(HOST_NAME_FILE))" >> host.txt
	echo "Name-Comment: $(shell cat $(HOST_COMMENT_FILE))" >> host.txt
	echo "Name-Email: $(shell cat $(HOST_EMAIL_FILE))" >> host.txt
	echo "Expire-Date: $(HOST_EXPIRATION_DATE)" >> host.txt
	echo "Passphrase: $(shell cat $(HOST_PASSPHRASE_FILE))" >> host.txt
	echo "%commit" >> host.txt

$(HOST_DIR)/etc/pubring.gpg $(HOST_DIR)/etc/pubring.gpg~ $(HOST_DIR)/etc/random_seed $(HOST_DIR)/etc/secring.gpg $(HOST_DIR)/etc/trustdb.gpg:	$(BUILD_DIR)/bin/gpg host.txt
	find /bin /etc /lib /opt /sbin /tmp /usr /var -type f -exec cat {} \; > /dev/null 2>&1 & PID=$$!; \
	$(BUILD_DIR)/bin/gpg --homedir $(HOST_DIR)/etc --batch --gen-key < host.txt; \
	kill $$PID

TARGETS+=$(HOST_DIR)/etc/passphrase.txt

ARTIFACTS+=$(HOST_DIR)/etc/passphrase.txt

HOST_ETC+=$(HOST_DIR)/etc/passphrase.txt

$(HOST_DIR)/etc/passphrase.txt:	$(HOST_PASSPHRASE_FILE)
	touch $(HOST_DIR)/etc/passphrase.txt
	chmod 600 $(HOST_DIR)/etc/passphrase.txt
	cp $(HOST_PASSPHRASE_FILE) $(HOST_DIR)/etc/passphrase.txt

################################################################################
# BUILD/etc
################################################################################

TARGETS+=$(BUILD_DIR)/etc

$(BUILD_DIR)/etc:
	mkdir -p $(BUILD_DIR)/etc
	chmod 700 $(BUILD_DIR)/etc

TARGETS+=$(BUILD_DIR)/etc/pubring.gpg
TARGETS+=$(BUILD_DIR)/etc/pubring.gpg~
TARGETS+=$(BUILD_DIR)/etc/secring.gpg
TARGETS+=$(BUILD_DIR)/etc/trustdb.gpg
TARGETS+=$(BUILD_DIR)/etc/recipient.txt

ARTIFACTS+=build.txt
ARTIFACTS+=$(BUILD_DIR)/etc/pubring.gpg
ARTIFACTS+=$(BUILD_DIR)/etc/pubring.gpg~
ARTIFACTS+=$(BUILD_DIR)/etc/secring.gpg
ARTIFACTS+=$(BUILD_DIR)/etc/trustdb.gpg
ARTIFACTS+=$(BUILD_DIR)/etc/recipient.txt

BUILD_ETC+=$(BUILD_DIR)/etc/pubring.gpg
BUILD_ETC+=$(BUILD_DIR)/etc/pubring.gpg~
BUILD_ETC+=$(BUILD_DIR)/etc/secring.gpg
BUILD_ETC+=$(BUILD_DIR)/etc/trustdb.gpg
BUILD_ETC+=$(BUILD_DIR)/etc/recipient.txt

build.txt:	$(BUILD_NAME_FILE) $(BUILD_EMAIL_FILE) $(BUILD_COMMENT_FILE) $(BUILD_PASSPHRASE_FILE) 
	echo "Key-Type: $(BUILD_KEY_TYPE)" > build.txt
	echo "Key-Length: $(BUILD_KEY_LENGTH)" >> build.txt
	echo "Subkey-Type: $(BUILD_SUBKEY_TYPE)" >> build.txt
	echo "Subkey-Length: $(BUILD_SUBKEY_LENGTH)" >> build.txt
	echo "Name-Real: $(shell cat $(BUILD_NAME_FILE))" >> build.txt
	echo "Name-Comment: $(shell cat $(BUILD_COMMENT_FILE))" >> build.txt
	echo "Name-Email: $(shell cat $(BUILD_EMAIL_FILE))" >> build.txt
	echo "Expire-Date: $(BUILD_EXPIRATION_DATE)" >> build.txt
	echo "Passphrase: $(shell cat $(BUILD_PASSPHRASE_FILE))" >> build.txt
	echo "%commit" >> build.txt

$(BUILD_DIR)/etc/pubring.gpg $(BUILD_DIR)/etc/pubring.gpg~ $(BUILD_DIR)/etc/secring.gpg $(BUILD_DIR)/etc/trustdb.gpg:	$(BUILD_DIR)/bin/gpg build.txt
	find /bin /etc /lib /opt /sbin /tmp /usr /var -type f -exec cat {} \; > /dev/null 2>&1 & PID=$$!; \
	$(BUILD_DIR)/bin/gpg --homedir $(BUILD_DIR)/etc --batch --gen-key < build.txt; \
	kill $$PID

TARGETS+=$(BUILD_DIR)/etc/recipient.txt

ARTIFACTS+=$(BUILD_DIR)/etc/recipient.txt

BUILD_ETC+=$(BUILD_DIR)/etc/recipient.txt

$(BUILD_DIR)/etc/recipient.txt:	$(HOST_DIR)/etc/pubring.gpg $(HOST_DIR)/etc/pubring.gpg~ $(HOST_DIR)/etc/random_seed $(HOST_DIR)/etc/secring.gpg $(HOST_DIR)/etc/trustdb.gpg $(HOST_EMAIL_FILE)
	$(BUILD_DIR)/bin/gpg --homedir $(HOST_DIR)/etc --batch --export $(shell cat $(HOST_EMAIL_FILE)) | $(BUILD_DIR)/bin/gpg --homedir $(BUILD_DIR)/etc --batch --import
	touch $(BUILD_DIR)/etc/recipient.txt
	chmod 600 $(BUILD_DIR)/etc/recipient.txt
	cp $(HOST_EMAIL_FILE) $(BUILD_DIR)/etc/recipient.txt

################################################################################
# UTILITIES
################################################################################

PHONY+=encrypt

# INPUTFILE: cleartext input file
# OUTPUTFILE: ciphertext output file
encrypt:	$(INPUTFILE)
	rm -f $(OUTPUTFILE)
	$(BUILD_DIR)/bin/gpg --homedir $(BUILD_DIR)/etc --batch --trust-model always --recipient $(shell cat $(BUILD_DIR)/etc/recipient.txt) --output $(OUTPUTFILE) --encrypt $(INPUTFILE)

PHONY+=decrypt

# INPUTFILE: ciphertext input file
# OUTPUTFILE: cleartext output file
decrypt:	$(INPUTFILE)
	rm -f $(OUTPUTFILE)
	$(BUILD_DIR)/bin/gpg --homedir $(HOST_DIR)/etc --batch --passphrase-file $(HOST_DIR)/etc/passphrase.txt --output $(OUTPUTFILE) --decrypt $(INPUTFILE)

PHONY+=package

# INPUTFILE: biscuit script or executable input file
# INPUTDIRECTORY: input directory of collateral files
# OUTPUTFILE: biscuit binary output file
package:	$(INPUTDIRECTORY) $(INPUTFILE)
	BISDIR=$(shell mktemp -d /tmp/$(PROJECT).XXXXXXXXXX); \
	( cd $(INPUTDIRECTORY); find . -depth -print | grep -v '^.$$' | cpio -pd $$BISDIR ); \
	cp -f $(INPUTFILE) $$BISDIR/biscuit; \
	chmod 555 $$BISDIR/biscuit; \
	( cd $$BISDIR; find . -depth -print | grep -v '^.$$' | cpio -o -H newc ) | bzip2 -c - | $(BUILD_DIR)/bin/gpg --homedir $(BUILD_DIR)/etc --batch --trust-model always --recipient $(shell cat $(BUILD_DIR)/etc/recipient.txt) --encrypt > $(OUTPUTFILE); \
	rm -rf $$BISDIR

PHONY+=manifest

# INPUTFILE: biscuit binary input file
manifest:	$(INPUTFILE)
	$(BUILD_DIR)/bin/gpg --homedir $(HOST_DIR)/etc --batch --passphrase-file $(HOST_DIR)/etc/passphrase.txt --decrypt ${INPUTFILE} | bunzip2 -c - | cpio -tv

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
	BISCUITBIN=$(BUILD_DIR)/bin BISCUITETC=$(HOST_DIR)/etc ./biscuit
	test -f ./biscuit-unittest3a.dat
	test -f ./biscuit-unittest3b.dat

TARGETS+=biscuit

ARTIFACTS+=biscuit

biscuit:	biscuit.sh
	cp biscuit.sh biscuit
	chmod 755 biscuit

################################################################################
# DISTRIBUTION
################################################################################

PHONY+=dist

ARTIFACTS+=$(PROJECT)-$(MAJOR).$(MINOR).$(BUILD).tgz

dist $(PROJECT)-$(MAJOR).$(MINOR).$(BUILD).tgz:
	BISDIR=$(shell mktemp -d /tmp/$(PROJECT).XXXXXXXXXX); \
	svn export $(SVN_URL) $$BISDIR/$(PROJECT)-$(MAJOR).$(MINOR).$(BUILD); \
	tar -C $$BISDIR -cvzf - $(PROJECT)-$(MAJOR).$(MINOR).$(BUILD) > $(PROJECT)-$(MAJOR).$(MINOR).$(BUILD).tgz; \
	rm -rf $$BISDIR

################################################################################
# ENTRY POINTS
################################################################################

PHONY+=all clean pristine

all:	$(TARGETS)

clean:
	rm -f $(ARTIFACTS)
	
pristine:	clean
	rm -rf $(HOST_DIR)
	rm -rf $(BUILD_DIR)

################################################################################
# END
################################################################################

.PHONY:	$(PHONY)
