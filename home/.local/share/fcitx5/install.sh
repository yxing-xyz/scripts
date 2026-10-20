#!/bin/env bash
cp default.custom.yaml ./rime
cp tiger_sentence.custom.yaml  ./rime
cp double_pinyin_flypy.schema.yaml ./rime
cp rime_ice.dict.yaml ./rime

pushd rime
wget https://github.com/iDvel/rime-ice/releases/latest/download/cn_dicts.zip
unzip cn_dicts.zip
rm -rf ./cn_dicts.zip
popd
