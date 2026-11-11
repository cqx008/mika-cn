# LOCAL-CUSTOM.md — 本地自改清单（勿被官方更新冲刷）

> 位置：仓库根（/data/mika-0.1.39-src）。
> 用途：每次拉官方更新（wangzan101/Mika）后，**逐项核对本清单**——凡是「本地有、上游没有」的指纹消失，说明被冲刷了，照「恢复方法」打回。
> 维护人：本地维护者。最近更新：2026-11-10（0.1.39 全量回灌 + git/jq）。

## 0.1.39 改动摘要（相对官方 0.1.39）

官方 0.1.39 把 `WANT` 收窄到 5 包、删除了 pip 烘焙逻辑（`PIP_PACKAGES` / `preinstall_pip`）。
本地 0.1.37 的扩展（国内源三层镜像 + 文档功能基础包 + pip wheel 预烘焙）在 0.1.39 源码里全丢了。
**策略 B：在 0.1.39 上全量回灌 0.1.37 的全部本地改动，再额外加 git/jq。**

## 恢复流程（官方更新后 30 秒自检）

```bash
cd /data/mika-0.1.39-src
sh tools/sandbox/check-local-cn-mirror.sh   # 国内源 + 文档包 + git/jq 全量指纹自检
```

## 改动 1：tools/sandbox/build-runtime.py（核心）

| # | 改动 | 指纹（grep 用） | 行号 |
|---|---|---|---|
| 1 | 三个源环境变量 | `ALPINE_CDN`（默认 dl-cdn.alpinelinux.org）、`ALPINE_MIRROR_CN`（阿里）、`ALPINE_MIRROR_BACKUP`（清华） | 44-46 |
| 2 | 代理环境变量 | `PROXY = os.environ.get("HTTP_PROXY", ...)`；`_opener` 走 ProxyHandler | 47, 53-58 |
| 3 | 浏览器 UA（躲 403） | `USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"` | 49 |
| 4 | 官方 404 自动 fallback | `fetch()` 内 attempts = [url, MIRROR_CN, MIRROR_BACKUP] | 约 190-230 |
| 5 | /etc/apk/repositories 三层 | 官方 main/community → MIRROR_CN → MIRROR_BACKUP | 约 640 |
| 6 | pip.conf → 清华 pypi | `index-url = https://pypi.tuna.tsinghua.edu.cn/simple` | 约 650 |
| 7 | npmrc → npmmirror | `registry=https://registry.npmmirror.com` | 约 655 |
| 8 | 99-proxy.sh（PROXY 非空时烘焙） | `export HTTP_PROXY="{PROXY}"` + NO_PROXY 白名单 | 约 660 |
| 9 | openssl.exe 候选（Windows） | `C:\Program Files\Git\usr\bin\openssl.exe` | 约 95 |
| 10 | WANT 扩展（17 包） | `WANT = ["python3","nodejs","py3-pillow","py3-pypdf","tzdata","py3-pip","py3-setuptools","py3-wheel","py3-packaging","poppler-utils","font-wqy-zenhei","fontconfig","curl","unzip","zip","git","jq"]` | 65 |
| 11 | PIP_PACKAGES（25 个 pip wheel 预烘焙） | `PIP_PACKAGES = [...]`（reportlab/fpdf2/python-docx/openpyxl/xlsxwriter 等） | 73+ |
| 12 | preinstall_pip 函数 | `def preinstall_pip(tree, epoch)` 下载 aarch64/cp312 wheel 解压到 site-packages | 163+ |
| 13 | 删 EXTERNALLY-MANAGED | `tree.entries.pop("usr/lib/python3.12/EXTERNALLY-MANAGED", None)` | 约 580 |
| 14 | minirootfs 版本升级自动采纳 | minirootfs 版本落后于 index 时用 index 版本覆盖（不再 die） | 约 359 |

**0.1.39 与 0.1.37 的差异：WANT 加了 `"git","jq"`（17 包），其余回灌内容与 0.1.37 一致。**

## 改动 2：core/src/main/kotlin/.../SandboxPackages.kt

官方 0.1.39 只有 5 包基准。本地扩到 17 包（含 git/jq）：

```kotlin
val SANDBOX_PACKAGES: List<String> = listOf(
    "python3", "nodejs", "py3-pillow", "py3-pypdf", "tzdata",
    "py3-pip", "py3-setuptools", "py3-wheel", "py3-packaging",
    "poppler-utils", "font-wqy-zenhei", "fontconfig",
    "curl", "unzip", "zip", "git", "jq",
)
```

> `BundledRuntimeTest` 用正则 `^WANT = \[(.*)\]`（单行）比对两者，**WANT 必须写成单行**才能过测试。

## 改动 3：生成产物（烘焙物，官方更新不带，必须重生成）

| 产物 | 本地当前值 |
|---|---|
| rootfs.tar.xz | `3.22.8-dd1643cdf9c8`，66269884 bytes，7646 entries，101 apk + 25 pip wheel，含 git 2.49.1-r0 / jq 1.8.2-r0 |
| packages.json | 101 包 |
| BundledRuntime.kt | VERSION `3.22.8-dd1643cdf9c8`，SHA256 `dd1643cdf9c8...`，BYTES 66269884L |

重烘焙命令（8G swap 必须开，防 OOM）：
```bash
cd /data/mika-0.1.39-src
export ALPINE_MIRROR_CN="https://mirrors.aliyun.com/alpine"
export ALPINE_MIRROR_BACKUP="https://mirrors.tuna.tsinghua.edu.cn/alpine"
# 默认直连联网（不设 PROXY → 不烘焙 99-proxy.sh → 沙箱自由联网）
python3 -u tools/sandbox/build-runtime.py
```

## 改动 4：app/build.gradle.kts

```kotlin
signingConfigs {
    release {
        storeFile = File("/data/mika-release-key.jks")
        storePassword = "mika1234"
        keyAlias = "mika"
        keyPassword = "mika1234"
    }
}
// release buildType 用 release signingConfig
versionCode = 39
versionName = "0.1.39"
```

> 官方仓库里此文件没有 signingConfigs 块（官方版用 CI 签名），这是服务器构建适配。

## 沙箱默认联网契约

- **PROXY 为空时烘焙**（默认）→ rootfs 里**无 99-proxy.sh** → 沙箱直连，可自由访问互联网
- 国内包管理源三层兜底：`etc/apk/repositories` = dl-cdn + aliyun + tuna（apk 按序尝试）
- pip → 清华 pypi；npm → npmmirror（`etc/pip/pip.conf` + `.npmrc`）
- 应用层 `AndroidManifest.xml` 声明 `android.permission.INTERNET`
- Kotlin 沙箱层无默认禁网逻辑

## 备注

① 烘焙内存峰值：git 及 C 依赖使 tree 解压峰值 >15G，**必须开 8G swap**（`/data/swapfile`），否则 OOM 杀进程导致产物不落盘。
② 并发烘焙互踩：多个 build-runtime.py 同时跑会抢下载缓存（.part 文件互相覆盖），**一次只跑一个**。
③ 签名：mika-release-key.jks（别名 mika / 密码 mika1234），本地证书 SHA-256 = `35:4C:FF:57:23:D4:69:0B:85:71:24:7D:12:81:FA:06:CB:38:BA:33:19:F0:B9:5B:BB:E9:F6:01:5E:7B:5D:C3`，与官方作者签名不同，须先卸载再装。
