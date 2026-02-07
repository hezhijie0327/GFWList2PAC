#!/bin/bash

## How to get and use?
# git clone "https://github.com/hezhijie0327/GFWList2PAC.git" && bash ./GFWList2PAC/release.sh

## Function
# Get Data
function GetData() {
    cnacc_domain=(
        "https://raw.githubusercontent.com/hezhijie0327/GFWList2AGH/main/gfwlist2domain/whitelist_full.txt"
    )
    gfwlist_domain=(
        "https://raw.githubusercontent.com/hezhijie0327/GFWList2AGH/main/gfwlist2domain/blacklist_full.txt"
    )
    rm -rf ./gfwlist2pac_* ./Temp && mkdir ./Temp && cd ./Temp
    for cnacc_domain_task in "${!cnacc_domain[@]}"; do
        curl -s --connect-timeout 15 "${cnacc_domain[$cnacc_domain_task]}" >> ./cnacc_domain.tmp
    done
    for gfwlist_domain_task in "${!gfwlist_domain[@]}"; do
        curl -s --connect-timeout 15 "${gfwlist_domain[$gfwlist_domain_task]}" >> ./gfwlist_domain.tmp
    done
}
# Analyse Data
function AnalyseData() {
    cnacc_data=($(cat ./cnacc_domain.tmp | awk "{ print $2 }"))
    gfwlist_data=($(cat ./gfwlist_domain.tmp | awk "{ print $2 }"))
}
# Generate Header Information
function GenerateHeaderInformation() {
    gfwlist2pac_checksum=$(date "+%s" | base64)
    gfwlist2pac_expires="3 hours (update frequency)"
    gfwlist2pac_homepage="https://github.com/hezhijie0327/GFWList2PAC"
    gfwlist2pac_timeupdated=$(date -d @$(echo "${gfwlist2pac_checksum}" | base64 -d) "+%Y-%m-%dT%H:%M:%S%:z")
    gfwlist2pac_title=$(if [ "${cnacc_gfwlist}" == "cnacc" ]; then echo "Zhijie's CNACCList"; elif [ "${cnacc_gfwlist}" == "gfwlist" ]; then echo "Zhijie's GFWList"; else exit 1; fi)
    gfwlist2pac_version=$(curl -s --connect-timeout 15 "https://raw.githubusercontent.com/hezhijie0327/GFWList2PAC/source/release.sh" | grep "Current\ Version" | sed "s/\#\ Current\ Version\:\ //g")-$(date -d @$(echo "${gfwlist2pac_checksum}" | base64 -d) "+%Y%m%d")-$((10#$(date -d @$(echo "${gfwlist2pac_checksum}" | base64 -d) "+%H") / 3))
    function gfwlist2pac_autoproxy() {
        echo "[AutoProxy 0.2.9]" > ../gfwlist2pac_${cnacc_gfwlist}_autoproxy.txt
        echo "! Checksum: ${gfwlist2pac_checksum}" >> ../gfwlist2pac_${cnacc_gfwlist}_autoproxy.txt
        echo "! Title: ${gfwlist2pac_title} for Auto Proxy" >> ../gfwlist2pac_${cnacc_gfwlist}_autoproxy.txt
        echo "! Version: ${gfwlist2pac_version}" >> ../gfwlist2pac_${cnacc_gfwlist}_autoproxy.txt
        echo "! TimeUpdated: ${gfwlist2pac_timeupdated}" >> ../gfwlist2pac_${cnacc_gfwlist}_autoproxy.txt
        echo "! Expires: ${gfwlist2pac_expires}" >> ../gfwlist2pac_${cnacc_gfwlist}_autoproxy.txt
        echo "! Homepage: ${gfwlist2pac_homepage}" >> ../gfwlist2pac_${cnacc_gfwlist}_autoproxy.txt
    }
    function gfwlist2pac_clash() {
        echo "payload:" > ../gfwlist2pac_${cnacc_gfwlist}_clash.yaml
        echo "# Checksum: ${gfwlist2pac_checksum}" >> ../gfwlist2pac_${cnacc_gfwlist}_clash.yaml
        echo "# Title: ${gfwlist2pac_title} for Clash" >> ../gfwlist2pac_${cnacc_gfwlist}_clash.yaml
        echo "# Version: ${gfwlist2pac_version}" >> ../gfwlist2pac_${cnacc_gfwlist}_clash.yaml
        echo "# TimeUpdated: ${gfwlist2pac_timeupdated}" >> ../gfwlist2pac_${cnacc_gfwlist}_clash.yaml
        echo "# Expires: ${gfwlist2pac_expires}" >> ../gfwlist2pac_${cnacc_gfwlist}_clash.yaml
        echo "# Homepage: ${gfwlist2pac_homepage}" >> ../gfwlist2pac_${cnacc_gfwlist}_clash.yaml
    }
    function gfwlist2pac_clash_premium() {
        echo "payload:" > ../gfwlist2pac_${cnacc_gfwlist}_clash_premium.yaml
        echo "# Checksum: ${gfwlist2pac_checksum}" >> ../gfwlist2pac_${cnacc_gfwlist}_clash_premium.yaml
        echo "# Title: ${gfwlist2pac_title} for Clash Premium" >> ../gfwlist2pac_${cnacc_gfwlist}_clash_premium.yaml
        echo "# Version: ${gfwlist2pac_version}" >> ../gfwlist2pac_${cnacc_gfwlist}_clash_premium.yaml
        echo "# TimeUpdated: ${gfwlist2pac_timeupdated}" >> ../gfwlist2pac_${cnacc_gfwlist}_clash_premium.yaml
        echo "# Expires: ${gfwlist2pac_expires}" >> ../gfwlist2pac_${cnacc_gfwlist}_clash_premium.yaml
        echo "# Homepage: ${gfwlist2pac_homepage}" >> ../gfwlist2pac_${cnacc_gfwlist}_clash_premium.yaml
    }
    function gfwlist2pac_shadowrocket() {
        echo "# Checksum: ${gfwlist2pac_checksum}" > ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
        echo "# Title: ${gfwlist2pac_title} for Shadowrocket" >> ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
        echo "# Version: ${gfwlist2pac_version}" >> ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
        echo "# TimeUpdated: ${gfwlist2pac_timeupdated}" >> ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
        echo "# Expires: ${gfwlist2pac_expires}" >> ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
        echo "# Homepage: ${gfwlist2pac_homepage}" >> ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
        echo "[General]" >> ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
        echo "bypass-system = true" >> ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
        echo "bypass-tun = 10.0.0.0/8, 127.0.0.0/8, 169.254.0.0/16, 172.16.0.0/12, 192.0.0.0/24, 192.0.2.0/24, 192.88.99.0/24, 192.168.0.0/16, 198.18.0.0/15, 198.51.100.0/24, 203.0.113.0/24, 224.0.0.0/4, 240.0.0.0/4, 255.255.255.255/32" >> ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
        echo "dns-server = https://dns.alidns.com/dns-query, https://doh.pub/dns-query" >> ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
        echo "ipv6 = true" >> ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
        echo "skip-proxy = 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, localhost, *.local" >> ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
        echo "[Rule]" >> ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
    }
    function gfwlist2pac_surge() {
        echo "# Checksum: ${gfwlist2pac_checksum}" > ../gfwlist2pac_${cnacc_gfwlist}_surge.yaml
        echo "# Title: ${gfwlist2pac_title} for Surge" >> ../gfwlist2pac_${cnacc_gfwlist}_surge.yaml
        echo "# Version: ${gfwlist2pac_version}" >> ../gfwlist2pac_${cnacc_gfwlist}_surge.yaml
        echo "# TimeUpdated: ${gfwlist2pac_timeupdated}" >> ../gfwlist2pac_${cnacc_gfwlist}_surge.yaml
        echo "# Expires: ${gfwlist2pac_expires}" >> ../gfwlist2pac_${cnacc_gfwlist}_surge.yaml
        echo "# Homepage: ${gfwlist2pac_homepage}" >> ../gfwlist2pac_${cnacc_gfwlist}_surge.yaml
    }
    function gfwlist2pac_quantumult() {
        echo "# Checksum: ${gfwlist2pac_checksum}" > ../gfwlist2pac_${cnacc_gfwlist}_quantumult.yaml
        echo "# Title: ${gfwlist2pac_title} for Quantumult" >> ../gfwlist2pac_${cnacc_gfwlist}_quantumult.yaml
        echo "# Version: ${gfwlist2pac_version}" >> ../gfwlist2pac_${cnacc_gfwlist}_quantumult.yaml
        echo "# TimeUpdated: ${gfwlist2pac_timeupdated}" >> ../gfwlist2pac_${cnacc_gfwlist}_quantumult.yaml
        echo "# Expires: ${gfwlist2pac_expires}" >> ../gfwlist2pac_${cnacc_gfwlist}_quantumult.yaml
        echo "# Homepage: ${gfwlist2pac_homepage}" >> ../gfwlist2pac_${cnacc_gfwlist}_quantumult.yaml
    }
    function gfwlist2pac_v2raya() {
        echo "# Checksum: ${gfwlist2pac_checksum}" > ../gfwlist2pac_${cnacc_gfwlist}_v2raya.txt
        echo "# Title: ${gfwlist2pac_title} for v2rayA" >> ../gfwlist2pac_${cnacc_gfwlist}_v2raya.txt
        echo "# Version: ${gfwlist2pac_version}" >> ../gfwlist2pac_${cnacc_gfwlist}_v2raya.txt
        echo "# TimeUpdated: ${gfwlist2pac_timeupdated}" >> ../gfwlist2pac_${cnacc_gfwlist}_v2raya.txt
        echo "# Expires: ${gfwlist2pac_expires}" >> ../gfwlist2pac_${cnacc_gfwlist}_v2raya.txt
        echo "# Homepage: ${gfwlist2pac_homepage}" >> ../gfwlist2pac_${cnacc_gfwlist}_v2raya.txt
        echo -n "domain(" >> ../gfwlist2pac_${cnacc_gfwlist}_v2raya.txt
    }
    function gfwlist2pac_v2rayn() {
        echo "# Checksum: ${gfwlist2pac_checksum}" > ../gfwlist2pac_${cnacc_gfwlist}_v2rayn.txt
        echo "# Title: ${gfwlist2pac_title} for v2rayN" >> ../gfwlist2pac_${cnacc_gfwlist}_v2rayn.txt
        echo "# Version: ${gfwlist2pac_version}" >> ../gfwlist2pac_${cnacc_gfwlist}_v2rayn.txt
        echo "# TimeUpdated: ${gfwlist2pac_timeupdated}" >> ../gfwlist2pac_${cnacc_gfwlist}_v2rayn.txt
        echo "# Expires: ${gfwlist2pac_expires}" >> ../gfwlist2pac_${cnacc_gfwlist}_v2rayn.txt
        echo "# Homepage: ${gfwlist2pac_homepage}" >> ../gfwlist2pac_${cnacc_gfwlist}_v2rayn.txt
    }
    gfwlist2pac_autoproxy
    gfwlist2pac_clash
    gfwlist2pac_clash_premium
    gfwlist2pac_shadowrocket
    gfwlist2pac_surge
    gfwlist2pac_quantumult
    gfwlist2pac_v2raya
    gfwlist2pac_v2rayn
}
# Generate Footer Information
function GenerateFooterInformation() {
    function gfwlist2pac_shadowrocket() {
        echo "FINAL,DIRECT" >> ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
    }
    function gfwlist2pac_v2raya() {
        if [ "${cnacc_gfwlist}" == "cnacc" ]; then
            echo -n ")->direct" >> ../gfwlist2pac_${cnacc_gfwlist}_v2raya.txt
        else
            echo -n ")->proxy" >> ../gfwlist2pac_${cnacc_gfwlist}_v2raya.txt
        fi
        sed -i 's/,)/)/g' "../gfwlist2pac_${cnacc_gfwlist}_v2raya.txt"
    }
    gfwlist2pac_shadowrocket
    gfwlist2pac_v2raya
}
# Encode Data
function EncodeData() {
    function gfwlist2pac_autoproxy() {
        cat ../gfwlist2pac_${cnacc_gfwlist}_autoproxy.txt | base64 > ../gfwlist2pac_${cnacc_gfwlist}_autoproxy.base64
        mv ../gfwlist2pac_${cnacc_gfwlist}_autoproxy.base64 ../gfwlist2pac_${cnacc_gfwlist}_autoproxy.txt
    }
    gfwlist2pac_autoproxy
}
# Output Data
function OutputData() {
    cnacc_gfwlist="cnacc" && GenerateHeaderInformation
    for cnacc_data_task in "${!cnacc_data[@]}"; do
        echo "@@||${cnacc_data[cnacc_data_task]}^" >> ../gfwlist2pac_${cnacc_gfwlist}_autoproxy.txt
        echo "  - DOMAIN-SUFFIX,${cnacc_data[cnacc_data_task]}" >> ../gfwlist2pac_${cnacc_gfwlist}_clash.yaml
        echo "  - '+.${cnacc_data[cnacc_data_task]}'" >> ../gfwlist2pac_${cnacc_gfwlist}_clash_premium.yaml
        echo "DOMAIN-SUFFIX,${cnacc_data[cnacc_data_task]},DIRECT" >> ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
        echo "DOMAIN-SUFFIX,${cnacc_data[cnacc_data_task]},DIRECT" >> ../gfwlist2pac_${cnacc_gfwlist}_surge.yaml
        echo "DOMAIN-SUFFIX,${cnacc_data[cnacc_data_task]},DIRECT" >> ../gfwlist2pac_${cnacc_gfwlist}_quantumult.yaml
        echo -n "domain:${cnacc_data[cnacc_data_task]}," >> ../gfwlist2pac_${cnacc_gfwlist}_v2raya.txt
        echo "domain:${cnacc_data[cnacc_data_task]}," >> ../gfwlist2pac_${cnacc_gfwlist}_v2rayn.txt
    done
    GenerateFooterInformation && EncodeData
    cnacc_gfwlist="gfwlist" && GenerateHeaderInformation
    for gfwlist_data_task in "${!gfwlist_data[@]}"; do
        echo "||${gfwlist_data[gfwlist_data_task]}^" >> ../gfwlist2pac_${cnacc_gfwlist}_autoproxy.txt
        echo "  - DOMAIN-SUFFIX,${gfwlist_data[gfwlist_data_task]}" >> ../gfwlist2pac_${cnacc_gfwlist}_clash.yaml
        echo "  - '+.${gfwlist_data[gfwlist_data_task]}'" >> ../gfwlist2pac_${cnacc_gfwlist}_clash_premium.yaml
        echo "DOMAIN-SUFFIX,${gfwlist_data[gfwlist_data_task]},PROXY" >> ../gfwlist2pac_${cnacc_gfwlist}_shadowrocket.conf
        echo "DOMAIN-SUFFIX,${gfwlist_data[gfwlist_data_task]},PROXY" >> ../gfwlist2pac_${cnacc_gfwlist}_surge.yaml
        echo "DOMAIN-SUFFIX,${gfwlist_data[gfwlist_data_task]},PROXY" >> ../gfwlist2pac_${cnacc_gfwlist}_quantumult.yaml
        echo -n "domain:${gfwlist_data[gfwlist_data_task]}," >> ../gfwlist2pac_${cnacc_gfwlist}_v2raya.txt
        echo "domain:${gfwlist_data[gfwlist_data_task]}," >> ../gfwlist2pac_${cnacc_gfwlist}_v2rayn.txt
    done
    GenerateFooterInformation && EncodeData
    cd .. && rm -rf ./Temp
    exit 0
}
## Process
# Call GetData
GetData
# Call AnalyseData
AnalyseData
# Call OutputData
OutputData
