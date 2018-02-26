updatepomxml(){
dirname=$1
cd $dirname
echo "directories $dirname"
dirnames=`ls -d */`
for k in $dirnames;do
m=${k%%/}
if [ "$m" == "releng" ]
then
echo "releng $m"
else
echo "modules $k"
sed  -i.bak "/<modules>/a <module>${m}</module>" pom.xml
fi
done;
}
updatepomxml com.kpit.c4k.bsw.root
#echo "PWDos $PWD"
subdirnames=`ls -d */`
for k in $subdirnames;do
echo "subdirectory name $k"
if [ "${k%%/}" == "releng" ]
then 
echo "releng"
else
    cd $k
    updatepomxml $PWD
    dirs2=`ls -d */`
    for m in $dirs2;do
       cd $m
       updatepomxml $PWD;
       cd ..
    done;
    cd ..
fi
done;
#echo $PWD
sed -i.bak "/<modules>/a <module>releng</module>" pom.xml
