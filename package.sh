# 获取描述文件的uuid并将描述文件copy到系统，前提将系统解锁
rm -rf build
rm -f GoHaierProvision.plist
basedir=`cd $(dirname $0); pwd -P`
ruby projectreference.ruby
#获取输入变量
#macmini的password  5324nxh050622
macPassword=$1
echo "${macPassword}"

#p12文件的位置 ios.p12
p12Name=$2
P12_Path="p12file/${p12Name}.p12"
echo "${P12_Path}"

#provision文件的名字 #COSMOIM
mobileprovisionName=$3
echo "${mobileprovisionName}"

# BundleID com.haier.imapp
mobileBundleId=$4
echo "${mobileBundleId}"

#provisionfile 文件
mobileprovision_file="provisionfile/${mobileprovisionName}.mobileprovision"
echo "${mobileprovision_file}"

security unlock-keychain -p ${macPassword}     ~/Library/Keychains/login.keychain
security import ${P12_Path} -k ~/Library/Keychains/login.keychain -P haierios -T /usr/bin/codesign



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

#开始编译打包
xcodebuild -workspace "GoHaier.xcworkspace" -scheme "GoHaier" -configuration Release -archivePath build/GoHaier.xcarchive clean archive build CODE_SIGN_IDENTITY="${code_sign}" PROVISIONING_PROFILE="${provision_UUID}" PRODUCT_BUNDLE_IDENTIFIER="${mobileBundleId}"
echo "${buildResult}"


#修改导出Export.plist里面的具体内容
#{app-store, ad-hoc, enterprise, development, validation}

/usr/libexec/PlistBuddy -c "Set teamID $teamID" Export.plist
/usr/libexec/PlistBuddy -c "Delete:provisioningProfiles" Export.plist
/usr/libexec/PlistBuddy -c "Add provisioningProfiles:${mobileBundleId} string ${provision_name}" Export.plist
#默认是先走企业版的证书(集团内大多数应用走这个发版)
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
