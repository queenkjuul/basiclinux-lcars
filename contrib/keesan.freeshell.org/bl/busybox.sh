#!/bin/sh

BUSYBOX="busybox"

offset=`$BUSYBOX --help | \
grep -n "Currently defined functions:" | \
sed -e "s/^\([0-9]*\):.*$/\1/"`

echo "#!/bin/sh" >tmpscript
echo -n "for i in" >>tmpscript

$BUSYBOX --help | \
tail -n +`expr $offset "+" 1` | \
sed -e "s/,/ /g" | tr '\n' ' ' | \
sed -e "s/\[//" >>tmpscript

echo "; do ln -s $BUSYBOX \$i; done" >>tmpscript
echo >>tmpscript

chmod +x tmpscript
sh tmpscript

rm -f tmpscript
