require 'xcodeproj'
project_path = File.join(File.dirname(__FILE__), "./GoHaier.xcodeproj")
project = Xcodeproj::Project.open(project_path)

#第一个参数,相对于.xcodeproj 项目根目录,一定要和工程里的根目录名字相同
#第二个参数,相对工程里的目录
mapiGroup = project.main_group.find_subpath(File.join('H5',''), true)#创建工程目录,没有可以创建
mapiGroup.set_source_tree('<group>')
#源,相对于.xcodeproj路径,提供给项目实体文件的路径
mapiGroup.set_path('./H5')

#移除索引
def removeBuildPhaseFilesRecursively(aTarget, aGroup)
aGroup.files.each do |file|
aTarget.resources_build_phase.remove_file_reference(file)
end

aGroup.groups.each do |group|
removeBuildPhaseFilesRecursively(aTarget, group)
end
end

#添加索引
def addFilesToGroup(aTarget, aGroup)
Dir.foreach(aGroup.real_path) do |entry|
filePath = File.join(aGroup.real_path, entry)
# 过滤目录和.DS_Store文件
if entry != ".DS_Store" && !filePath.to_s.end_with?(".meta") &&entry != "." &&entry != ".."then
# 向group中增加文件引用
fileReference = aGroup.new_reference(filePath)
aTarget.resources_build_phase.add_file_reference(fileReference, true)
end
end
end



if !mapiGroup.empty? then
removeBuildPhaseFilesRecursively(project.targets.first,mapiGroup)
mapiGroup.clear()
end


addFilesToGroup(project.targets.first, mapiGroup)
project.save


