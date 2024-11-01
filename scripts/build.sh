#!/bin/bash

# 编译项目
echo "Building project..."
forge build

# 检查编译是否成功
if [ $? -eq 0 ]; then
    echo "Build completed successfully!"
else
    echo "Build failed."
fi
