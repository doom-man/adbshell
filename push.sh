read -p "input the remote path " rpath
#echo $rpath
read -p "input the file name " fname
#echo "filename "$fname
echo `find . -name $fname | awk '{ print NR , $1 }' `
read -p "the correct path number " num
# find ./ -name $fname | awk "NR==$num {print $1}" | (read lpath) 
read lpath <<< `find ./ -name $fname | awk "NR==$num {print $1}"`
path=$rpath"/"$lpath
adb push $lpath $path


