#!/bin/bash

# 新元素内容
new_outbound='{"type": "socks", "tag": "chatgpt", "server": "127.0.0.1", "server_port": 40000, "version": "5", "network": "tcp"}'
new_rule='{"rule_set": "geosite-openai", "outbound": "chatgpt"}'
new_rule_set='{"tag": "geosite-openai", "type": "remote", "format": "binary", "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-openai.srs"}'

# 指定要处理的JSON文件路径
json_file="/etc/sing-box/config.json"

# 检查文件是否存在route对象
if jq -e '.route' "$json_file" > /dev/null 2>&1; then
    # 检查是否存在rules数组
    if jq -e '.route.rules' "$json_file" > /dev/null 2>&1; then
        # 向rules数组添加新元素并保存到临时文件
        jq --argjson new_outbound "$new_outbound" --argjson new_rule "$new_rule" '.route.rules += [$new_rule]' "$json_file" > "$json_file.tmp" \
        && mv "$json_file.tmp" "$json_file"
        echo "Added new outbound and rule to $json_file"
    else
        echo "No 'rules' array found in $json_file"
    fi

    # 检查是否存在rule_set数组
    if jq -e '.route.rule_set' "$json_file" > /dev/null 2>&1; then
        # 向rule_set数组添加新元素并保存到临时文件
        jq --argjson new_rule_set "$new_rule_set" '.route.rule_set += [$new_rule_set]' "$json_file" > "$json_file.tmp" \
        && mv "$json_file.tmp" "$json_file"
        echo "Added new rule set to $json_file"
    else
        # 创建rule_set数组并向其中添加新元素并保存到临时文件
        jq --argjson new_rule_set "$new_rule_set" '.route += {"rule_set": [$new_rule_set]}' "$json_file" > "$json_file.tmp" \
        && mv "$json_file.tmp" "$json_file"
        echo "Created and added new rule set to $json_file"
    fi
fi

# 向outbounds数组添加新元素并保存到临时文件
jq --argjson new_outbound "$new_outbound" '.outbounds += [$new_outbound]' "$json_file" > "$json_file.tmp" \
&& mv "$json_file.tmp" "$json_file"
echo "Added new outbound to $json_file"
