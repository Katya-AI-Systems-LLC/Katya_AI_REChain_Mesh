Name: meshapp
Version: 0.1.0
Release: 1
Summary: MeshApp Flutter-based package (for Aurora/Sailfish devices)
License: MIT
Group: Applications/Network
URL: https://example.org/meshapp
Source0: %{name}-%{version}.tar.gz

BuildArch: noarch
BuildRequires: qt5-qtbase-devel
Requires: qt5-qtbase

%description
MeshApp — offline mesh messenger & voting app scaffold. This package contains a Linux-flutter build or a wrapper to run the Flutter engine on a Sailfish/Aurora device.

%prep
%setup -q

%build
# Build steps depend on packaging approach. This spec is a template:
# - If you include a prebuilt flutter-embed, place binaries in usr/lib/%{name}
true

%install
mkdir -p %{buildroot}/opt/meshapp
cp -r * %{buildroot}/opt/meshapp/

%files
/opt/meshapp

%changelog
* Thu Oct 23 2025 Your Name <you@example.org> - 0.1.0-1
- Initial package
