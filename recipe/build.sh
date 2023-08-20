#!/usr/bin/env bash
set -ex

OSX_ARGS=""
if [[ $target_platform == "osx-"* ]]; then
  # the following do not build on macOS
  # wall is already on macOS
  # uuid conflicts with ossp-uuid
  OSX_ARGS="--disable-ipcs \
            --disable-ipcrm \
            --disable-wall \
            --disable-libmount \
            --enable-libuuid"

fi

# https://kernelnewbies.org/Linux_4.10
# https://elixir.bootlin.com/linux/v4.10.17/source/include/uapi/linux/sockios.h
export CPPFLAGS="${CPPFLAGS} -DSIOCGSKNS=0x894C"

./configure --prefix="${PREFIX}" \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-static     \
            --without-systemd    \
            --disable-makeinstall-chown \
            --disable-makeinstall-setuid \
            --without-systemdsystemunitdir \
            $OSX_ARGS
make -j ${CPU_COUNT}

known_fail="TS_OPT_misc_setarch_known_fail=yes"
known_fail+=" TS_OPT_column_invalid_multibyte_known_fail=yes"
known_fail+=" TS_OPT_hardlink_options_known_fail=yes"  # flaky on py3.9?
if [[ $target_platform == linux-aarch64 ]]; then
  known_fail+=" TS_OPT_lsfd_mkfds_ro_regular_file_known_fail=yes"  # can be flaky on this platform
fi
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
make check $known_fail
fi

make install
