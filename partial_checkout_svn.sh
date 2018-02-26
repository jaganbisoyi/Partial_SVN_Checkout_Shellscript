!Partial checkout from a text file e.g. revfile.txt with reviion IDs and update site.xml to create an updatesite

svn checkout https://<svn branch location>/com.XXX.yyy.zzz.root --depth files
svn update com.XXX.yyy.zzz.root/.mvn
svn update --set-depth infinity com.XXX.yyy.zzz.root/releng
sed -i '/.*module>'$'/ d' com.XXX.yyy.zzz.root/pom.xml
updatesitexmlpath=com.XXX.yyy.zzz.root/releng/com.XXX.yyy.zzz.updatesite/site.xml
ecufeaturestring="\<feature url=\"features/com.XXX.yyy.zzz.ecuc.feature_0.0.0.jar\" id=\"com.XXX.yyy.zzz.ecuc.feature\" version=\"0.0.0\"\>\<category name=\"bsw_bundles\"\/\> \<\/feature\>"
sed -i '/.*feature>'$'/ d' "$updatesitexmlpath"
sed -i '/<feature.*'$'/ d' "$updatesitexmlpath"
sed -i '/<category\s.*name.*'$'/ d' "$updatesitexmlpath"
sed -i "/<site>/a $ecufeaturestring" "$updatesitexmlpath"
declare -a modulelist
declare -a modulepluginfeaturelist
declare -a modulepluginfeaturebundlelist
declare -a featurepluginpathlist
for i in `cat revfile.txt`;do
module="$(cut -d'@' -f1 <<<"$i")";
revisionid="$(cut -d'@' -f2 <<<"$i")";
modulename="$(cut -d'/' -f1 <<<"$module")";
pluginfeature="$(cut -d'/' -f2 <<<"$module")";
pluginfeaturename="$(cut -d'/' -f3 <<<"$module")";
modulelist+=("$modulename")
modulepluginfeaturelist+=("$modulename/$pluginfeature")
modulepluginfeaturebundlelist+=("$modulename/$pluginfeature/$pluginfeaturename@$revisionid")
if [[ "$pluginfeature" = "features" ]]
then
 featurepluginpathlist+=("$module")
fi

done;
uniqmodules=($(printf "%s\n" "${modulelist[@]}" | sort -u))
for each in "${uniqmodules[@]}"; do
svn update --set-depth files com.XXX.yyy.zzz.root/"$each"
sed -i '/.*module>'$'/ d' com.XXX.yyy.zzz.root/"$each"/pom.xml
done;

uniqmodulepluginfeaturelist=($(printf "%s\n" "${modulepluginfeaturelist[@]}" | sort -u))
for each in "${uniqmodulepluginfeaturelist[@]}";do
svn update --set-depth files com.XXX.yyy.zzz.root/"$each"
sed -i '/.*module>'$'/ d' com.XXX.yyy.zzz.root/"$each"/pom.xml
done

uniqmodulepluginfeaturebundlelist=($(printf "%s\n" "${modulepluginfeaturebundlelist[@]}" | sort -u))
for each in "${uniqmodulepluginfeaturebundlelist[@]}";do
plugin="$(cut -d'@' -f1 <<<"$each")"
revisionidl="$(cut -d'@' -f2 <<<"$each")"

svn update --set-depth infinity com.XXX.yyy.zzz.root/"$(cut -d '@' -f1 <<<"$each")" -r$(cut -d '@' -f2 <<<"$each")
done
uniqfeaturepluginpathlist=($(printf "%s\n" "${featurepluginpathlist[@]}" | sort -u))
for each in "${uniqfeaturepluginpathlist[@]}";do
featurestring="$(cut -d'/' -f2 <<<"$each")"
pluginname="$(cut -d'/' -f3 <<<"$each")"
sitefeaturestringl="\<feature url=\""$featurestring/$pluginname"_0.0.0.jar\" id=\""$pluginname"\" version=\"0.0.0\"\>\<category name=\"bsw_bundles\"\/\> \<\/feature\>"

sed -i "/<site>/a $sitefeaturestringl" "$updatesitexmlpath"
done

echo "Updated site.xml"
