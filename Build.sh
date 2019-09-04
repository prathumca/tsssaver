#!/bin/sh

#  Build.sh
#  TSS Saver
#
#  Created by Prathap Dodla on 16/03/17.
#

clear

export THEOS=/opt/theos
export THEOS_MAKE_PATH=/opt/theos/makefiles

PROD_NAME="TSSSaver"
DYLIB_NAME="TSSSaver"
HOME_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BUILD_DIR="build"
DYNAMIC_LIB_OPATH="Library/MobileSubstrate/DynamicLibraries"

INFOPLIST_PATH="./Resources/Info.plist"
echo "**** Infolist path -> $INFOPLIST_PATH ****"
VERSION=$(/usr/libexec/PlistBuddy -c "Print :Version" "${INFOPLIST_PATH}")
echo "**** Got version as -> $VERSION ****"
OUTPUT_DIR="../../Development/Tweaks/cydiarepo/cydiarepo/"
USER_HOME=$(eval echo ~${SUDO_USER})

cd "$HOME_DIR"

echo "**** Cleaning Output Directory ****"
sudo rm -rf "./output"

DEBUG="1"
echo "Is it a beta package (y/n)?"
read answer
if echo "$answer" | grep -iq "^N" ;
then
OUTPUT_DIR="../../Development/Tweaks/Bigboss/"
DEBUG="0"
else
DEBUG="1"
fi

echo "**** Output dir is -> $OUTPUT_DIR ********"

make -C "$HOME_DIR" -f MakeFile DEBUG=$DEBUG

mkdir -p ./$BUILD_DIR/DEBIAN
cp ./control ./$BUILD_DIR/DEBIAN
cp ./postinst ./$BUILD_DIR/DEBIAN
#cp ./extrainst_ ./$BUILD_DIR/DEBIAN
chmod -R 755 ./$BUILD_DIR/DEBIAN

#copy to lib folder
mkdir -p ./$BUILD_DIR/usr/lib
for file in ./output/lib*.dylib; do
echo "******** 2. ldid'ng ***** ${file}****"
ldid -S ${file}
cp -r ${file} ./$BUILD_DIR/usr/lib
done

#copy to DynamicLibraries folder
mkdir -p ./$BUILD_DIR/$DYNAMIC_LIB_OPATH
for file in ./output/TSS*.dylib; do
echo "******** ldid'ng ***** ${file}****"
ldid -S ${file}
cp -r ${file} ./$BUILD_DIR/$DYNAMIC_LIB_OPATH
done

#Now get plist files from each directory and copy to DynamicLibraries folder
for file in "$HOME_DIR"/**/TSS*.plist; do
#echo "${file##*/}";
cp -r "${file}" ./$BUILD_DIR/$DYNAMIC_LIB_OPATH
done

#copy to App
echo "******** building App *****"
mkdir -p ./$BUILD_DIR/Applications
echo "******** ldid'ng ***** ./output/TSSSaver.app/TSSSaver ****"
#ldid -S./Entitlements.xml "./output/TSSSaver.app/TSSSaver"
cp -r ./output/"$PROD_NAME.app" ./$BUILD_DIR/Applications
for file in ./output/**/*.storyboardc; do
echo "******** copying ***** ${file}****"
cp -r ${file} ./$BUILD_DIR/Applications/"$PROD_NAME.app"
done

sudo find ./ -name ".DS_Store" -depth -exec rm {} \;

export COPYFILE_DISABLE=true
export COPY_EXTENDED_ATTRIBUTES_DISABLE=true

dpkg-deb -Zgzip -b $BUILD_DIR
mv ./$BUILD_DIR.deb $OUTPUT_DIR$PROD_NAME$VERSION.deb

echo "cleaning '$BUILD_DIR' directory..."
rm -rf $BUILD_DIR
