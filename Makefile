# $Id$
# Makefile pour construire le RPM de git-store
SHELL   := /bin/bash
NAME    := git-store
VERSION := $(shell ./$(NAME) --version | sed -nE 's/^.*\s+//p')

BINS    = git-store
SPEC    = git-store.spec

DIST_ARCHIVE = $(distdir).tar.gz
GZIP_ENV = --best

distdir = $(NAME)-$(VERSION)

am__tar = /bin/tar chof - $(distdir)
am__remove_distdir = \
  { test ! -d "$(distdir)" \
    || { find "$(distdir)" -type d ! -perm -200 -exec chmod u+w {} ';' \
         && rm -fr "$(distdir)"; }; }

$(DIST_ARCHIVE): dist

.PHONY: spec clean distclean dist distdir sources install srpm

%: %.in
	sed 's/@VERSION@/$(VERSION)/g' $< > $@

spec: $(SPEC)

distdir:
	$(am__remove_distdir)
	test -d "$(distdir)" || mkdir "$(distdir)"
	cp Makefile $(BINS) "$(distdir)"

dist: distdir
	tardir=$(distdir) && $(am__tar) | GZIP=$(GZIP_ENV) gzip -c >$(DIST_ARCHIVE)
	$(am__remove_distdir)

# Nettoyage 
clean:
	@$(am__remove_distdir)
	@rm -f $(DIST_ARCHIVE) /tmp/SRPMS/$(NAME)-* *~

distclean: clean
	@rm -f $(SPEC)

# Cible 'sources' utilisée par Koji dans le cadre de la construction du RPM source
# Création du tar.gz des sources
sources: clean $(SPEC) dist
	if groups | grep -q -E '\bmockbuild\b'; then cp $(SPEC) bootstrap.spec; fi

install: $(BINS)
	@install -m 0755 $(BINS) "$${PREFIX:-/usr}"/bin

# Cible 'srpm'
srpm: sources
	rpmbuild --define "_topdir /tmp" \
		--define "_sourcedir ." \
		--define "_specdir ." \
		--nodeps -bs $(NAME).spec
