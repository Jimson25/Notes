#!/bin/bash
echo "## ==========================================="
echo "## @org csbj-boc-xc"
echo "## @date 2024-06-07"              
echo "## @author jinaosong"
echo "## ==========================================="
echo 
echo 
echo 
CP=$(pwd)
echo "当前路径为: $CP"
echo
echo
echo
r_t=$1
r_a=$2
if [ "$r_t" != "-l" ] && [ "$r_t" != "-r" ]; then
    echo "错误的仓库类型参数，-l表示本地仓库，-r表示远程仓库。"
    exit 1
fi
if [ "$r_t" == "-r" ]; then
    git clone $r_a repo
    cd repo
elif [ "$r_t" == "-l" ]; then
    cd $r_a
fi
r_n=$(basename `git rev-parse --show-toplevel`)
echo "分支列表："
brs=()
a_r_b=$(git branch -r)
IFS=$'\n' read -d '' -r -a brs <<< "$(echo "$a_r_b" | sed 's/^[^\/]*\///')"
unset IFS
for i in "${!brs[@]}"; do
  echo "$((i+1)). ${brs[$i]}"
done
read -p "请输入你想要使用的分支的序号：" b_n
b_n=${brs[$((b_n-1))]}
git checkout -b $b_n
read -p "请输入第一个版本号：" v1
read -p "请输入第二个版本号：" v2
if ! git rev-parse $v1 >/dev/null 2>&1 || ! git rev-parse $v2 >/dev/null 2>&1; then
    echo "版本号不存在，请检查输入的版本号。"
    exit 1
fi
if [ -f diff.txt ]; then
    > diff.txt
fi
mkd() {
    mkdir -p $1
}
mkd i_f
git diff --name-only $v1 $v2 > i_f/d.txt
while read f_p; do
    cp --parents $f_p i_f/
done < i_f/d.txt
c_d=$(date +%Y%m%d)
c_t=$(date +%s)
zip -r inc_${r_n}_${c_d}_${c_t}.zip i_f/
mv inc_${r_n}_${c_d}_${c_t}.zip $CP/
rm -rf i_f
echo "增量版本已生成至 $CP/。"
