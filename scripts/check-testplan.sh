#!/bin/sh
set -eu

plan="AppTemplate.xctestplan"
manifest="Package/Package.swift"

declared=$(sed -n '/\.testTarget(/,/^        )/ s/.*name: "\([A-Za-z0-9_]*\)".*/\1/p' "$manifest" | sort)
planned=$(sed -n 's/.*"identifier"[ ]*:[ ]*"\([A-Za-z0-9_]*\)".*/\1/p' "$plan" | sort)

if [ -z "$declared" ]; then
    echo "$manifest からテストターゲットを読み取れませんでした" >&2
    exit 1
fi

if [ -z "$planned" ]; then
    echo "$plan からテストターゲットを読み取れませんでした" >&2
    exit 1
fi

if [ "$declared" != "$planned" ]; then
    echo "テスト対象がずれています。足りないものは走らないまま緑になります。" >&2
    echo "" >&2
    echo "$manifest:" >&2
    echo "$declared" | sed 's/^/  /' >&2
    echo "$plan:" >&2
    echo "$planned" | sed 's/^/  /' >&2
    exit 1
fi

echo "テスト対象は $manifest と $plan で一致しています（$(echo "$declared" | wc -l | tr -d ' ') 件）"
