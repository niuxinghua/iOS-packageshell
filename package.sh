# 获取描述文件的uuid并将描述文件copy到系统，前提将系统解锁
basepath=$(cd `dirname $0`; pwd)
rm -rf build
rm -f GoHaierProvision.plist
#获取输入变量
#macmini的password  5324nxh050622
ruby projectreference.ruby
macPassword=$1
echo "${macPassword}"

#p12文件的位置 ios.p12
p12Name=$2
P12_Path="p12file/${p12Name}.p12"
echo "${P12_Path}"

p12Password=$3
echo "${p12Password}"
#provision文件的名字 #COSMOIM
mobileprovisionName=$4
echo "${mobileprovisionName}"

# BundleID com.haier.imapp
mobileBundleId=$5
echo "${mobileBundleId}"

bundleName=$6
echo "${bundleName}"

bundleVersion=$7
echo "${bundleVersion}"

isRelease=$8
echo "${isRelease}"

#provisionfile 文件
mobileprovision_file="provisionfile/${mobileprovisionName}.mobileprovision"
echo "${mobileprovision_file}"
security unlock-keychain -p ${macPassword}     ~/Library/Keychains/login.keychain
security import ${P12_Path} -k ~/Library/Keychains/login.keychain -P ${p12Password} -T /usr/bin/codesign



# 将描述文件转换成plist
mobileprovision_plist="GoHaierProvision.plist"
security cms -D -i $mobileprovision_file > $mobileprovision_plist
provision_name=`/usr/libexec/PlistBuddy -c "Print AppIDName" $mobileprovision_plist`
provision_UUID=`/usr/libexec/PlistBuddy -c "Print UUID" $mobileprovision_plist`
developmentTeamName=`/usr/libexec/PlistBuddy -c "Print TeamName" $mobileprovision_plist`
code_sign_identity=`/usr/libexec/PlistBuddy -c 'Print DeveloperCertificates:0' $mobileprovision_plist | \
openssl x509 -subject -inform der|head -n 1`
code_sign=`echo "$code_sign_identity" | cut -d "/" -f3 | cut -d "=" -f2`
teamID=`/usr/libexec/PlistBuddy -c 'Print TeamIdentifier:0' $mobileprovision_plist`
echo "${provision_UUID}"
echo "${developmentTeamName}"
echo "${code_sign}"

cp ${mobileprovision_file} ~/Library/MobileDevice/Provisioning\ Profiles/$provision_UUID.mobileprovision


#修改安装后显示的名字
infoplist="${basepath}/GoHaier/Info.plist"


sudo -S /usr/libexec/PlistBuddy -c "Set 'CFBundleName' $bundleName" $infoplist <<EOF
${macPassword}
EOF

sudo -S /usr/libexec/PlistBuddy -c "Set 'CFBundleShortVersionString' $bundleVersion" $infoplist <<EOF
${macPassword}
EOF

echo "${infoplist}"


#需要将icon进行替换
# 输出icon的目录

icon_path="${basepath}/appIcons"
# 1024 icon 特别处理
icon_1024_path="${icon_path}/icon-1024.png"

icon_asset_path="${basepath}/GoHaier/Assets.xcassets/AppIcon.appiconset"

echo "${icon_1024_path}"
if [ ! -f "$icon_1024_path" ]; then
echo"icon不存在"
else
sips -s format png ${image_path} --out ${icon_1024_path} > /dev/null 2>&1
[ $? -eq 0 ] && echo -e "info:\tresize copy 1024 successfully." || echo -e "info:\tresize copy 1024 failed."

sips -z 1024 1024 ${icon_1024_path} > /dev/null 2>&1
[ $? -eq 0 ] && echo -e "info:\tresize 1024 successfully." || echo -e "info:\tresize 1024 failed."

prev_size_path=${icon_1024_path} #用于复制小图，减少内存消耗
# 需要生成的图标尺寸
icons=(180 167 152 120 87 80 60 58 40)
for size in ${icons[@]}
do
size_path="${icon_path}/icon-${size}.png"
cp ${prev_size_path} ${size_path}
prev_size_path=${size_path}
sips -Z $size ${size_path} > /dev/null 2>&1
[ $? -eq 0 ] && echo -e "info:\tresize ${size} successfully." || echo -e "info:\tresize ${size} failed."
done


