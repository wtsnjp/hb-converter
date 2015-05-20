#!/usr/bin/ruby


### バージョン表示
VERSION = "1.0"
puts "Version #{VERSION}"


### 入出力ファイル名を定義
inputfile = ARGV[0]
$outputfile = "output.md"


### 出力ファイルに内容をコピー
File.open(inputfile, "r") do |file|
	input = file.read
	output = open($outputfile, "w")
	output.write(input)
	output.close
end


### 文字数をカウント
require_relative './script/counter.rb'


### リンクを停止
require_relative './script/add_nolink.rb'


### 処理の完了を表示
puts "Process has been completed successfully."
