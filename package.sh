#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 版本号
VERSION="1.0.0"

# 创建临时目录
echo -e "${YELLOW}[*] 创建临时目录...${NC}"
rm -rf packages
mkdir -p packages

# 构建有根版本
echo -e "${YELLOW}[*] 构建有根版本...${NC}"
make clean
make package FINALPACKAGE=1
if [ $? -eq 0 ]; then
    mv packages/*.deb packages/RedBookPure_${VERSION}_rootful.deb
    echo -e "${GREEN}[+] 有根版本构建成功${NC}"
else
    echo -e "${RED}[-] 有根版本构建失败${NC}"
    exit 1
fi

# 构建无根版本
echo -e "${YELLOW}[*] 构建无根版本...${NC}"
make clean
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless
if [ $? -eq 0 ]; then
    mv packages/*.deb packages/RedBookPure_${VERSION}_rootless.deb
    echo -e "${GREEN}[+] 无根版本构建成功${NC}"
else
    echo -e "${RED}[-] 无根版本构建失败${NC}"
    exit 1
fi

# 清理
make clean

echo -e "${GREEN}[+] 打包完成！${NC}"
echo -e "${YELLOW}[*] 插件包位置: packages/RedBookPure_${VERSION}_rootful.deb${NC}"
echo -e "${YELLOW}[*] 插件包位置: packages/RedBookPure_${VERSION}_rootless.deb${NC}" 