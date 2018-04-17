#!/bin/bash
# find and remove
#/*f6996*/
#
#@include "\x2fhom\x65/ad\x6din/\x77eb/\x6eako\x6cesa\x68.ne\x74.ua\x2fpub\x6cic_\x68tml\x2fwa-\x63ach\x65/ap\x70s/c\x6fnta\x63ts/\x66avi\x63on_\x615ac\x34a.i\x63o";
#
#/*f6996*/

SITE_PATH=$1

if [[ -d ${SITE_PATH} ]]; then
	echo "Find ${SITE_PATH} "
else
	echo "${SITE_PATH} not found"
	exit 1
fi

#find pattern /*f6996*/ in php scripts
for i in `find ${SITE_PATH} -type f -name "*.php" |xargs egrep -ril "^\/\*[[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]]\*\/$"`; do
	echo "find file $i"
	#check for availability pattern "@include"
	if [[ -n $(grep -ril -E "^@include \"\.*" $i) ]]; then
		echo "remove line in file $i"
		sed -i '/^\/\*[[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]]\*\/$/,/^\/\*[[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]]\*\/$/d' $i
	fi
	# Remove line break
	sed -i '/^<\?\n*$/d' $i
	#clear file if is only <?php ?>  or <?php 
	#sed -i '/^<?php\s?>$'
done

#Find and remove long space pattern <?php                    
echo Find and remove long space...
find ${SITE_PATH} -type f -name '*.php' |xargs perl -pi -e's/^<\?php\s{100,}.*$/<\?php/' 2>/dev/null && echo "OK" || exit 1

echo Find and remove pattern favicon_c45b08.ico
find ${SITE_PATH} -type f -name "favicon_*.ico" -exec rm -rfv {} \; && echo "OK" || exit 1

while true; do
	read -p "Do you want to change permissions? (yes/no): "  I
	if [[ $I = "yes" ]]; then
		echo -n Change permissions...
	    find ${SITE_PATH} -type f -exec chmod 644 {} \; && echo "Files OK" || exit 1
	    find ${SITE_PATH} -type d -exec chmod 755 {} \; && echo "Directories OK" || exit 1
	    break
	elif [[ $I = "no" ]]; then
	    echo Stop change permissions
	    break
	else
		echo Please enter either \"yes\" or \"no\"
		continue
	fi
done
