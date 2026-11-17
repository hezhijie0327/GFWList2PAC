#!/usr/bin/env python3

## How to get and use?
# git clone "https://github.com/hezhijie0327/GFWList2PAC.git" && python3 ./GFWList2PAC/build.py

# Current Version: 1.0.0

import base64
import re
import time
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
from pathlib import Path
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parent

CNACC_DOMAIN = (
    "https://raw.githubusercontent.com/hezhijie0327/GFWList2AGH/main/dist/domain/whitelist_full.txt",
)
GFWLIST_DOMAIN = (
    "https://raw.githubusercontent.com/hezhijie0327/GFWList2AGH/main/dist/domain/blacklist_full.txt",
)

HOMEPAGE = "https://github.com/hezhijie0327/GFWList2PAC"
EXPIRES = "3 hours (update frequency)"
VERSION_URL = "https://raw.githubusercontent.com/hezhijie0327/GFWList2PAC/main/build.py"

SHADOWROCKET_GENERAL = (
    "[General]",
    "bypass-system = true",
    "bypass-tun = 10.0.0.0/8, 127.0.0.0/8, 169.254.0.0/16, 172.16.0.0/12, 192.0.0.0/24, 192.0.2.0/24, 192.88.99.0/24, 192.168.0.0/16, 198.18.0.0/15, 198.51.100.0/24, 203.0.113.0/24, 224.0.0.0/4, 240.0.0.0/4, 255.255.255.255/32",
    "dns-server = https://dns.alidns.com/dns-query, https://doh.pub/dns-query",
    "ipv6 = true",
    "skip-proxy = 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, localhost, *.local",
    "[Rule]",
)


## Function
# Download one URL, return decoded text (empty string on failure, like curl -s)
def download(url):
    try:
        request = Request(url, headers={"User-Agent": "curl/8"})
        with urlopen(request, timeout=15) as response:
            return response.read().decode("utf-8", errors="replace")
    except OSError:
        return ""


# Get Data
def get_data():
    with ThreadPoolExecutor(max_workers=8) as pool:
        cnacc_raw, gfwlist_raw = pool.map(download, CNACC_DOMAIN + GFWLIST_DOMAIN)
    # awk "{ print $2 }" with an unquoted $2 prints the whole line;
    # bash word splitting drops empty lines
    return [line for line in cnacc_raw.split("\n") if line], [line for line in gfwlist_raw.split("\n") if line]


# Generate Header Information
def generate_header_information(list_name):
    now = time.time()
    checksum = base64.b64encode(f"{int(now)}\n".encode()).decode()
    updated = datetime.fromtimestamp(int(now), tz=timezone.utc)
    timeupdated = updated.strftime("%Y-%m-%dT%H:%M:%S+00:00")
    title = "Zhijie's CNACCList" if list_name == "cnacc" else "Zhijie's GFWList"
    base_version = ""
    match = re.search(r"# Current Version: (.+)", download(VERSION_URL))
    if match:
        base_version = match.group(1).strip()
    version = f"{base_version}-{updated.strftime('%Y%m%d')}-{int(updated.strftime('%H')) // 3}"
    return {
        "checksum": checksum,
        "title": title,
        "version": version,
        "timeupdated": timeupdated,
        "expires": EXPIRES,
        "homepage": HOMEPAGE,
    }


# Render the shared metadata block with the given comment prefix
def metadata(header, comment, suffix):
    return [
        f"{comment} Checksum: {header['checksum']}",
        f"{comment} Title: {header['title']} for {suffix}",
        f"{comment} Version: {header['version']}",
        f"{comment} TimeUpdated: {header['timeupdated']}",
        f"{comment} Expires: {header['expires']}",
        f"{comment} Homepage: {header['homepage']}",
    ]


# Output Data
def output_data(list_name, domains, header):
    action = "DIRECT" if list_name == "cnacc" else "PROXY"
    autoproxy_prefix = "@@" if list_name == "cnacc" else ""
    v2raya_action = "direct" if list_name == "cnacc" else "proxy"
    out_dir = ROOT / "dist" / list_name
    out_dir.mkdir(parents=True, exist_ok=True)

    autoproxy = ["[AutoProxy 0.2.9]"] + metadata(header, "!", "Auto Proxy")
    autoproxy += [f"{autoproxy_prefix}||{domain}^" for domain in domains]
    # encodebytes wraps at 76 columns, like the base64 CLI
    (out_dir / "autoproxy.txt").write_bytes(base64.encodebytes("\n".join(autoproxy).encode() + b"\n"))

    clash = ["payload:"] + metadata(header, "#", "Clash")
    clash += [f"  - DOMAIN-SUFFIX,{domain}" for domain in domains]
    (out_dir / "clash.yaml").write_text("\n".join(clash) + "\n")

    clash_premium = ["payload:"] + metadata(header, "#", "Clash Premium")
    clash_premium += [f"  - '+.{domain}'" for domain in domains]
    (out_dir / "clash_premium.yaml").write_text("\n".join(clash_premium) + "\n")

    shadowrocket = metadata(header, "#", "Shadowrocket") + list(SHADOWROCKET_GENERAL)
    shadowrocket += [f"DOMAIN-SUFFIX,{domain},{action}" for domain in domains]
    shadowrocket.append("FINAL,DIRECT")
    (out_dir / "shadowrocket.conf").write_text("\n".join(shadowrocket) + "\n")

    surge = metadata(header, "#", "Surge")
    surge += [f"DOMAIN-SUFFIX,{domain},{action}" for domain in domains]
    (out_dir / "surge.yaml").write_text("\n".join(surge) + "\n")

    quantumult = metadata(header, "#", "Quantumult")
    quantumult += [f"DOMAIN-SUFFIX,{domain},{action}" for domain in domains]
    (out_dir / "quantumult.yaml").write_text("\n".join(quantumult) + "\n")

    v2raya = metadata(header, "#", "v2rayA")
    v2raya_body = "domain(" + "".join(f"domain:{domain}," for domain in domains) + f")->{v2raya_action}"
    v2raya_body = v2raya_body.replace(",)", ")")
    (out_dir / "v2raya.txt").write_text("\n".join(v2raya) + "\n" + v2raya_body)

    v2rayn = metadata(header, "#", "v2rayN")
    v2rayn += [f"domain:{domain}," for domain in domains]
    (out_dir / "v2rayn.txt").write_text("\n".join(v2rayn) + "\n")


## Process
def main():
    cnacc_data, gfwlist_data = get_data()
    for list_name, domains in (("cnacc", cnacc_data), ("gfwlist", gfwlist_data)):
        header = generate_header_information(list_name)
        output_data(list_name, domains, header)


if __name__ == "__main__":
    main()
