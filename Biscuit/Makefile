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

# The intent here is to choose EIGamal asymetric key encryption (which is not
# patent encumbered) of 1024 bits in length (to accomodate slower embedded
# systems) with no expiration date. You can change the name, recipient, comment,
# and passphrase files to be anything you want, and use different ones for
# different projects or versions of the same project. That prevents a biscuit
# for project A or version N from being used on project B or version N+1.

HOST_NAME_FILE=host_name.txt
HOST_EMAIL_FILE=host_email.txt
HOST_COMMENT_FILE=host_comment.txt
HOST_PASSPHRASE_FILE=host_passphrase.txt
HOST_KEY_TYPE=DSA
HOST_KEY_LENGTH=1024
HOST_SUBKEY_TYPE=ELG-E
HOST_SUBKEY_LENGTH=1024
HOST_EXPIRATION_DATE=0

BUILD_NAME_FILE=build_name.txt
BUILD_EMAIL_FILE=build_email.txt
BUILD_COMMENT_FILE=build_comment.txt
BUILD_PASSPHRASE_FILE=build_passphrase.txt
BUILD_KEY_TYPE=DSA
BUILD_KEY_LENGTH=1024
BUILD_SUBKEY_TYPE=ELG-E
BUILD_SUBKEY_LENGTH=1024
BUILD_EXPIRATION_DATE=0

################################################################################
# SERVER
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

# We adopt the GNU nomenclature here: BUILD is the server side on which the
# software is all built and biscuit binary packages are encrypted. HOST is the
# target side on which the biscuit binary packages are decrypted.

BUILD=i686-pc-linux-gnu
HOST=arm-linux-gnu

PROJECT_DIR=$(HOME)/projects/$(PROJECT)
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
	chmod 700 $(BUILD_DIR)/etc

TARGETS+=$(HOST_DIR)/etc/pubring.gpg
TARGETS+=$(HOST_DIR)/etc/pubring.gpg~
TARGETS+=$(HOST_DIR)/etc/random_seed
TARGETS+=$(HOST_DIR)/etc/secring.gpg
TARGETS+=$(HOST_DIR)/etc/trustdb.gpg
TARGETS+=$(HOST_DIR)/etc/passphrase.txt

ARTIFACTS+=host.txt
ARTIFACTS+=$(HOST_DIR)/etc/pubring.gpg
ARTIFACTS+=$(HOST_DIR)/etc/pubring.gpg~
ARTIFACTS+=$(HOST_DIR)/etc/random_seed
ARTIFACTS+=$(HOST_DIR)/etc/secring.gpg
ARTIFACTS+=$(HOST_DIR)/etc/trustdb.gpg
ARTIFACTS+=$(HOST_DIR)/etc/passphrase.txt

HOST_ETC+=$(HOST_DIR)/etc/pubring.gpg
HOST_ETC+=$(HOST_DIR)/etc/pubring.gpg~
HOST_ETC+=$(HOST_DIR)/etc/random_seed
HOST_ETC+=$(HOST_DIR)/etc/secring.gpg
HOST_ETC+=$(HOST_DIR)/etc/trustdb.gpg
HOST_ETC+=$(HOST_DIR)/etc/passphrase.txt

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

$(HOST_DIR)/etc/pubring.gpg $(HOST_DIR)/etc/pubring.gpg~ $(HOST_DIR)/etc/random_seed $(HOST_DIR)/etc/secring.gpg $(HOST_DIR)/etc/trustdb.gpg:	$(BUILD_DIR)/bin/gpg $(HOST_DIR)/etc/passphrase.txt host.txt
	find /bin /etc /lib /opt /sbin /tmp /usr /var -type f -exec cat {} \; > /dev/null 2>&1 & PID=$$!; \
	$(BUILD_DIR)/bin/gpg --homedir $(HOST_DIR)/etc --batch --gen-key < host.txt; \
	kill $$PID

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

