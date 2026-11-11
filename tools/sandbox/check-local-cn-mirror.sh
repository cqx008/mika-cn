#!/bin/sh
# check-local-cn-mirror.sh — 本地国内源 + 文档基础包 + git/jq 全量指纹自检（0.1.39 版）
# 官方更新后跑一次：任一指纹缺失说明被冲刷，照 LOCAL-CUSTOM.md 恢复。
cd "$(dirname "$0")/../.." || exit 1
pass=0; fail=0
ok(){ echo "OK  $1"; pass=$((pass+1)); }
no(){ echo "MISS $1"; fail=$((fail+1)); }

f() { grep -q "$1" tools/sandbox/build-runtime.py && ok "$1" || no "$1"; }

echo "=== 国内源三层镜像 ==="
f 'ALPINE_CDN'
f 'ALPINE_MIRROR_CN'
f 'ALPINE_MIRROR_BACKUP'
f 'Mozilla/5.0'
f 'mirrors.aliyun.com'

echo "=== 文档功能基础包（apk 层 WANT）==="
f '"git"'
f '"jq"'
f '"poppler-utils"'
f '"font-wqy-zenhei"'
f '"fontconfig"'
f '"curl"'

echo "=== pip wheel 预烘焙 ==="
f 'PIP_PACKAGES'
f 'preinstall_pip'
f 'reportlab'
f 'python-docx'
f 'openpyxl'
f 'pypi.tuna.tsinghua.edu.cn'

echo "=== npm 镜像 ==="
f 'npmmirror'

echo "=== 代理烘焙（PROXY 非空时）==="
f '99-proxy.sh'

echo "=== core 基准同步 ==="
if grep -q '"git", "jq"' core/src/main/kotlin/com/wangzan101/mika/core/cap/sandbox/SandboxPackages.kt 2>/dev/null; then
  ok "SandboxPackages 含 git/jq"
else
  no "SandboxPackages 缺 git/jq"
fi

echo "=== rootfs 产物版本戳（应与烘焙一致）==="
grep 'VERSION' app/src/main/java/com/wangzan101/mika/cap/sandbox/BundledRuntime.kt | head -1

echo "=== 结果: OK=$pass MISS=$fail ==="
[ "$fail" -eq 0 ] && echo "全部通过" || echo "有缺失，照 LOCAL-CUSTOM.md 恢复"
exit $fail
