# Mika CN — 社区特化版（非官方）

基于上游 [wangzan101/Mika](https://github.com/wangzan101/Mika) **v0.1.39**（Apache-2.0）构建的社区特化版本，**非官方发行**。

## 相对官方的改动
- 国内源三层镜像：alpine（dl-cdn→阿里→清华）+ pip（清华）+ npm（npmmirror），国内无需代理即可安装/更新
- 预烘焙 25 个常用 pip wheel + git + jq，离线文档处理开箱即用
- 沙箱脚本默认允许联网（官方版默认关闭）
- 自签 keystore 签名

## 许可证
Apache-2.0。见 [LICENSE](LICENSE) / [NOTICE](NOTICE)。本地改动清单与自检见 [LOCAL-CUSTOM.md](LOCAL-CUSTOM.md)。

## 已向上游贡献
- PR #486（国内源 + pip + git/jq）：https://github.com/wangzan101/Mika/pull/486
- PR #487（沙箱默认联网，可选行为）：https://github.com/wangzan101/Mika/pull/487
