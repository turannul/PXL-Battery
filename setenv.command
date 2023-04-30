#!/bin/bash

SDK_URL="https://www.dropbox.com/s/jvonok3de24ibsz/14.1.zip"
H1=("SparkColourPickerView.h")
H2=("SparkColourPickerUtils.h")
L1=("libsparkcolourpicker.dylib")

printf "\033[32m ==> \033[0m Hello this is setup required stuff to compile PXL\n\033[32m ==> \033[0m Please wait while we are setting up your environment\n"

theoschk(){
    if [[ -d "$THEOS" ]]; then
         printf "\033[32m ==> \033[0m THEOS is already installed at $THEOS\n"
    else 
        printf "\033[31m ==> It seems like THEOS is not installed or its installation path is incorrect."
        printf "\033[33m ==> Please follow the instructions at https://theos.dev/docs/installation to install it properly."
        exit 98
    fi 
}

wgetchk(){
    if ! command -v wget &> /dev/null; then
         printf "\033[33m ==> \033[0m Installing wget\n"
        if [[ "$(uname)" == "Linux" ]]; then
            sudo apt-get update && sudo apt-get install wget -y
        elif [[ "$(uname)" == "Darwin" ]]; then
            brew install wget
        else
            printf "\033[31m ==> \033[0m Error: Unsupported operating system."
            exit 99
        fi
    else
         printf "\033[32m ==> \033[0m wget is already installed.\n"
    fi
}

sdkchk(){
    if ! test -e "$THEOS/sdks/14.1.zip"; then
        printf "\033[33m ==> \033[0m Downloading and installing 14.1 SDK\n" && wget "$SDK_URL" -O $THEOS/sdks/14.1.zip > /dev/null 2>&1 && unzip -q $THEOS/sdks/14.1.zip -d $THEOS/sdks/  && rm $THEOS/sdks/14.1.zip 2>&1 && printf "\033[32m ==> \033[0m SDK successfully installed\n" || printf "\n\033[31m ==> \033[0m Oops! something goes wrong."
    else
        printf "\033[32m ==> \033[0m 14.1 SDK is already installed\n"
    fi
}

viewchk(){
    if ! test -e "$THEOS/include/$H1"; then
        printf "\033[33m ==> \033[0m Downloading and installing Spark Colour Picker Header [1/2]\n" && wget https://raw.githubusercontent.com/SparkDev97/libSparkColourPicker/master/headers/SparkColourPickerView.h -O $THEOS/include/SparkColourPickerView.h > /dev/null 2>&1 && printf "\n\033[32m ==> \033[0m Spark Colour Picker Header [1/2] successfully installed\n" || printf "\n\033[31m ==> \033[0m Oops!! something goes wrong."
    else
        printf "\033[32m ==> \033[0m $H1 is already installed\n"
    fi
}

utilschk(){
  if ! test -e "$THEOS/include/$H2"; then
        printf "\033[33m ==> \033[0m Downloading and installing Spark Colour Picker Header [2/2]\n" && wget https://raw.githubusercontent.com/SparkDev97/libSparkColourPicker/master/headers/SparkColourPickerUtils.h -O $THEOS/include/SparkColourPickerUtils.h > /dev/null 2>&1 && printf "\n\033[32m ==> \033[0m Spark Colour Picker Header [2/2] successfully installed\n" || printf "\n\033[31m ==> \033[0m Oops!! something goes wrong."
    else
        printf "\033[32m ==> \033[0m $H2 is already installed\n"
  fi
}

pickerchk(){
    if ! test -e "$THEOS/lib/$L1";then
        printf "\033[33m ==> \033[0m Downloading and installing SparkColourPicker Library\n" && wget https://raw.githubusercontent.com/SparkDev97/libSparkColourPicker/master/lib/libsparkcolourpicker.dylib -O $THEOS/lib/libsparkcolourpicker.dylib > /dev/null 2>&1 && chmod 755 $THEOS/lib/libsparkcolourpicker.dylib && printf "\n\033[32m ==> \033[0m Spark Colour Picker Library successfully installed\n" || printf "\n\033[31m ==> \033[0m Oops!! something goes wrong."
    else
        printf "\033[32m ==> \033[0m $L1 already installed\n"
    fi
}
theoschk
wgetchk
sdkchk
viewchk
utilschk
pickerchk
printf "\033[32m ==> \033[0m All done! You can now compile PXL :)\n"

read -p "Compile now? [y/n]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    make clean package
else
    printf "\033[33m ==> \033[0m use 'make clean package' when you want to."
fi