contents_json_path="${icon_path}/Contents.json"
# 生成图标对应的配置文件
echo '{
"images" : [
{
"size" : "20x20",
"idiom" : "iphone",
"filename" : "icon-40.png",
"scale" : "2x"
},
{
"size" : "20x20",
"idiom" : "iphone",
"filename" : "icon-60.png",
"scale" : "3x"
},
{
"size" : "29x29",
"idiom" : "iphone",
"filename" : "icon-58.png",
"scale" : "2x"
},
{
"size" : "29x29",
"idiom" : "iphone",
"filename" : "icon-87.png",
"scale" : "3x"
},
{
"size" : "40x40",
"idiom" : "iphone",
"filename" : "icon-80.png",
"scale" : "2x"
},
{
"size" : "40x40",
"idiom" : "iphone",
"filename" : "icon-120.png",
"scale" : "3x"
},
{
"size" : "60x60",
"idiom" : "iphone",
"filename" : "icon-120.png",
"scale" : "2x"
},
{
"size" : "60x60",
"idiom" : "iphone",
"filename" : "icon-180.png",
"scale" : "3x"
},
{
"idiom" : "ipad",
"size" : "20x20",
"scale" : "1x"
},
{
"size" : "20x20",
"idiom" : "ipad",
"filename" : "icon-40.png",
"scale" : "2x"
},
{
"idiom" : "ipad",
"size" : "29x29",
"scale" : "1x"
},
{
"size" : "29x29",
"idiom" : "ipad",
"filename" : "icon-58.png",
"scale" : "2x"
},
{
"idiom" : "ipad",
"size" : "40x40",
"scale" : "1x"
},
{
"size" : "40x40",
"idiom" : "ipad",
"filename" : "icon-80.png",
"scale" : "2x"
},
{
"idiom" : "ipad",
"size" : "76x76",
"scale" : "1x"
},
{
"size" : "76x76",
"idiom" : "ipad",
"filename" : "icon-152.png",
"scale" : "2x"
},
{
"size" : "83.5x83.5",
"idiom" : "ipad",
"filename" : "icon-167.png",
"scale" : "2x"
},
{
"size" : "1024x1024",
"idiom" : "ios-marketing",
"filename" : "icon-1024.png",
"scale" : "1x"
}
],
"info" : {
"version" : 1,
"author" : "xcode"
}
}' > ${contents_json_path}


#将所有的文件copy到xcassets目录下
echo $icon_asset_path
sudo -S rm -rf $icon_asset_path <<EOF
${macPassword}
EOF
sudo -S cp -r $icon_path $icon_asset_path <<EOF
${macPassword}
EOF
#echo "${macPassword}"|sudo rm -rf $icon_asset_path
#echo "${macPassword}"|sudo cp -r $icon_path $icon_asset_path

fi










#开始编译打包
xcodebuild -workspace "GoHaier.xcworkspace" -scheme "GoHaier" -configuration Release -archivePath build/GoHaier.xcarchive clean archive build CODE_SIGN_IDENTITY="${code_sign}" PROVISIONING_PROFILE="${provision_UUID}" PRODUCT_BUNDLE_IDENTIFIER="${mobileBundleId}" -quiet

echo "${buildResult}"


#修改导出Export.plist里面的具体内容
#{app-store, ad-hoc, enterprise, development, validation}

/usr/libexec/PlistBuddy -c "Set teamID $teamID" Export.plist
/usr/libexec/PlistBuddy -c "Delete:provisioningProfiles" Export.plist
/usr/libexec/PlistBuddy -c "Add provisioningProfiles:${mobileBundleId} string ${provision_name}" Export.plist
#默认是先走企业版的证书(集团内大多数应用走这个发版)
if [ "$isRelease"x = "release"x ];then
echo "release"
/usr/libexec/PlistBuddy -c "Set method enterprise" Export.plist
#导出ipa
xcodebuild  -exportArchive \
-archivePath build/GoHaier.xcarchive \
-exportPath build/GoHaier.ipa \
-exportOptionsPlist  Export.plist\

#没打出包来可能是证书不是企业版那么 再d导出一个个人版本的
if [ ! -d build/GoHaier.ipa ];
then
echo "打包appstore版本"
/usr/libexec/PlistBuddy -c "Set method app-store" Export.plist

xcodebuild  -exportArchive \
-archivePath build/GoHaier.xcarchive \
-exportPath build/GoHaier.ipa \
-exportOptionsPlist  Export.plist\

fi
else
#测试版本
echo "打包个人版的adhoc版本"
/usr/libexec/PlistBuddy -c "Set method ad-hoc" Export.plist

xcodebuild  -exportArchive \
-archivePath build/GoHaier.xcarchive \
-exportPath build/GoHaier.ipa \
-exportOptionsPlist  Export.plist\

fi

