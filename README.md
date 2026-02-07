# GFWList2PAC

一个自动化工具，用于从域名列表生成多种格式的代理自动配置（PAC）文件。支持主流代理客户端，包括 Clash、Shadowrocket、Surge、Quantumult、v2rayA 和 v2rayN。

## 📋 项目简介

**GFWList2PAC** 是一个基于 Bash 的自动化脚本，用于：

- 📥 自动获取 CNACC（中国可访问域名白名单）和 GFWList（被墙域名黑名单）数据
- 🔄 处理和分析域名数据
- 📦 生成 8 种不同格式的代理配置文件
- ⏰ 每 3 小时自动更新一次（每日运行）

### 支持的格式

本项目为以下代理客户端生成配置文件：

| 客户端            | 格式            | 文件名模式                         |
| ----------------- | --------------- | ---------------------------------- |
| **AutoProxy**     | Base64 编码文本 | `gfwlist2pac_*_autoproxy.txt`      |
| **Clash**         | YAML 规则集     | `gfwlist2pac_*_clash.yaml`         |
| **Clash Premium** | YAML 域名集     | `gfwlist2pac_*_clash_premium.yaml` |
| **Shadowrocket**  | 配置文件        | `gfwlist2pac_*_shadowrocket.conf`  |
| **Surge**         | YAML 规则       | `gfwlist2pac_*_surge.yaml`         |
| **Quantumult**    | YAML 规则       | `gfwlist2pac_*_quantumult.yaml`    |
| **v2rayA**        | 聚合域名规则    | `gfwlist2pac_*_v2raya.txt`         |
| **v2rayN**        | 域名列表        | `gfwlist2pac_*_v2rayn.txt`         |

每种格式都提供两个版本：

- **CNACC** (白名单)：中国可访问域名 → 直连
- **GFWList** (黑名单)：被墙域名 → 代理

## 🚀 快速开始

### 方法一：使用预生成的文件

直接从本仓库下载已生成的配置文件：

```bash
# 下载 Clash 格式的 GFWList
wget https://raw.githubusercontent.com/hezhijie0327/GFWList2PAC/source/gfwlist2pac_gfwlist_clash.yaml

# 下载 Shadowrocket 格式的 CNACC
wget https://raw.githubusercontent.com/hezhijie0327/GFWList2PAC/source/gfwlist2pac_cnacc_shadowrocket.conf
```

### 方法二：本地构建

克隆仓库并运行构建脚本：

```bash
# 克隆仓库
git clone https://github.com/hezhijie0327/GFWList2PAC.git

# 进入目录并运行脚本
cd GFWList2PAC
bash release.sh
```

**系统要求：**

- Bash 4.0+
- curl (支持 HTTPS)
- awk (gawk 或 mawk)
- base64
- GNU date
- sed

**注意：** 脚本使用 GNU `date` 语法，在 macOS/BSD 系统上可能需要修改。

## 📁 文件说明

### 生成的文件

运行 `release.sh` 后，将生成 16 个配置文件：

```
gfwlist2pac_cnacc_autoproxy.txt       # CNACC AutoProxy 格式（Base64）
gfwlist2pac_cnacc_clash.yaml          # CNACC Clash 规则
gfwlist2pac_cnacc_clash_premium.yaml  # CNACC Clash Premium 规则
gfwlist2pac_cnacc_shadowrocket.conf   # CNACC Shadowrocket 配置
gfwlist2pac_cnacc_surge.yaml          # CNACC Surge 规则
gfwlist2pac_cnacc_quantumult.yaml     # CNACC Quantumult 规则
gfwlist2pac_cnacc_v2raya.txt          # CNACC v2rayA 规则
gfwlist2pac_cnacc_v2rayn.txt          # CNACC v2rayN 规则

gfwlist2pac_gfwlist_autoproxy.txt     # GFWList AutoProxy 格式（Base64）
gfwlist2pac_gfwlist_clash.yaml        # GFWList Clash 规则
gfwlist2pac_gfwlist_clash_premium.yaml # GFWList Clash Premium 规则
gfwlist2pac_gfwlist_shadowrocket.conf # GFWList Shadowrocket 配置
gfwlist2pac_gfwlist_surge.yaml        # GFWList Surge 规则
gfwlist2pac_gfwlist_quantumult.yaml   # GFWList Quantumult 规则
gfwlist2pac_gfwlist_v2raya.txt        # GFWList v2rayA 规则
gfwlist2pac_gfwlist_v2rayn.txt        # GFWList v2rayN 规则
```

### 文件大小参考

- **CNACC 文件**：约 2-4 MB（包含 ~117,000 个域名）
- **GFWList 文件**：约 0.7-1.2 MB（包含 ~34,000 个域名）

## 🔧 使用方法

### Clash / Clash Premium

在 Clash 配置文件中引用规则集：

```yaml
rule-providers:
  gfwlist:
    type: http
    behavior: domain
    url: https://raw.githubusercontent.com/hezhijie0327/GFWList2PAC/source/gfwlist2pac_gfwlist_clash.yaml
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
   https://raw.githubusercontent.com/hezhijie0327/GFWList2PAC/source/gfwlist2pac_gfwlist_shadowrocket.conf
   ```

### Surge

在 Surge 配置中添加规则集：

```ini
[Rule]
RULE-SET,https://raw.githubusercontent.com/hezhijie0327/GFWList2PAC/source/gfwlist2pac_gfwlist_surge.yaml,PROXY
```

### v2rayN

1. 设置 → 路由设置
2. 导入自定义规则文件：
   ```
   https://raw.githubusercontent.com/hezhijie0327/GFWList2PAC/source/gfwlist2pac_gfwlist_v2rayn.txt
   ```

### v2rayA

在 v2rayA 中使用聚合规则格式：

```
domain(google.com,youtube.com,...)->proxy
```

## 📄 许可证

本项目采用Apache License 2.0 with Commons Clause v1.0许可证 - 详见[LICENSE](LICENSE)文件
