set -e
set +x

echo "Build ios start"
now=$(date +"%Y%m%d%H%M")

project_path=$1
archive_root_path=$2
archive_director_name=$3
archive_name=$4
ios_distribute_platform=$5
#没有指定平台，说明不想出产物
if [[ -z ${ios_distribute_platform} ]]; then
  #指定打包所使用的输出方式，目前支持app-store, package, ad-hoc, enterprise, development, 和developer-id，即xcodebuild的method参数
  export_method="enterprise";
else
  export_method=${ios_distribute_platform};
fi

echo "======================================"
echo "project_path = ${project_path}"
echo "archive_root_path = ${archive_root_path}"
echo "archive_director_name = ${archive_director_name}"
echo "archive_name = ${archive_name}"
echo "export_method = ${export_method}"
echo "======================================"

pod repo update
if [[ -f "$project_path/ios/Podfile.lock" ]]; then
	rm "$project_path/ios/Podfile.lock"
fi
flutter clean
flutter pub upgrade
flutter build ios

cd $project_path/ios

# 企业包和appstore使用不同的应用图标
if [[ ${export_method} == "enterprise" ]]; then
    cp -R ${project_path}/deploy/iosenterpriseicons/* ${project_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset
elif [[ ${export_method} == "app-store" ]]; then
    cp -R ${project_path}/deploy/iosappstoreicons/* ${project_path}/ios/Runner/Assets.xcassets/AppIcon.appiconset
fi


#指定项目地址
workspace_path="${project_path}/ios/Runner.xcodeproj"
#指定输出路径
rm -rf "${archive_root_path}/ios/"
rm -rf "${project_path}/outputs/symbol/ios"
mkdir -p "${archive_root_path}/ios/${archive_director_name}"
mkdir -p "${project_path}/outputs/symbol/ios"
output_path_app="${archive_root_path}/ios/${archive_director_name}"
output_path_symbol="${project_path}/outputs/symbol/ios"

#指定输出归档文件地址
archive_path="$output_path_symbol/meeting_mobile_${export_method}_${now}.xcarchive"
archive_zip_path="$output_path_app/meeting_mobile_${export_method}_${now}.xcarchive.zip"
#指定输出ipa名称
ipa_name="${archive_name}.ipa"
ipa_path="${output_path_app}/${ipa_name}"


#输出设定的变量值
echo "===================================== "
echo "workspace path: ${workspace_path}"
echo "archive path: ${archive_path}"
echo "archive zip path: ${archive_zip_path}"
echo "output path: ${output_path_app}"
echo "ipa path: ${ipa_path}"
echo "===================================== "

with_archive=true
if [[ -z ${ios_distribute_platform} ]]; then
  with_archive=false
fi

if [[ ${export_method} == "enterprise" ]]; then
    bundle exec fastlane build_enterprise archive_path:${archive_path} output_directory:${output_path_app} output_name:${ipa_name} with_archive:${with_archive}
elif [[ ${export_method} == "app-store" ]]; then
    bundle exec fastlane build_appstore archive_path:${archive_path} output_directory:${output_path_app} output_name:${ipa_name} with_archive:true
    bundle exec fastlane upload_testflight ipa_path:${ipa_path}
fi

if [[ "${with_archive}" == true ]]; then
  #把xcarchive文件压缩成zip放到ipa的产物路径
  zip -r $archive_zip_path $archive_path
  rm -rf "${project_path}/outputs/symbol"
fi
echo "Build ios done"

set +e
