# ad_nolink.rb


in_source, in_tex = false, false

file = File.open($outputfile, "r")
	buffer = ""
	file.each_line do |line|
		# ソースコードモード
		if in_source == true
			if /^```/ === line
				in_source = false
			end
			buffer += line
		# TeXモード
		elsif in_tex == true
			if /%\]/ === line
				line.gsub!('%]', ']')
				in_tex = false
			end
			buffer += line
		# 通常モード
		else
			# ソースコードモードへ移行
			if /^```/ === line
				in_source = true
				buffer += line
				next
			end
			# TeXモードへ移行
			if /^\[tex:/ === line && !(/%\]/ === line)
				in_tex = true
				buffer += line
				next
			end
			# インラインソースコード（中身を回収）
			source_buffer = []
			line.gsub!(/`(.+?)`/) do
				source_buffer << $1
				'[]``[]'
			end
			# リンク構文
			line.gsub!(/\[.+?\]\(.+?\)/){|str|
				if /!$/ === $`
					str
				else
					'[]' + str + '[]'
				end
			}
			# 引用構文
			line.gsub!(/^>\s/, '[]> []')
			# 脚注構文
			line.gsub!('((', '[](([]')
			line.gsub!('))', '[]))[]')
			# TeX構文
			line.gsub!('[tex:', '[][tex:')
			line.gsub!('%]', '][]')
			# 見出し
			if /^\#/ === line
				line.gsub!("#\ ", "#\ \[\]")
				line.gsub!("\n", "[]\n")
			end
			# enumerate構文
			if /^\s*\d+?\.\s/ === line
				line.gsub!('. ', '. []')
				line.gsub!("\n", "[]\n")
			end
			# itemize構文
			if /^\s*[*+-]\s/ === line
				line.gsub!(/[*+-]\s/){|str| str + '[]'}
				line.gsub!("\n", "[]\n")
			end
			# 表組み
			if /^\|.+\|$/ === line
				line.gsub!('|', '[]|[]')
				line.gsub!('|[]-', '|-')
				line.gsub!('|[]:', '|:')
				line.gsub!('-[]|', '-|')
				line.gsub!(':[]|', ':|')
			end
			# 画像キャプション
			if /^<figcaption>/ === line
				line.gsub!('<figcaption>', '<figcaption>[]')
				line.gsub!('</figcaption>', '[]</figcaption>')
			end
			# 行頭行末（見出し，箇条書き，HTMLタグのみ，水平線の行を除く）
			unless /^\#|^\s*[*+-]\s|^\s*\d+?\.\s|^<.+>$|^[*-_]{3,}$/ === line
				line.gsub!("\n", "")
				line.gsub!(line, '[]' + line + '[]' + "\n")
			end
			# 改行構文
			line.gsub!(/\ \ \[\]$/, '[]  ')
			# 二重[]の除去
			line.gsub!('[][]', '')
			# インラインソースコードを復元
			line.gsub!('``'){ '`' + source_buffer.shift + '`' }
			# 書き出し
			buffer += line
		end
	end
file = File.open($outputfile, "w")
	file.write(buffer)
file.close()
