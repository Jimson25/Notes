#!/bin/bash
echo "## ==========================================="
echo "## @org csbj-boc-xc"
echo "## @date 2024-06-07"              
echo "## @author jinaosong"
echo "## ==========================================="
echo 
echo 
echo 

CURRENT_PATH=$(pwd)
echo "当前路径为: $CURRENT_PATH"
echo
echo
echo
# 获取参数
repo_type=$1
repo_address=$2

# 检查仓库类型
if [ "$repo_type" != "-l" ] && [ "$repo_type" != "-r" ]; then
    echo "错误的仓库类型参数，-l表示本地仓库，-r表示远程仓库。"
    exit 1
fi

# 克隆或者定位到仓库
if [ "$repo_type" == "-r" ]; then
    git clone $repo_address repo
    cd repo
elif [ "$repo_type" == "-l" ]; then
    cd $repo_address
fi

# 获取仓库名
repo_name=$(basename `git rev-parse --show-toplevel`)

# 列出分支
echo "分支列表："
branches=()
# 获取所有远程分支
all_remote_branches=$(git branch -r)
IFS=$'\n' read -d '' -r -a branches <<< "$(echo "$all_remote_branches" | sed 's/^[^\/]*\///')"
unset IFS

# 打印分支列表及编号
for i in "${!branches[@]}"; do
  echo "$((i+1)). ${branches[$i]}"
done

# 获取用户选择的分支
read -p "请输入你想要使用的分支的序号：" branch_num
branch_name=${branches[$((branch_num-1))]}

# 切换到用户选择的分支
git checkout -b $branch_name

git pull origin $branch_name

sleep 5

# 获取用户输入的两个版本号
read -p "请输入第一个版本号：" version1
read -p "请输入第二个版本号：" version2

# 检查版本号是否存在
if ! git rev-parse $version1 >/dev/null 2>&1 || ! git rev-parse $version2 >/dev/null 2>&1; then
    echo "版本号不存在，请检查输入的版本号。"
    exit 1
fi


# 如果diff.txt文件存在，则清空文件内容
if [ -f diff.txt ]; then
    > diff.txt
fi

# 创建增量文件的目录
mkdir increment_files

# 对比两个版本的差异并保存到txt文件
git diff --name-only $version1 $version2 > increment_files/diff.txt


# 分析差异文件，复制增量文件到目录
while read file_path; do
    cp --parents $file_path increment_files/
done < increment_files/diff.txt

# 获取当前的日期和时间戳
current_date=$(date +%Y%m%d)
current_timestamp=$(date +%s)

# 压缩增量文件到zip包，并使用包含日期和时间戳的名称
zip -r inc_${repo_name}_${current_date}_${current_timestamp}.zip increment_files/

# 移动zip包到脚本所在位置
mv inc_${repo_name}_${current_date}_${current_timestamp}.zip  $CURRENT_PATH/

# 删除增量文件的目录
rm -rf increment_files

echo "增量版本已生成至 $CURRENT_PATH/。"
