# 获取描述文件的uuid并将描述文件copy到系统，前提将系统解锁
security unlock-keychain -p 5324nxh0506222     /Users/niuxinghua/Library/Keychains/login.keychain
P12_Path="/Users/niuxinghua/Desktop/ios/证书/cosmoim/证书(haierios).p12"
echo "${P12_Path}"
security import ${P12_Path} -k /Users/niuxinghua/Library/Keychains/login.keychain -P haierios -T /usr/bin/codesign

mobileprovisionName="COSMOIM"
mobileBundleId="com.haier.imapp"
mobileprovision_file="/Users/niuxinghua/Desktop/ios/证书/cosmoim/${mobileprovisionName}.mobileprovision"

# 将描述文件转换成plist
mobileprovision_plist="/Users/niuxinghua/Desktop/whocall/${mobileprovisionName}.plist"
security cms -D -i $mobileprovision_file > $mobileprovision_plist
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


#修改导出Export.plist里面的具体内容
/usr/libexec/PlistBuddy -c "Set teamID $teamID" Export.plist
/usr/libexec/PlistBuddy -c "Add provisioningProfiles:${mobileBundleId} string ${mobileprovisionName}" Export.plist

#导出ipa
xcodebuild  -exportArchive \
-archivePath build/GoHaier.xcarchive \
-exportPath build/GoHaier.ipa \
-exportOptionsPlist  Export.plist\




