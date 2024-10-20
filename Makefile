PACKAGE_NAME := sample
SRC := sample.c
OBJ := sample.o
EXEC := sample
DEBUG_EXEC := $(EXEC)_debug
VERSION_INC := version.h

CC := gcc

# Flags
CCFLAGS = 

# Debug flags
DEBUG_CCFLAGS = -g

RPMBUILD_ROOT := $(shell pwd)/build
SOURCES_DIR := $(RPMBUILD_ROOT)/rpmbuild/SOURCES
SPECS_DIR := $(RPMBUILD_ROOT)/rpmbuild/SPECS
BUILD_DIR := $(RPMBUILD_ROOT)/rpmbuild/BUILD
RPMS_DIR := $(RPMBUILD_ROOT)/rpmbuild/RPMS
SRPMS_DIR := $(RPMBUILD_ROOT)/rpmbuild/SRPMS

# Git information
GIT_TAG := $(shell git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
COMMIT_HASH := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
GIT_STATUS := $(shell git status --porcelain 2>/dev/null | grep -q . && echo "-dirty" || echo "")
VERSION = $(GIT_TAG)-$(COMMIT_HASH)$(GIT_STATUS)
RELEASE = 1

# Default target
all: $(VERSION_INC) $(EXEC) debug

# Debug target
debug: $(VERSION_INC) $(DEBUG_EXEC)

# Update version information in main.s
$(VERSION_INC): version.h.in
	@echo "Updating version information..."
	@sed 's/@VERSION@/$(VERSION)/g; s/@GIT_TAG@/$(GIT_TAG)/g; s/@COMMIT_HASH@/$(COMMIT_HASH)/g; s/@GIT_STATUS@/$(GIT_STATUS)/g' $< > $@

$(EXEC): $(SRC) $(VERSION_INC)
	$(CC) $(CCFLAGS) -o $(EXEC) $(SRC)

# Assemble the source file into an object file (debug version)
$(OBJ:.o=_debug.o): $(SRC) $(VERSION_INC)
	$(AS) $(DEBUG_ASFLAGS) -o $(OBJ:.o=_debug.o) $(SRC)

# Link the object file to create the executable (debug version)
$(DEBUG_EXEC): $(SRC) $(VERSION_INC)
	$(CC) $(DEBUG_CCFLAGS) -o $(DEBUG_EXEC) $(SRC)

# Run test script
test:
	./test.sh

# Clean up generated files
clean:
	rm -f $(EXEC) $(DEBUG_EXEC)
	rm -rf $(RPMBUILD_ROOT)
	rm -f $(VERSION_INC)

setup-rpmbuild:
	mkdir -p $(SOURCES_DIR) $(SPECS_DIR) $(BUILD_DIR) $(RPMS_DIR) $(SRPMS_DIR)

TARBALL_EXCLUDE_PATTERN = --exclude='*/bin/*' --exclude='build' --exclude='*.o' --exclude='$(EXEC)' --exclude='$(DEBUG_EXEC)'
#FIND_EXECUTABLES = find . -type f -executable -not -name "*.*"
#GIT_LOG := $(shell git log --pretty=format:"* %ad %an <%ae> %D%n- %s%n" --date=format:"%a %b %d %Y")

rpm: all setup-rpmbuild
	sha256sum $(EXEC) > SHA256SUM
	sha256sum $(DEBUG_EXEC) > SHA256SUM_DEBUG
	tar czf $(SOURCES_DIR)/$(PACKAGE_NAME)-$(GIT_TAG).tar.gz $(TARBALL_EXCLUDE_PATTERN) .
	cp $(PACKAGE_NAME).spec $(SPECS_DIR)/
	# Gen changelog from git
	LANG=C git log --pretty=format:"* %ad %an <%ae> %D%n- %s%n" --date=format:"%a %b %d %Y" > changelog.tmp
	sed -i '/%changelog/r changelog.tmp' $(SPECS_DIR)/$(PACKAGE_NAME).spec
	rm changelog.tmp
	rpmbuild -ba \
		--define "_topdir $(RPMBUILD_ROOT)/rpmbuild" \
		--define "version $(GIT_TAG)" \
		--define "release $(RELEASE)" \
		$(SPECS_DIR)/$(PACKAGE_NAME).spec

.PHONY: all debug update_version test clean setup-rpmbuild rpm

