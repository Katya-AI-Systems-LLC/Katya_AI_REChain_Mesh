# RPM build steps (example) for packaging Flutter Linux build into RPM for Aurora/Sailfish

Preconditions:
- You need a Linux host with rpmbuild tools installed (Fedora/CentOS/RHEL or openSUSE).
- Flutter desktop/linux build environment set up.

Steps:
1. Build Flutter Linux artifact:
   ```bash
   flutter channel stable
   flutter upgrade
   flutter build linux --release
   ```
   The build will produce `build/linux/x64/release/bundle` with binary and assets.

2. Prepare source tarball:
   ```bash
   mkdir -p ~/rpmbuild/SOURCES/meshapp-0.1.0
   cp -r build/linux/x64/release/bundle/* ~/rpmbuild/SOURCES/meshapp-0.1.0/
   cd ~/rpmbuild/SOURCES
   tar czf meshapp-0.1.0.tar.gz meshapp-0.1.0
   ```

3. Place specfile (specfile.spec) into `~/rpmbuild/SPECS/` and build:
   ```bash
   cp specfile.spec ~/rpmbuild/SPECS/
   rpmbuild -ba ~/rpmbuild/SPECS/specfile.spec
   ```

4. The resulting RPM will be in `~/rpmbuild/RPMS/` — transfer and install on target device via `rpm -Uvh` or through device-specific package manager.

Notes:
- Adjust BuildRequires and Requires in spec depending on target device libraries.
- Test on a VM or container that mimics target Aurora OS environment.
