# GFWList2PAC

[![License](https://img.shields.io/badge/License-Apache%202.0--Commons%20Clause-blue)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)](https://www.python.org/)

一个自动化工具，用于从域名列表生成多种格式的代理自动配置（PAC）文件。支持主流代理客户端，包括 Clash、Shadowrocket、Surge、Quantumult、v2rayA 和 v2rayN。

工程契约见 [AGENTS.md](AGENTS.md)。
## 项目简介

**GFWList2PAC** 是一个基于 Python 的自动化工具，用于：

- 自动获取 CNACC（中国可访问域名白名单）和 GFWList（被墙域名黑名单）数据
- 处理和分析域名数据
- 生成 8 种不同格式的代理配置文件
- 每 3 小时自动更新一次（每日运行）

### 支持的格式

本项目为以下代理客户端生成配置文件：

| 客户端            | 格式            | 文件名模式                         |
| ----------------- | --------------- | ---------------------------------- |
| **AutoProxy**     | Base64 编码文本 | `dist/<模式>/autoproxy.txt`      |
| **Clash**         | YAML 规则集     | `dist/<模式>/clash.yaml`         |
| **Clash Premium** | YAML 域名集     | `dist/<模式>/clash_premium.yaml` |
| **Shadowrocket**  | 配置文件        | `dist/<模式>/shadowrocket.conf`  |
| **Surge**         | YAML 规则       | `dist/<模式>/surge.yaml`         |
| **Quantumult**    | YAML 规则       | `dist/<模式>/quantumult.yaml`    |
| **v2rayA**        | 聚合域名规则    | `dist/<模式>/v2raya.txt`         |
| **v2rayN**        | 域名列表        | `dist/<模式>/v2rayn.txt`         |

每种格式都提供两个版本：

- **CNACC** (白名单)：中国可访问域名 → 直连
- **GFWList** (黑名单)：被墙域名 → 代理

## 快速开始

### 方法一：使用预生成的文件

直接从本仓库下载已生成的配置文件：

| 格式 | CNACC（国内 → 直连） | GFWList（被墙 → 代理） |
| ---- | -------------------- | ---------------------- |
| AutoProxy | [txt](dist/cnacc/autoproxy.txt) | [txt](dist/gfwlist/autoproxy.txt) |
| Clash | [yaml](dist/cnacc/clash.yaml) | [yaml](dist/gfwlist/clash.yaml) |
| Clash Premium | [yaml](dist/cnacc/clash_premium.yaml) | [yaml](dist/gfwlist/clash_premium.yaml) |
| Quantumult | [yaml](dist/cnacc/quantumult.yaml) | [yaml](dist/gfwlist/quantumult.yaml) |
| Shadowrocket | [conf](dist/cnacc/shadowrocket.conf) | [conf](dist/gfwlist/shadowrocket.conf) |
| Surge | [yaml](dist/cnacc/surge.yaml) | [yaml](dist/gfwlist/surge.yaml) |
| v2rayA | [txt](dist/cnacc/v2raya.txt) | [txt](dist/gfwlist/v2raya.txt) |
| v2rayN | [txt](dist/cnacc/v2rayn.txt) | [txt](dist/gfwlist/v2rayn.txt) |

### 方法二：本地构建

克隆仓库并运行构建脚本：

```bash
# 克隆仓库
git clone https://github.com/hezhijie0327/GFWList2PAC.git

# 进入目录并运行脚本
cd GFWList2PAC
python3 build.py
```

**系统要求：**

- Python 3.9+（仅标准库，无第三方依赖）
- 网络访问（拉取上游域名列表）

跨平台：Linux / macOS / Windows 均可运行。

## 文件说明

### 生成的文件

运行 `build.py` 后，将生成 16 个配置文件，按模式分目录：

```text
dist/cnacc/                # 中国可访问域名 → 直连
├── autoproxy.txt          # AutoProxy 格式（Base64）
├── clash.yaml             # Clash 规则
├── clash_premium.yaml     # Clash Premium 规则
├── quantumult.yaml        # Quantumult 规则
├── shadowrocket.conf      # Shadowrocket 配置
├── surge.yaml             # Surge 规则
├── v2raya.txt             # v2rayA 规则
└── v2rayn.txt             # v2rayN 规则

dist/gfwlist/              # 被墙域名 → 代理
└── （同上 8 个文件）
```

### 文件大小参考

- **CNACC 文件**：约 2-4 MB（包含 ~117,000 个域名）
- **GFWList 文件**：约 0.7-1.2 MB（包含 ~34,000 个域名）

## 使用方法

### Clash / Clash Premium

在 Clash 配置文件中引用规则集：

```yaml
rule-providers:
  gfwlist:
    type: http
    behavior: domain
    url: https://raw.githubusercontent.com/hezhijie0327/GFWList2PAC/main/dist/gfwlist/clash.yaml
    path: ./ruleset/gfwlist.yaml
    interval: 10800 # 3 小时更新一次

rules:
  - RULE-SET,gfwlist,PROXY
```

### Shadowrocket

1. 打开 Shadowrocket
2. 配置 → 编辑配置文件
3. 粘贴远程配置 URL：
   ```
   https://raw.githubusercontent.com/hezhijie0327/GFWList2PAC/main/dist/gfwlist/shadowrocket.conf
   ```

### Surge

在 Surge 配置中添加规则集：

```ini
[Rule]
RULE-SET,https://raw.githubusercontent.com/hezhijie0327/GFWList2PAC/main/dist/gfwlist/surge.yaml,PROXY
```

### v2rayN

1. 设置 → 路由设置
2. 导入自定义规则文件：
   ```
   https://raw.githubusercontent.com/hezhijie0327/GFWList2PAC/main/dist/gfwlist/v2rayn.txt
   ```

### v2rayA

在 v2rayA 中使用聚合规则格式：

```
domain(google.com,youtube.com,...)->proxy
```

## License

[Apache License 2.0 with Commons Clause v1.0](LICENSE)
