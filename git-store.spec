Name:			git-store
Version:		0.1
Release:		1%{?dist}
Summary:		Git store

License:		GPLv2
URL:			https://github.com/JrCs/git-store.git
Source:         %{name}-%{version}.tar.gz

#BuildRequires:	
Requires:		git

%description
Git Store

%prep
%setup -q

%install
rm -rf $RPM_BUILD_ROOT
%__install -d -m 0755 $RPM_BUILD_ROOT/%{_bindir}
%__install -m 0644 git-store $RPM_BUILD_ROOT/%{_bindir}/
%__install -m 0444 utils.lib $RPM_BUILD_ROOT/%{_bindir}/

%files
%{_bindir}

%changelog