$(BUILD_DIR)/etc/pubring.gpg $(BUILD_DIR)/etc/pubring.gpg~ $(BUILD_DIR)/etc/secring.gpg $(BUILD_DIR)/etc/trustdb.gpg:	$(BUILD_DIR)/bin/gpg $(HOST_DIR)/etc/pubring.gpg $(HOST_DIR)/etc/pubring.gpg~ $(HOST_DIR)/etc/random_seed $(HOST_DIR)/etc/secring.gpg $(HOST_DIR)/etc/trustdb.gpg $(BUILD_DIR)/etc/recipient.txt build.txt
	find /bin /etc /lib /opt /sbin /tmp /usr /var -type f -exec cat {} \; > /dev/null 2>&1 & PID=$$!; \
	$(BUILD_DIR)/bin/gpg --homedir $(BUILD_DIR)/etc --batch --gen-key < build.txt; \
	kill $$PID
	TEMP=$(shell mktemp /tmp/biscuit.XXXXXXXXXX); \
	chmod 600 $$TEMP; \
	$(BUILD_DIR)/bin/gpg --homedir $(HOST_DIR)/etc --batch --export $(shell cat $(HOST_EMAIL_FILE)) > $$TEMP; \
	$(BUILD_DIR)/bin/gpg --homedir $(BUILD_DIR)/etc --batch --import $$TEMP; \
	rm -f $$TEMP

TARGETS+=$(BUILD_DIR)/etc/recipient.txt

ARTIFACTS+=$(BUILD_DIR)/etc/recipient.txt

BUILD_ETC+=$(BUILD_DIR)/etc/recipient.txt

$(BUILD_DIR)/etc/recipient.txt:	$(HOST_EMAIL_FILE)
	touch $(BUILD_DIR)/etc/recipient.txt
	chmod 600 $(BUILD_DIR)/etc/recipient.txt
	cp $(HOST_EMAIL_FILE) $(BUILD_DIR)/etc/recipient.txt

################################################################################
# ENCRYPT
################################################################################

PHONY+=encrypt

encrypt:	$(BUILD_DIR)/bin/gpg $(BUILD_DIR)/etc/pubring.gpg $(BUILD_DIR)/etc/pubring.gpg~ $(BUILD_DIR)/etc/secring.gpg $(BUILD_DIR)/etc/trustdb.gpg $(BUILD_DIR)/etc/recipient.txt
	rm -f $(CIPHEROUTPUTFILE)
	$(BUILD_DIR)/bin/gpg --homedir $(BUILD_DIR)/etc --batch --trust-model always --recipient $(shell cat $(BUILD_DIR)/etc/recipient.txt) --output $(CIPHEROUTPUTFILE) --encrypt $(CLEARINPUTFILE)

################################################################################
# DECRYPT
################################################################################

PHONY+=decrypt

decrypt:	$(BUILD_DIR)/bin/gpg $(HOST_DIR)/etc/pubring.gpg $(HOST_DIR)/etc/pubring.gpg~ $(HOST_DIR)/etc/random_seed $(HOST_DIR)/etc/secring.gpg $(HOST_DIR)/etc/trustdb.gpg $(HOST_DIR)/etc/passphrase.txt
	rm -f $(CLEAROUTPUTFILE)
	$(BUILD_DIR)/bin/gpg --homedir $(HOST_DIR)/etc --batch --passphrase-file $(HOST_DIR)/etc/passphrase.txt --output $(CLEAROUTPUTFILE) --decrypt $(CIPHERINPUTFILE)

################################################################################
# TESTS
################################################################################

unittest1:
	make CLEARINPUTFILE=millay.txt CIPHEROUTPUTFILE=millay.cip CIPHERINPUTFILE=millay.cip CLEAROUTPUTFILE=millay.dat encrypt decrypt
	diff millay.txt millay.dat

################################################################################
# DISTRIBUTION
################################################################################

PHONY+=dist

ARTIFACTS+=$(PROJECT)-$(MAJOR).$(MINOR).$(BUILD).tgz

dist $(PROJECT)-$(MAJOR).$(MINOR).$(BUILD).tgz:
	export TMPDIR=$(shell mktemp -d /tmp/$(PROJECT).XXXXXXXXXX); \
	svn export $(SVN_URL) $$TMPDIR/$(PROJECT)-$(MAJOR).$(MINOR).$(BUILD); \
	tar -C $$TMPDIR -cvzf - $(PROJECT)-$(MAJOR).$(MINOR).$(BUILD) > $(PROJECT)-$(MAJOR).$(MINOR).$(BUILD).tgz; \
	rm -rf $$TMPDIR

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
