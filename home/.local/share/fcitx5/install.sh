#!/bin/env bash
cp default.custom.yaml ./rime
cp tiger_sentence.custom.yaml  ./rime
cp double_pinyin_flypy.schema.yaml ./rime
cp rime_ice.dict.yaml ./rime
## theme
cp -rf ./backgrounds ./rime
cp -rf ./fonts ./rime
cp -rf ./小睦.yaml ./rime
cp -rf ./小睦44键.yaml ./rime

pushd rime
wget https://github.com/iDvel/rime-ice/releases/latest/download/cn_dicts.zip
unzip cn_dicts.zip
rm -rf ./cn_dicts.zip
popd
