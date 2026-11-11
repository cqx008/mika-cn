# Mika CN — 社区特化版（非官方）

基于上游 [wangzan101/Mika](https://github.com/wangzan101/Mika) **v0.1.39**（Apache-2.0）构建的社区特化版本，**非官方发行**。

## Mika 是什么？

Mika 是一款装在**你自己手机上的 AI 助手**：你说要什么，它就帮你在手机 App 和网页里操作，直到做完为止。

核心特性：
- **后台隐形屏幕**：Mika 开一块隐藏屏幕去点击、输入、滚动，你的主屏幕可以继续用
- **不挑 App**：纯视觉识别，不需要 App API 或逐个集成，任何 App 和网站都能用
- **沙箱内执行代码**：每个会话独立跑一个 Linux 沙箱（Python / Node / Shell），arm64 设备可用
- **数据留在本地**：没有 Mika 服务器，用自己的模型 API key，或登录 ChatGPT / xAI / OpenRouter 账号
- **开源免费**：Apache-2.0，所有代码公开

> 详见上游：https://github.com/wangzan101/Mika

## 这个社区版相对官方做了什么

- **国内源三层镜像**：alpine（dl-cdn→阿里→清华）+ pip（清华）+ npm（npmmirror），国内**无需代理**即可安装/更新
- **预烘焙 25 个常用 pip wheel + git + jq**：文档处理/JSON 工具离线开箱即用
- **沙箱脚本默认允许联网**（官方版默认关闭，需在设置里手动开）
- 自签 keystore 签名（非官方签名）

## 下载 APK

| 架构 | 链接 |
|---|---|
| ARM64（手机实机推荐） | https://123.movejianshen.icu/omnibot-assets/mika-0.1.39-arm64-v8a-release.apk |
| Universal（全架构） | https://123.movejianshen.icu/omnibot-assets/mika-0.1.39-universal-release.apk |

> 安装时请允许"未知来源"，签名非官方。官方下载请看上游 Releases：https://github.com/wangzan101/Mika/releases/latest

## 许可证

Apache-2.0。见 [LICENSE](LICENSE) / [NOTICE](NOTICE)。本地改动清单与自检见 [LOCAL-CUSTOM.md](LOCAL-CUSTOM.md)。

## 已向上游贡献

- [PR #486](https://github.com/wangzan101/Mika/pull/486)（国内源 + pip + git/jq）
- [PR #487](https://github.com/wangzan101/Mika/pull/487)（沙箱默认联网，可选行为变更）

## 快速上手（和官方一致）

1. 安装 APK
2. Settings › Model：填一个模型 API key（或登录 ChatGPT/xAI/OpenRouter）
3. Settings › Phone control：跟着向导配对一次无线调试（只需一次）
4. 试一下："帮我设 9:40 和 10:00 两个明早闹钟" 或 "每天早上 8 点查天气，下雨就告诉我"
