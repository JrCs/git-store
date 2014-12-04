# $Id$
# Makefile pour construire le RPM de git-store
SHELL   = /bin/bash
NAME    = git-store
VERSION = $(shell awk '/Version:/{print $$2;exit}' $(NAME).spec)

DIST_ARCHIVE = $(distdir).tar.gz
GZIP_ENV = --best

distdir = $(NAME)-$(VERSION)

am__tar = /bin/tar chof - $(distdir)
am__remove_distdir = \
  { test ! -d "$(distdir)" \
    || { find "$(distdir)" -type d ! -perm -200 -exec chmod u+w {} ';' \
         && rm -fr "$(distdir)"; }; }

$(DIST_ARCHIVE): dist

distdir:
	$(am__remove_distdir)
	test -d "$(distdir)" || mkdir "$(distdir)"
	cp Makefile git-store utils.lib "$(distdir)"

dist: distdir
	tardir=$(distdir) && $(am__tar) | GZIP=$(GZIP_ENV) gzip -c >$(DIST_ARCHIVE)
	$(am__remove_distdir)

# Nettoyage 
clean:
	@$(am__remove_distdir)
	@rm -f $(DIST_ARCHIVE) /tmp/SRPMS/$(NAME)-* *~

# Cible 'sources' utilisée par Koji dans le cadre de la construction du RPM source
# Création du tar.gz des sources
sources: clean dist

# Cible 'srpm' utilisée pour debug
srpm: sources
	rpmbuild --define "_topdir /tmp" \
		--define "_sourcedir ." \
		--define "_specdir ." \
		--nodeps -bs $(NAME).spec
