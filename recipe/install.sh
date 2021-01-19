#!/bin/bash

unset _CONDA_PYTHON_SYSCONFIGDATA_NAME
cd forgebuild
ninja install || (cat meson-logs/meson-log.txt; false)
# remove libtool files
find $PREFIX -name '*.la' -delete

# gdb folder has a nested folder structure similar to our host prefix
# (255 chars) which causes installation issues so remove it.
rm -rf $PREFIX/share/gdb

if [[ "$PKG_NAME" == glib ]]; then
    # Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
    # This will allow them to be run on environment activation.
    for CHANGE in "activate" "deactivate"
    do
        mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
        cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
     done
else
    mkdir .keep
    # We ship glib-compile-* and gio-* binaries as part of the libglib packages
    # as they are native binaries and also come along inside of libglib
    # in other distributions.
    mv $PREFIX/bin/glib-compile* .keep
    rm $PREFIX/bin/gdbus* $PREFIX/bin/glib* $PREFIX/bin/gobject* $PREFIX/bin/gresource $PREFIX/bin/gsettings $PREFIX/bin/gtester*
    mv .keep/glib-compile* $PREFIX/bin
    rm -r $PREFIX/include/gio-* $PREFIX/include/glib-*
    rm -r $PREFIX/lib/pkgconfig/{gio*,glib*,gmodule*,gobject*,gthread*}
    rm -r $PREFIX/share/aclocal/{glib*,gsettings*}
    rm -r $PREFIX/share/bash-completion/completions/{gapplication,gdbus,gresource,gsettings}
    rm -r $PREFIX/share/glib-*
fi
