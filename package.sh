# 获取描述文件的uuid并将描述文件copy到系统，前提将系统解锁
security unlock-keychain -p 5324nxh0506222     /Users/niuxinghua/Library/Keychains/login.keychain

security import ${P12_Path}.p12 -k /Users/niuxinghua/Library/Keychains/login.keychain -P p12的密码 -T /usr/bin/codesign

mobileprovisionName="COSMOIM"
mobileprovision_file="/Users/niuxinghua/Desktop/ios/证书/cosmoim/${mobileprovisionName}.mobileprovision"

# 将描述文件转换成plist
mobileprovision_plist="/Users/niuxinghua/Desktop/whocall/${mobileprovisionName}.plist"
security cms -D -i $mobileprovision_file > $mobileprovision_plist
provision_UUID=`/usr/libexec/PlistBuddy -c "Print UUID" $mobileprovision_plist`
echo "${provision_UUID}"

cp ${mobileprovision_file} ~/Library/MobileDevice/Provisioning\ Profiles/$provision_UUID.mobileprovision


