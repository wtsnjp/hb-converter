# counter.rb


### ソースコード構文領域の調査
begin_end_lines = []						# ソースコード開始・終了行番号格納配列
source_lines = []							# ソースコード行格納配列

file = File.open($outputfile, "r")
	file.each_line do |line|
		if /^```/ === line
			begin_end_lines << $.
		end
	end
file.close()

begin_end_lines.each_slice 2 do |b,e|
	source_lines << Range.new(b,e)
end


### カウンター
file = File.open($outputfile, "r")
	buffer = ""
	file.each_line do |line|
		# 空白と改行を除去
		line.gsub!(/\s|\n/, '')
		# ソースコード構文は全部カウント
		in_source = source_lines.map{|r| r.include?($.)}
		if in_source.none?
			# HTML
			line.gsub!('^<br>', '')
			line.gsub!(/^<!\-\-.+?\-\->/, '')
			line.gsub!(/^<center>|<\/center>/, '')
			line.gsub!(/^<figcaption>|<\/figcaption>/, '')
			line.gsub!(/^<img.+/, '')
			# リンク構文
			line.gsub!(/\[(.+?)\]\(.+?\)/){ $1 }
			# 引用構文
			line.gsub!(/^>/, '')
			# 脚注構文
			line.gsub!('((', '')
			line.gsub!('))', '')
			# TeX構文
			line.gsub!('[tex:', '')
			line.gsub!('%]', '')
			# インラインソースコード
			line.gsub!('`','')
			# 見出し
			line.gsub!(/^#+/,'')
			# 表組み
			if /^\|/ === line
				line.gsub!(/\-|:|\|/, '')
			end
			# 水平線
			line.gsub!(/^[*-_]{3,}/, '')
			# バッファーに代入
			buffer += line
		else
			line.gsub!(/```.*/, '')
			buffer += line
		end
	end
	# p buffer								# カウンタ動作確認用
	puts "The draft has #{buffer.length} characters."
file.close()

