#!/bin/bash
set -o

DEST_DIR='/test/'

TMP_FILE=$(mktemp)

mkdir -p $DEST_DIR

cookie_text="paste your browser's feishu cookie here"
CSRF_TOKEN="paste your browser's feishu bv-csrf-token here"

function get_list_of_epsidoe() {
	curl 'https://fs1xfqxc3u.feishu.cn/minutes/api/space/list?size=50&space_name=2&rank=0&asc=false&language=zh_cn' \
		-H 'authority: fs1xfqxc3u.feishu.cn' \
		-H 'accept: application/json, text/plain, */*' \
		-H 'accept-language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6' \
		-H "bv-csrf-token: $CSRF_TOKEN" \
		-H "cookie: $cookie_text" \
		-H 'device-id: 7315999206347079683' \
		-H 'dnt: 1' \
		-H 'platform: web' \
		-H 'referer: https://fs1xfqxc3u.feishu.cn/minutes/me' \
		-H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Microsoft Edge";v="120"' \
		-H 'sec-ch-ua-mobile: ?0' \
		-H 'sec-ch-ua-platform: "Windows"' \
		-H 'sec-fetch-dest: empty' \
		-H 'sec-fetch-mode: cors' \
		-H 'sec-fetch-site: same-origin' \
		-H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0' \
		-H 'utc-bias: 480' \
		-H 'x-lgw-os-type: 1' \
		-H 'x-lgw-terminal-type: 2' \
		--compressed -o $TMP_FILE

}

function post_export_request() {
	local topic=$1
	local url=$2
	local object_token=$3
	local now_time=$(date +%s%3N)
	clean_topic=$(echo "$topic" | tr ' ' '_')
	curl "https://fs1xfqxc3u.feishu.cn/minutes/api/export?_t=$now_time" \
		-H 'authority: fs1xfqxc3u.feishu.cn' \
		-H 'accept: application/json, text/plain, */*' \
		-H 'accept-language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6' \
		-H "bv-csrf-token: $CSRF_TOKEN" \
		-H "cookie: $cookie_text" \
		-H 'content-type: application/x-www-form-urlencoded' \
		-H 'device-id: 7315999523468689412' \
		-H 'dnt: 1' \
		-H 'origin: https://fs1xfqxc3u.feishu.cn' \
		-H 'platform: web' \
		-H "referer: $url" \
		-H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Microsoft Edge";v="120"' \
		-H 'sec-ch-ua-mobile: ?0' \
		-H 'sec-ch-ua-platform: "Windows"' \
		-H 'sec-fetch-dest: empty' \
		-H 'sec-fetch-mode: cors' \
		-H 'sec-fetch-site: same-origin' \
		-H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0' \
		-H 'utc-bias: 480' \
		-H 'x-lgw-os-type: 1' \
		-H 'x-lgw-terminal-type: 2' \
		--data-raw "add_speaker=true&add_timestamp=true&format=2&is_fluent=false&language=zh_cn&object_token=$object_token&translate_lang=default" \
		--compressed -o "${DEST_DIR}/${clean_topic}".txt
}

function export_to_dir() {
	result=$(jq -r '.data.list[] | .topic, .url, .object_token' $TMP_FILE)

	# Iterate over the lines of the result
	while IFS= read -r topic; do
		# Process each line (in this example, just print it)
		#echo "Processing: $line"

		# Split the line into separate variables
		#read -r topic
		read -r url
		read -r object_token

		# Use the variables in your Bash script as needed
		echo "Topic: $topic"
		echo "URL: $url"
		echo "Object_TOKEN :$object_token"
		clean_topic=$(echo "$topic" | tr ' ' '_')

		# Perform additional operations with the variables
		post_export_request $clean_topic $url $object_token
		sleep 1
	done <<<"$result"

}

function main() {
	get_list_of_epsidoe

	export_to_dir
}

main
