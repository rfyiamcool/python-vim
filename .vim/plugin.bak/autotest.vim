" Vim c\c++ type plugin for generating btest code
" Last Change: 2010 
" Maintainer: luozuozuo@baidu.com

if exists("loaded_autotest")
	finish
endif
let loaded_autotest = 1

"是否是cpp文件
let g:flag_c_cpp = 0

"私有函数测试开关
let g:private_switch_flag = 0

"私有函数类型case生成标志
let g:private_case_flag = 0

"私有函数的行号信息
let g:private_class_bottom_row = 0

"类对应类测试标志
let g:class_to_class_flag = 0

"将生成路径追加test目录的字符串
let g:test_dir_str = "/test/"

"case 的begin_version
let g:begin_version = ""

"测试代码生成模式
let g:gen_mode = "function_to_class"

"静态库模式，值为空字符串或者"lib"
let g:lib_mode = ""

"class or struct flag
let g:class_or_struct = "class"

"设置类对类的标志属性
if system('test -e ./.class_to_class ; echo $?') ==0
	"echo "类对用例集模式"
	let g:class_to_class_flag = 1
endif

"判断是否生成路径追加test目录
if system('test -e ./.no_test_dir ; echo $?') == 0
	let g:test_dir_str = "./"
endif

"get_conf key ; return value
let g:get_conf = ". read_conf.sh;load_conf btest.conf;find_by_key "

"change_conf key value
let g:change_conf = ". read_conf.sh;load_conf btest.conf;change_by_key "

let g:source_path = expand("%:p")	
let g:source_name = bufname("%")
let g:source_name = substitute( g:source_path, '.*/', '', '')
let temp = 'test_'.g:source_name

"配置文件的判断和处理
"兼容了原test_dir.conf的配置方式
if system ('test -e ./test_dir.conf ; echo $?') != 0
	let g:relate_path = "."
	let g:object_name =getcwd()."/".g:test_dir_str.substitute(temp, '\..*', '.cpp',"")
else
	let g:relate_path = system('head -n 1 ./test_dir.conf | tr -d "\n"') 
	let g:object_name =getcwd()."/".g:relate_path.'/'.g:test_dir_str.substitute(temp, '\..*', '.cpp',"")
	if system('test -e ./btest.conf ; echo $?') !=0
		if system("test -e ".g:relate_path.'/'.g:test_dir_str."; echo $?") !=0
			call system("mkdir -p ".g:relate_path.'/'.g:test_dir_str)
		endif
	endif
endif

"读取配置文件
if system('test -e ./btest.conf ; echo $?') == 0
	" 读begin_version
	let g:begin_version = system(g:get_conf.' begin_version')

	"读路径
	let g:relate_path = "./"
	let g:test_dir_str = "./"
	let temp = system(g:get_conf.' test_dir')
	if temp != ""
		let g:relate_path = temp
	endif
	"echo "relate_path: ".g:relate_path 
	let temp = system(g:get_conf. ' no_test_dir')
	if temp == "" || temp == "false"
		let g:test_dir_str =  "/test/"
	endif
	"echo "no_test_dir: ".temp
	"echo "test_dir_str: ".g:test_dir_str
	let temp = 'test_'.g:source_name
	let g:object_name =getcwd()."/".g:relate_path.'/'.g:test_dir_str.substitute(temp, '\..*', '.cpp',"")
	"echo "object_name: ".g:object_name
	"if system("test -e ".g:relate_path.'/'.g:test_dir_str."; echo $?") !=0
		"call system("mkdir -p ".g:relate_path.'/'.g:test_dir_str)
	"endif

	"读gen_mode
	let g:class_to_class_flag = 0
	let g:gen_mode = system(g:get_conf. ' gen_mode')
	if g:gen_mode == 'class_to_class'
		"echo "class_to_class true"
		let g:class_to_class_flag = 1
	endif

	"读lib_mode
	let g:lib_mode = ""
	let g:lib_mode = system(g:get_conf. ' lib_mode')

endif

"将comake2文件转为Makefile

"初始化生成测试代码文件
function! <SID>Create_file()
	exec 'edit '.g:object_name
	call cursor(1, 1)
	let row = search('*/\$*', 'W')
    if row <= 0
		let row = 1
	else
		let row = row +1
	endif
	call append(row, "	")
	call append(row, "	")
	call append(row, '#include <gtest/gtest.h>')
	call append(row, '#include <'.g:source_name.'>')

	if g:lib_mode != "lib"
		let row =  row + 4
		call append(row,'}')
		call append(row,'	return RUN_ALL_TESTS();')
		call append(row,' 	testing::InitGoogleTest(&argc, argv);')
		call append(row, '{')
		call append(row, 'int main(int argc, char **argv)' )
	endif
	w
	exec 'edit '.g:source_path
endfunction

"追加一个测试case
function! <SID>Create_test(class_name, fun_name)
	let suite_name = ""
	let case_name = ""
	if g:class_to_class_flag == 0
		if a:class_name == ""
			let suite_name = 'test_'.a:fun_name.'_suite'
		else
			let suite_name = 'test_'.a:class_name.'_'.a:fun_name.'_suite'
		endif
		let case_name = "case_name"
	else
		if a:class_name == ""
			let suite_name = 'test_'.a:fun_name.'_suite'
		else
			let suite_name = 'test_'.a:class_name.'_suite'
		endif
		let case_name = 'test_'.a:fun_name."__"
	endif
	exec 'edit '.g:object_name 

	exec 'normal gg'
	let no_class = 0
	let temp = search(suite_name, "W")
	if temp > 0
		let no_class = 1
	endif

	exec 'normal G$'

	"for comfort with comdg.vim
	let row = search('}', 'bW')
	if (row <= 0)
		let row = line("$") - 20
		if (row <= 0)
			let row = line("$")
		endif
	elseif row + 1 <= line("$")
		let row = row + 1 
	endif

	let case_name_num = "1"
	if no_class == 1
		exec 'normal G$'	
		if g:class_to_class_flag == 0
			let temp = search(suite_name, "bW")
		else
			let temp = search('TEST_F('.suite_name.'\s*,\s*test_'.a:fun_name."__" , 'bW')
			if temp <=0 
				exec 'normal G$'	
				let temp = search(suite_name, "bW")
			endif
		endif

		if g:class_to_class_flag == 0
			let case_name_num = <SID>Get_case_name_num(suite_name , "")
			let case_name = <SID>Get_case_name(suite_name)
		else
			let case_name_num = <SID>Get_case_name_num(suite_name , case_name)
		endif

		let temp = search('{', 'W')
		let temp = searchpair('{', '', '}', 'W')
		let row = temp + 1
	endif

	call append(row, ' ')
    call append(row, '}')
	call append(row, '	//TODO')
    call append(row, '{')
	call append(row, 'TEST_F('.suite_name.', '.case_name.case_name_num.')')
	call append(row, '**/')
	call append(row, ' * @begin_version '.g:begin_version)
	call append(row, ' * @brief ')
	call append(row, '/**')
	
	"if g:private_case_flag == 1
	"	call append(row, '//的FRIEND_TEST，保证casename一致，或删除 FRIEND_TEST ')
	"	call append(row, '//文件 :' . expand( g:source_name. ":t") .' 行:'.g:private_class_bottom_row)
	"	call append(row, '//如果需要更改casename，或删除用例，请对应操作位于')
	"	call append(row, '//私有、保护方法测试')
	"	w
	"	exec 'edit '.g:source_path
	"	call append(g:private_class_bottom_row - 1 , 'FRIEND_TEST('. suite_name. ',' .case_name.case_name_num.');')
	"	w
	"	exec 'edit '.g:object_name 
	"endif

	if no_class ==1
		w
		exec "edit ".g:source_path
		return 
	endif

	call append(row, ' ')
    call append(row, '};')
    call append(row, '        };')
	call append(row, '            //Called after every TEST_F('.suite_name. ', *)')
    call append(row, '        virtual void TearDown() {')
    call append(row, '        };')
	call append(row, '            //Called befor every TEST_F('.suite_name. ', *)')
    call append(row, '        virtual void SetUp() {')
    call append(row, '        virtual ~'.suite_name.'(){};')
	if g:lib_mode != "lib"
		call append(row, '        '.suite_name.'(){};')
	else
		call append(row, '        };')
		call append(row, '            //TODO')
		call append(row, '        '.suite_name.'(void *instance, void *data){')
	endif
    call append(row, '    protected:')
	call append(row, 'class '.suite_name.' : public ::testing::Test{')
	call append(row, '**/')
	call append(row, ' * @brief ')
	call append(row, '/**')
	w
	exec 'edit '.g:source_path
endfunction


"判断函数是否已经存在于统计文件中
function! <SID>Is_in_statics( class_name, fun_name) 
	exec 'edit .statics_temp'
	let temp = 0
	exec 'normal gg'
	if a:class_name == ""
		let temp = search("function:".a:fun_name." case:", 'W')
	else
		let temp = search("class:".a:class_name." function:".a:fun_name. " case:", 'W')
	endif
	if temp != 0 
		let temp = 1
	endif
	exec 'edit '.g:source_path
	return temp
endfunction
	

"从测试代码中获取统计信息
function! <SID>Get_statics( class_name, fun_name )
	let suite_name = 'TEST_F\s*(\s*test_'.a:class_name."_".a:fun_name.'_suite'
	if a:class_name == "" 
		let suite_name = 'TEST_F\s*(\s*test_'.a:fun_name.'_suite'
	elseif g:class_to_class_flag == 1
		let suite_name = 'TEST_F\s*(\s*test_'.a:class_name.'_suite\s*,\s*test_'.a:fun_name."__"
	endif
	exec 'edit '.g:object_name 
	exec 'normal gg'
	let case_count = 0
	let temp = search(suite_name, "W")
	while temp > 0
		if <SID>In_comment() == 0
			let case_count = case_count + 1
		endif
		let temp = search(suite_name, "W")
	endwhile
	exec 'edit '.g:source_path
	return case_count
endfunction

"打印函数对应的case数量的统计信息
function! <SID>Print_statics(line_num, class_name, fun_name )
	let temp = <SID>Is_in_statics( a:class_name, a:fun_name)
	if temp == 1
		return
	endif
	let case_count = <SID>Get_statics( a:class_name, a:fun_name)
	let prefix = ""
	if case_count == 0
		let prefix = "*"
	endif
	if a:class_name != ""
		if g:class_to_class_flag == 0
			call system('echo '.prefix ."line:".a:line_num . " class:". a:class_name. " function:".a:fun_name ." case:". case_count .'>> .statics_temp')
		else
			call system('echo '.prefix ."line:".a:line_num . " class:". a:class_name. " function:".a:fun_name ." case:". case_count .'>> .statics_temp')
		endif
	else 
		call system('echo '.prefix . "line:".a:line_num ." function:".a:fun_name ." case:". case_count.'>> .statics_temp')
	endif
	w
endfunctio

"追加统计信息
function! <SID>Print_append(line_num, class_name, fun_name )
	let prefix = ""
	exec 'edit .statics_temp'
	if a:class_name != ""
		call append(line("$") - 1,prefix ."line:".a:line_num . " class:". a:class_name. " function:".a:fun_name )
	else 
		call append(line("$") - 1,prefix . "line:".a:line_num ." function:".a:fun_name )
	endif
	w
	exec 'edit '.g:source_path
endfunctio

"删除字符串的\r
function! <SID>Remove_CR( string)
	let string = substitute( a:string, "\r", "", 0)
	return string
endfunction

"判断匹配的函数是否是#define的宏定义
function! <SID>In_define()
	let line = getline(".")
	let pos = match(line, '[^\s]', 0 )
	if pos < 0 
		return 0 
	endif 
	if 	strpart(line, pos, 1) == '#'
		return 1
	endif
	return 0
endfunction

"判断匹配到的函数是否是typedef的类型
function! <SID>In_typedef()
	let line = getline(".")
	let pos = match(line, '\k', 0)
	if pos <0
		return 0
	endif
	if strpart(line, pos, 7) == 'typedef'
		return 1
	endif
	return 0
endfunction

"判断当前光标是否在注释区域
function! <SID>In_comment()
	let row = line(".")
	let colomn = col(".")
	call cursor( row , colomn)
	let two_slash_row = search('//', 'bW')
	if two_slash_row == row 
		call cursor ( row, colomn)
		return 1
	endif

	call cursor ( row, colomn)
	let left_slash_asterisk_row = search ('/\*', 'bW')
	let left_slash_asterisk_col = col(".")

	if left_slash_asterisk_row > 0
		let right_asterisk_slash_row = searchpair('/\*','','\*/', 'W')
		let right_slash_asterisk_col = col(".")

		if right_asterisk_slash_row > row
			call cursor ( row, colomn)
			return 1
		elseif right_asterisk_slash_row == row && right_slash_asterisk_col > colomn
			call cursor ( row, colomn)
			return 1
		endif
	endif
	call cursor ( row, colomn)
	return 0
endfunction

"判断是否是虚函数
function! <SID>Is_pure_virtual()
	let ori_row = line(".")
	let ori_colomn = col(".")
	
	call search('(','W')
	call searchpair('(','',')','W')
	let colomn = col(".")
	if colomn <= 0 
		call cursor(ori_row, ori_colomn)
		return 0
	endif
	let line = getline(".")
	let pos = match(line, '\s*=\s*0', colomn - 1)
	if pos < 0
		call cursor(ori_row, ori_colomn)
		return 0
	endif
	call cursor(ori_row, ori_colomn)
	return 1
endfunction

"判断是否函数指针
function! <SID>Is_fun_point()
	let ori_row = line(".")
	let ori_colomn  = col(".")
	
	let fun_row = search('(', 'W')
	if fun_row <= 0 
		call cursor(ori_row, ori_colomn)
		return 1
	endif

	let fun_row = searchpair('(','',')','W')
	if fun_row <= 0
		call cursor(ori_row, ori_colomn)
		return 1
	endif
	let start = col(".") - 1
	let pos = match( getline("."),  ')\s*(', start)
	"echo "pos : ".pos
	if pos < 0 
		call cursor(ori_row, ori_colomn)
		return 0
	else
		call cursor(ori_row, ori_colomn)
		return 1
	endif
endfunction


"判断是否是构造函数初始化
function! <SID>Is_constructor_init(fun_name, start)
	let ori_row = line(".")
	let ori_colomn = col(".")
	let fun_reg = <SID>Get_fun_reg()

	"echo "start: ".a:start
	call cursor(ori_row, a:start + 1)
	let colon_row = search(':', 'bW')
	if colon_row <= 0
		call cursor( ori_row, ori_colomn)
		return 0
	endif
	if colon_row + 5 < ori_row
		call cursor( ori_row, ori_colomn)
		return 0
	endif
	let colon_colomn = col(".")

	"判断是否是public 等以后的方法
	let temp_row = search('\<\h\w*\>','bW')
	let temp_colomn = col(".")
	let line = getline(".")  
	let pos = match(line, 'public\|private\|protected\s*:')
	if pos + 1 == temp_colomn
		call cursor( ori_row, ori_colomn)
		return 0
	else
		call cursor(colon_row, colon_colomn)
	endif
	" 完成判断

	"echo colon_row 
	"echo ori_row
	"echo colon_colomn
	"echo ori_colomn
	
	"if colon_row == ori_row 
		"if colon_colomn + 1 == a:start + 1
			"call cursor( ori_row, ori_colomn)
			"return 1
		"endif
	"else
	if 1 == 1
		let row = search('\_s*,\_s*'.a:fun_name.'\s*(','eW')
		if row == ori_row || row == ori_row -1
			call cursor( ori_row, ori_colomn)
			return 1
		endif
		
		"++add for cpp
		if g:flag_c_cpp == 1
			call cursor(colon_row, colon_colomn -2)
			let row = search('::\_s*'.a:fun_name.'\s*(','eW')
			if row == ori_row || row == ori_row - 1
				call cursor( ori_row , ori_colomn)
				return 0
			endif
		endif
		"--add

		call cursor(colon_row, colon_colomn -1)
		let row = search(':\_s*'.a:fun_name.'\s*(','eW')
		if row == ori_row || row == ori_row - 1
			call cursor( ori_row, ori_colomn)
			return 1
		endif
	endif
	call cursor( ori_row , ori_colomn)
	return 0
endfunction

"判断是否是友元类
function! <SID>Is_friend_class()
	let ori_row = line(".")
	let ori_colomn = col(".")
	let row = search('friend\s\+class', 'bW')
	if row == ori_row
		call cursor( ori_row , ori_colomn)
		return 1
	else
		call cursor( ori_row , ori_colomn)
		return 0
	endif
endfunction


"just in namespace , count it not in codeblock
function! <SID>Not_in_codeblock(start, middle, end)
	let ori_row = line(".")
	let ori_colomn = col(".")

	" about namespace with {
	let flag_namespace = 0
	while flag_namespace == 0 && a:start == '{'
		let namespace_row = search('namespace', 'bW')
		if namespace_row <= 0
			break
		endif
		let namespace_colomn = col(".")
		if <SID>In_comment()
			continue
		endif
		let line = getline(".")
		let pos = match(line, 'using\s\+namespace', 0)
		if pos >= 0
			continue
		endif

		let namespace_leftb_row = search('{', 'W')
		if namespace_leftb_row <= 0 
			continue
		endif
		let namespace_lefb_colomn = col(".")
		let namespace_rightb_row = searchpair('{','','}','W')
		let namespace_rightb_colomn = col(".")
		call cursor( namespace_row, namespace_colomn)
		if namespace_rightb_row <= 0
			echo 'miss }'
			continue
		endif
		if namespace_rightb_row > ori_row || namespace_rightb_row == ori_row && namespace_rightb_colomn > ori_colomn 
			let flag_namespace = 1
		endif
	endwhile
	call cursor(ori_row, ori_colomn)
	"echo "flag_namespace : ".flag_namespace
	


	let flag_not_in_block = 1
	while 1 == 1
		"echo "ori col :". ori_colomn
		"echo "start :".a:start
		call cursor(line("."), col(".") + 1)
		let left_bracket_row = search(a:start, 'bW')
		if left_bracket_row <= 0
			break
		endif 

		"if <SID>In_comment() == 1
			"continue
		"endif
		
		let left_bracket_colomn = col(".")
		if  ( a:start == '<' || a:start == '[' || a:start == '(' ) && left_bracket_row != ori_row
			let flag_not_in_block = 1
			break
		endif

		"if  a:start != '{' || a:start == '{' && <SID>In_comment() == 0
			let right_bracket_row = searchpair(a:start,a:middle,a:end, 'W')
			if right_bracket_row == 0
				echo "parse error : miss ".a:end
				echo "--------------------"
				let flag_not_in_block = 0
				break
			endif
			let right_bracket_colomn = col(".")
			if ( right_bracket_row > ori_row || right_bracket_row == ori_row && right_bracket_colomn > ori_colomn )
				if flag_namespace == 0 
					let flag_not_in_block = 0
					break
				else
					if right_bracket_row == namespace_rightb_row && right_bracket_colomn == namespace_rightb_colomn && left_bracket_row == namespace_leftb_row && left_bracket_colomn == namespace_lefb_colomn
						break
					else
						let flag_not_in_block = 0
						break
					endif
				endif
			endif

		"endif

		"++ avoid death loop
		if left_bracket_colomn != 1
			call cursor( left_bracket_row, left_bracket_colomn -1)
		else 
			if left_bracket_row != 1
				call cursor( left_bracket_row -1 , 1)
				call cursor( left_bracket_row -1, col("$") )
			else
				break
			endif
		endif
		"-- avoid death loop
	endwhile
	call cursor( ori_row, ori_colomn)
	"echo "flag_not_in_block :".flag_not_in_block
	"echo "flag_not_in_block :".flag_not_in_block
	return flag_not_in_block
endfunction

"判断是否恰好在class的{}代码块中
function! <SID>Is_class_fun()
	let ori_row = line(".")
	let ori_colomn = col(".")

	let flag_class = 0
	while flag_class == 0
        "struct
		"let class_row = search( '\<class\|struct\>', 'bW')
		let class_row = search( '\<\(class\|struct\)[ \t\n]\+[^{;]\+[ \t\n]\+{', 'bW')
		if class_row <= 0
            break
		endif
		let class_colomn = col(".")
		if <SID>In_comment() == 0
			if <SID>Not_in_codeblock('<','','>') == 0 || <SID>Is_friend_class()
				continue
			endif
			let flag_class = 1
		endif 
	endwhile
	"echo "class_row: ".line(".")."class_col: ".col(".")
	"echo "class_row :".class_row 
	"echo "---------------------"

	if flag_class == 0
		call cursor( ori_row, ori_colomn)
		return 0
	endif 
	let class_left_bracket_row = search('{', 'W')
	if class_left_bracket_row <= 0
		call cursor( ori_row, ori_colomn)
		return 0
	endif
	let class_left_bracket_colomn = col(".")
	let class_right_bracket_row = searchpair('{','','}','W')
	if class_right_bracket_row == 0
		call cursor( ori_row, ori_colomn)
		return 0
	endif
	let class_right_bracket_colomn = col(".")

	"find function's mix code block
	call cursor( ori_row, ori_colomn)
	while 1==1
		let code_block_left_bracket_row = search('{','bW')
		if code_block_left_bracket_row <= 0 
			call cursor(ori_row , ori_colomn)
			return 0
		endif
		if <SID>In_comment() == 1
			continue
		endif
		let temp_row = line(".")
		let temp_colomn = col(".")
		let code_block_left_bracket_colomn = col(".")
		let code_block_right_bracket_row = searchpair('{','','}','W')
		let code_block_right_bracket_colomn = col(".")
		if code_block_left_bracket_row == class_left_bracket_row && code_block_left_bracket_row == class_left_bracket_colomn
			break
		endif
		if code_block_right_bracket_row > ori_row || code_block_right_bracket_row == ori_row && code_block_right_bracket_colomn > ori_colomn
			break
		endif
		call cursor(temp_row , temp_colomn)
	endwhile

	"echo class_right_bracket_row ." ". code_block_right_bracket_row 
	"echo class_right_bracket_colomn ." ". code_block_right_bracket_colomn
	"echo class_left_bracket_row ." ". code_block_left_bracket_row 
	"echo class_left_bracket_colomn ." ". code_block_left_bracket_colomn
	"echo '.....................'

	if class_right_bracket_row == code_block_right_bracket_row 
		if class_right_bracket_colomn == code_block_right_bracket_colomn
			if class_left_bracket_row == code_block_left_bracket_row 
				if class_left_bracket_colomn == code_block_left_bracket_colomn
					call cursor(ori_row, ori_colomn)
					return 1
				endif
			endif
		endif
	endif
	call cursor(ori_row , ori_colomn)
	return 0
endfunction

"获取class的名称
function! <SID>Get_class_name_inline()
	let line = getline(".")
	let start = match(line, '\k', 0)
	if start < 0
		return ""
	endif 
	"let keyword =  strpart(line, start, 5)
    "struct
	if strpart(line, start, 5) != 'class' && strpart(line, start, 6) != 'struct'
		return ""
	endif

	let space_pos = match(line , '\s', start )
	let begin = match(line, '\k', space_pos )
	let end = match(line, '\s\|:\|{', begin)
	if end < 0
		let end = strlen (line)
	endif 
	let class_name = strpart(line, begin, end - begin)
	let class_name = <SID>Remove_CR( class_name)

	return class_name
endfunction
	
"获取在cpp中实现的函数的类名
function! <SID>Get_colon_classname(fun_name)
	if <SID>Not_in_codeblock("{", "", "}") == 0
		return ""
	endif

	let line = getline(".")
	let pos = match( line, '>\s*::\s*'.a:fun_name )
	let class_name = ""
	"echo 'pos :'.pos
	if pos >= 0
		let ori_row = line(".")
		let ori_colomn = col(".")
		call cursor( ori_row , 1)
		call search( '::', 'W')
		call search( '>', 'bW')
		call searchpair('<','','>', 'bW')
		call search('\k', 'bW')
		let end = col(".")
		let row =  search('[^a-zA-Z_0-9]', 'bW')
		let start = col(".")
		if row != ori_row 
			let start = 0
		endif
		let class_name = strpart( line, start, end - start)
		call cursor( ori_row , ori_colomn)
	else
		let start = match(line, '\S\+\s*::\s*'.a:fun_name)
		let end = match(line, '\s*::\s*'.a:fun_name)
		let class_name = strpart (line, start, end - start)
	endif
	"echo 'class_name :' . class_name ."--"
	"echo '----------'
	let class_name = <SID>Remove_CR( class_name)
	return class_name
endfunction
		

"function! <SID>Get_case_name_num(suite_name)
"	let line = getline(".")
"	let case_num = "1"
"	if match(line, '\s*TEST_F\s*(\s*' .a:suite_name.'\s*,\s*case_name[0-9]\+\s*)' ) >= 0
"		let pos = match( line, 'case_name')
"		let start = match( line ,'[0-9]',pos)
"		let end = match( line, '[^0-9]', start)
"		let case_num = strpart( line, start, end - start)
"		let case_num = case_num + 1
"	endif
"	return case_num
"endfunction

"获取测试代码中最新的case名称的序号
function! <SID>Get_case_name_num(suite_name, case_name)
	let line = getline(".")
	let case_num = "1"
	if match(line, '\s*TEST_F\s*(\s*' .a:suite_name.'\s*,\s*\w\+\s*)' ) >= 0
		let pos = match( line, ',')
		let temp = match(line ,'\k',pos)
		let start = match(line, '[0-9]\+\s*)',temp)
		"echo "======="
		"echo a:case_name
		"echo strpart(line, temp, strlen(a:case_name) )
		"echo "======="
		if a:case_name != "" && strpart(line, temp, strlen(a:case_name) ) != a:case_name
			return case_num
		endif
		if  start > 0 
			let end = match(line, '\s*)', start)
			let case_num = strpart( line, start, end - start)
			let case_num = case_num + 1
		endif
	endif
	return case_num
endfunction

"获取测试代码中case的名称
function! <SID>Get_case_name(suite_name)
	let line = getline(".")
	let case_name = "case_name"
	if match(line, '\s*TEST_F\s*(\s*' .a:suite_name.'\s*,\s*\k\+\s*)' ) >= 0 
		let pos = match(line, ",")
		let start = match(line, '\k', pos)
		let end = match(line, '[0-9]*\s*)',start)
		let case_name = strpart(line, start, end - start)
	endif
	return case_name
endfunction
				


"获取函数的名称
"start is function first pos in the line
function! <SID>Get_function_name( start )
	let row = line(".")
	let colomn = a:start + 1

	call cursor( row , colomn)
	let two_slash_row = search('//', 'bW')
	if two_slash_row == row 
		call cursor ( row, colomn)
		return ""
	endif

	call cursor ( row, colomn)
	let left_slash_asterisk_row = search ('/\*', 'bW')
	let left_slash_asterisk_col = col(".")

	if left_slash_asterisk_row > 0
		let right_asterisk_slash_row = searchpair('/\*','','\*/', 'W')
		let right_slash_asterisk_col = col(".")

		if right_asterisk_slash_row > row
			call cursor ( row, colomn)
			return ""
		elseif right_asterisk_slash_row == row && right_slash_asterisk_col > colomn
			call cursor ( row, colomn)
			return ""
		endif
	endif

	call cursor ( row, colomn)

	if <SID>In_define() == 1
		return ""
	endif

	if <SID>In_typedef() == 1
		return ""
	endif

	if <SID>Is_pure_virtual() == 1
		return ""
	endif

	if <SID>Is_fun_point() == 1
		return ""
	endif

	if <SID>Not_in_codeblock('[','','\]') == 0 || <SID>Not_in_codeblock('(','',')') == 0
		return ""
	endif


	let line = getline(".")
	let end = a:start
	if ( match(line , g:regular_fun_reg, a:start) >= 0)
		let begin = match(line, '\k', a:start)
		let end = match(line, '\s', begin)
		let g:return_type = strpart(line, begin, end - begin)
	else
		let g:return_type = ""
	endif


	let begin = match(line, '\k\|\~', end )
	"let pos = match(line, '\s', pos )
	"let begin = match(line, '\k', pos )
	
	let end = match(line, '\s\|(', begin)
	let fun_name = strpart(line, begin, end - begin)
	if fun_name =="if" || fun_name == "while" || fun_name == "for" || fun_name == "switch" || fun_name == "FRIEND_TEST"
		return ""
	endif
	if match( fun_name , '\~.*' ) >=0
		return ""
	endif
	if <SID>Is_constructor_init(fun_name, a:start) == 1
		return ""
	endif
	let class_name = <SID>Remove_CR( fun_name)
	return fun_name
endfunction


"获取匹配函数的正则表达式
function! <SID>Get_fun_reg()
	"let decl_word = '\s*\[inline\|extern\|virtual\|static\|\]\s*'
	"let point = '\*\{0,3}\s*'
	"let array = '\s*\([\s*]\)*\s*'
	"let extra = point
	"let word = '\s*\k\+\s*'
	"let space = '\s\+'
	"let type = '\['.word.extra.'\|'.word.space.'\]'
	"let fun_reg = type.space.word.'('.'\('.type.space.word.','.'\)*'.type.space.word.')'
	"let fun_reg = type.space.word.'('.'\('.type.space.word.','.'\)*'.type.space.word.')'
	"let fun_reg = '\s*\~\{0,1}\k\+\s*([^)]*)'
	"let g:regular_fun_reg = '\s*\k\+\s\+\k\+\s*([^)]*)'
	"let g:constructor_fun_reg = '\s*\~\{0,1}\k\+\s*([^)]*)'
	let g:regular_fun_reg = '\s*\k\+\s\+\k\+\s*('
	let g:constructor_fun_reg = '\s*\~\{0,1}\k\+\s*('
	let fun_reg = g:regular_fun_reg.'\|'.g:constructor_fun_reg
	return fun_reg
endfunction

"传给gen_makefile.sh 的参数
"(1) 解析的文件的目录的绝对路径
"(2) 要生成的Makefile所在的绝对路径
function! <SID>Gen_makefile()
	let code_file_path = expand("%:p:h")
	let base = getcwd().'/'.g:relate_path.'/'.g:test_dir_str
	call system("mkdir -p ".base)
	if g:lib_mode == "lib"
		exec '!gen_makefile.sh '.code_file_path.' '.base.' '.g:private_switch_flag.' so'
	else
		exec '!gen_makefile.sh '.code_file_path.' '.base.' '.g:private_switch_flag
	endif
endfunction

"生成测试代码的comake文件
function! <SID>Gen_comake_file()
	echo "Gen comake file!"
	let base = getcwd().'/'.g:relate_path.'/'.g:test_dir_str
	let temp = system("ls *.prj")
	let pos = match(temp , '\_s')
	let temp = strpart(temp, 0, pos )
	let a =  system("gen_prj.py ".temp." ".base)
	"echo a
endfunction

"生成comake2格式的makefile
function! <SID>Gen_comake2_file()
	let code_file_path = expand("%:p:h")
	let base = getcwd().'/'.g:relate_path.'/'.g:test_dir_str
	call system("mkdir -p ".base)
	call system("gen_comake2.py COMAKE ".g:source_path." ".base)
  if (g:private_switch_flag)
    call <SID>Private_support() 
  endif
endfunction



"补助函数, 向下搜索指定函数内的字符串
function! <SID>Search_inline(pattern, flags, stopline)
	let row = search( a:pattern, a:flags)
	if (row > a:stopline)
		return 0
	endif
	return row
endfunction

"补助函数, 向上搜索指定行内的字符串
function! <SID>Search_inline_back(pattern, flags, stopline)
	let row = search( a:pattern, a:flags)
	if (row < a:stopline)
		return 0
	endif
	return row
endfunction

"判断匹配的函数的类的public函数
"current row position is class
function! <SID>In_class_public(fun_row, fun_colomn)
	let row = line(".")
	let colomn = col(".")

	"初始化私有函数类偷腸ase生成标志
	let g:private_case_flag = 0

	"echo "class row :".row."---- class colomn :".colomn
	"echo "fun row :".a:fun_row."---- fun colomn :".a:fun_colomn
	"echo "fun row :".a:fun_row."---- fun colomn :".a:fun_colomn

	let left_bracket_row = search('{', 'W')
	if left_bracket_row <= 0
		call cursor(row, colomn)
		return "0"
	endif 
	let left_bracket_colomn = col(".")

	let right_bracket_row = searchpair('{','','}', 'W')
	"echo "right_bracket_row ". right_bracket_row
	"echo "right_bracket_row ". right_bracket_row
	if left_bracket_row <= 0
		call cursor(row, colomn)
		return "0"
	endif 
	let right_bracket_colomn = col(".")
	"echo "right_bracket_colomn ". right_bracket_colomn
	"echo "right_bracket_colomn ". right_bracket_colomn

	
	if left_bracket_row  > a:fun_row 
		call cursor( row, colomn)
		return "0"
	elseif left_bracket_row == a:fun_row && left_bracket_colomn > a:fun_colomn
		call cursor( row, colomn)
		return "0"
	elseif right_bracket_row < a:fun_row 
		call cursor( row, colomn)
		return "0"
	elseif right_bracket_row == a:fun_row && right_bracket_colomn < a:fun_colomn
		call cursor( row, colomn)
		return "0"
	endif
	

	call cursor( a:fun_row, a:fun_colomn)
	let public_reg = 'public\s*:'
	let protect_reg = 'protected\s*:'
	let private_reg = 'private\s*:'

	let flag_in_comment = 1
	while flag_in_comment ==1
		let public_row = <SID>Search_inline_back(public_reg , 'bW', left_bracket_row)
		if public_row <=0 
			break
		endif
		let flag_in_comment =  <SID>In_comment()
		"echo flag_in_comment
		"echo flag_in_comment
	endwhile

	if public_row <= 0
		let public_row = left_bracket_row
	endif
		
	call cursor( a:fun_row, a:fun_colomn)
	let flag_in_comment = 1
	while flag_in_comment ==1
		let protect_row = <SID>Search_inline_back(protect_reg , 'bW', public_row)
		if protect_row <= 0
			break
		endif 
		let flag_in_comment =  <SID>In_comment()
	endwhile


	call cursor( a:fun_row, a:fun_colomn)
	let flag_in_comment = 1
	while flag_in_comment ==1
		let private_row = <SID>Search_inline_back( private_reg, 'bW', public_row)
		if private_row <=0 
			break
		endif
		let flag_in_comment =  <SID>In_comment()
	endwhile

	let private_protect_row = 0
	if private_row > 0 || protect_row > 0
		let private_protect_row = 1
	endif
		
	"echo "pub : ".public_row 
	"echo "protect_row : ".protect_row 
	"echo "private_row : ".private_row

	let flag_is_private = 0 
	if private_protect_row == 1 || private_protect_row == 0 &&  public_row == left_bracket_row && g:class_or_struct == "class"
		let flag_is_private = 1
	endif

	"echo "flag _ private ". flag_is_private
	"echo "--------------"
	
	if flag_is_private == 1
		if g:private_switch_flag == 0
			call cursor( row, colomn)
			return '#is_private_fun'
		else
			let g:private_case_flag = 1
			let g:private_class_bottom_row = right_bracket_row
		endif
	endif
		
	call cursor( row, colomn)
	return "1"

endfunction

"获取类的名称
function! <SID>Get_class_name()
	let row = line(".")
	let colomn = col(".")

    "let tmp_class_row = search('\<class\>', 'bW')
    let tmp_class_row = search('\<class[ \t\n]\+[^{;]\+[ \t\n]\+{', 'bW')
    call cursor(row, colomn)

    "let tmp_struct_row = search('\<struct\>', 'bW')
    let tmp_struct_row = search('\<struct[ \t\n]\+[^{;]\+[ \t\n]\+{', 'bW')
    call cursor(row, colomn)

    "echo "tmp_struct_row:".tmp_struct_row."tmp_class_row:".tmp_class_row
    if tmp_struct_row > tmp_class_row
        let g:class_or_struct = "struct"
    endif

	let flag_class = 0
	let flag_private_fun = 0
	
	while flag_class == 0
        "struct
		"let class_row = search( '\<class\|struct\>', 'bW')
		let class_row = search( '\<\(class\|struct\)[ \t\n]\+[^{;]\+[ \t\n]\+{', 'bW')
		if class_row <= 0
            break
		endif
		"echo "find class in ". class_row
		let class_colomn = col(".")


		if <SID>In_comment() == 0
			let temp = <SID>In_class_public(row, colomn)
            "echo "in_class_public result:".temp
			if temp  == "1"
				let flag_class = 1
				"echo "success class in ". class_row
				"echo "success class in ". class_row
				break
			elseif temp == '#is_private_fun'
				let flag_class = 1
				let flag_private_fun = 1
				break
			endif 
		endif 
	endwhile

	if flag_class == 0
		call cursor( row, colomn)
		return ""
	elseif flag_private_fun == 1
		call cursor( row, colomn)
		return '#is_private_fun'
	endif 


    let space_pos = search('\s\|\n', 'W')
    "echo "space_pos=".space_pos
    if space_pos <= 0
        call cursor( row, colomn)
        return ""
    endif
    let begin_pos = search('\k', 'W')
    "echo "begin_pos=".begin_pos
    if begin_pos <= 0
        call cursor( row, colomn)
        return ""
    endif
    let line = getline(".")
    let begin_pos = col(".") - 1
    "echo "begin_pos=".begin_pos
    let end_pos = match(line, '\s\|:\|{\|\n', begin_pos)
    "echo "end_pos=".end_pos
    if end_pos < 0
        let end_pos = strlen (line)
    endif



	"let line = getline(".")

	"let space_pos = match(line , '\s', class_colomn )
	"let begin = match(line, '\k', space_pos )
	"let end = match(line, '\s\|:\|{', begin)
	"if end < 0
	"	let end = strlen (line)
	"endif 
	"echo space_pos
	"echo begin
	"echo end
	"echo "jjjjjjjjjjjjjjjjjjjjjj"
	let class_name = strpart(line, begin_pos, end_pos - begin_pos)

	call cursor( row, colomn)
	let class_name = <SID>Remove_CR( class_name)
	return class_name

endfunction


"从函数当前行跳转的对应的测试代码的用例集位置（function to class模式）
"或跳转到对应的case(class to class 模式）
function! <SID>Jump_testcode(class_name, fun_name)
	let suite_name = 'test_'.a:class_name.'_'.a:fun_name.'_suite'
	if a:class_name == ""
		let suite_name = 'test_'.a:fun_name.'_suite'
		exec 'edit '.g:object_name 
		call cursor(1,1)
		call search(suite_name ,'W')
	elseif g:class_to_class_flag == 1
		let suite_name = 'TEST_F\s*(\s*test_'.a:class_name.'_suite\s*,\s*test_'.a:fun_name."__"
		exec 'edit '.g:object_name 
		call cursor(1,1)
		let ret = search(suite_name ,'W')
		if ret <=0
			let suite_name = 'TEST_F\s*(\s*test_'.a:class_name.'_suite\s*,\s*test_'.a:fun_name
			call cursor(1,1)
			call search(suite_name, 'W')
		endif
	else
		exec 'edit '.g:object_name 
		call cursor(1,1)
		call search(suite_name ,'W')
	endif
endfunction

"类跳转到对应的测试代码中
function! <SID>Jump_class_testcode(string)
	exec 'edit '.g:object_name 
	call cursor(1,1)
	"echo a:string
	"echo a:string
	call search(a:string ,'W')
endfunction

function! <SID>For_test()
	"echo "上面是调试信息"
endfunction

function! <SID>Print_log(msg)
  call system("echo ".a:msg." >> auto.log")
endfunction

function! <SID>Gen_fun_test(class_name, fun_name)
  if a:fun_name == ""
    return
  endif
  if !(a:class_name == "" && a:fun_name == "main")
    if g:create_flag == 0
      "call <SID>Print_log("Create_file")
      call <SID>Create_file()
      let g:create_flag = 1
    endif
    "call <SID>Print_log("Gen_fun_test: ".a:class_name."::".a:fun_name)
    call <SID>Create_test(a:class_name, a:fun_name)
  endif
endfunction

function! <SID>Append_new_suite()
  if system("test -e ".g:info_file."; echo $?") != 0
    "call <SID>Print_log("info_file: ".g:info_file." not exist")
    return
  endif

  w
  exec 'edit '.g:info_file
  let cur_row = 1
  let last_row = line("$")
  "call <SID>Print_log("cur_row: ".cur_row." last_row: ".last_row)

  while cur_row <= last_row
    w
    exec 'edit '.g:info_file
    let content = getline(cur_row)

    let space_pos = match(content, " ")
    let begin_line = strpart(content, 0, space_pos)
    let content = strpart(content, space_pos + 1)

    let space_pos = match(content, " ")
    let save_num_1 = strpart(content, 0, space_pos)
    let content = strpart(content, space_pos + 1)

    let space_pos = match(content, " ")
    let end_line = strpart(content, 0, space_pos)
    let content = strpart(content, space_pos + 1)

    let space_pos = match(content, " ")
    let save_num_2 = strpart(content, 0, space_pos)
    let content = strpart(content, space_pos + 1)

    let space_pos = match(content, " ")
    let access_code = strpart(content, 0, space_pos)
    let content = strpart(content, space_pos + 1)

    let space_pos = match(content, " ")
    if space_pos == -1
      "no more space => fun_name is the last item => no class name
      let fun_name = content
      let class_name = ""
    else
      let fun_name = strpart(content, 0, space_pos)
      let class_name = strpart(content, space_pos + 1)
    endif

    "call <SID>Print_log("access_code: ".access_code."  class_name: ".class_name."  fun_name: ".fun_name)

    let temp = <SID>Get_statics(class_name, fun_name)
    
    if temp == 0
      if (g:private_switch_flag == 0 && access_code == 0) || g:private_switch_flag == 1
        call <SID>Print_append(begin_line, class_name, fun_name)
        call <SID>Gen_fun_test(class_name, fun_name)
      endif
    endif

    let cur_row = cur_row + 1
  endwhile
  w
  exec 'edit '.g:source_path
endfunction

function! <SID>Gen_statics()
  if system("test -e ".g:info_file."; echo $?") != 0
    "call <SID>Print_log("info_file: ".g:info_file." not exist")
    return
  endif

  w
  exec 'edit '.g:info_file
  let cur_row = 1
  let last_row = line("$")
  "call <SID>Print_log("cur_row: ".cur_row." last_row: ".last_row)

  while cur_row <= last_row
    w
    exec 'edit '.g:info_file
    let content = getline(cur_row)

    let space_pos = match(content, " ")
    let begin_line = strpart(content, 0, space_pos)
    let content = strpart(content, space_pos + 1)

    let space_pos = match(content, " ")
    let save_num_1 = strpart(content, 0, space_pos)
    let content = strpart(content, space_pos + 1)

    let space_pos = match(content, " ")
    let end_line = strpart(content, 0, space_pos)
    let content = strpart(content, space_pos + 1)

    let space_pos = match(content, " ")
    let save_num_2 = strpart(content, 0, space_pos)
    let content = strpart(content, space_pos + 1)

    let space_pos = match(content, " ")
    let access_code = strpart(content, 0, space_pos)
    let content = strpart(content, space_pos + 1)

    let space_pos = match(content, " ")
    if space_pos == -1
      "no more space => fun_name is the last item => no class name
      let fun_name = content
      let class_name = ""
    else
      let fun_name = strpart(content, 0, space_pos)
      let class_name = strpart(content, space_pos + 1)
    endif

    "call <SID>Print_log("access_code: ".access_code."  class_name: ".class_name."  fun_name: ".fun_name)

    let cur_row = cur_row + 1
    
    if class_name == "" && fun_name == "main"
      continue
    endif

    if g:private_switch_flag == 0 && access_code != 0
      continue
    endif
    
    call <SID>Print_statics(begin_line, class_name, fun_name)
  endwhile

  w
  exec 'edit '.g:source_path
endfunction

function! <SID>Gen_test_code()
  if system("test -e ".g:info_file."; echo $?") != 0
    "call <SID>Print_log("info_file: ".g:info_file." not exist")
    return
  endif

  w
  exec 'edit '.g:info_file
  let cur_row = 1
  let last_row = line("$")
  "call <SID>Print_log("cur_row: ".cur_row." last_row: ".last_row)

  while cur_row <= last_row
    w
    exec 'edit '.g:info_file
    let content = getline(cur_row)

    let space_pos = match(content, " ")
    let begin_line = strpart(content, 0, space_pos)
    let content = strpart(content, space_pos + 1)

    let space_pos = match(content, " ")
    let save_num_1 = strpart(content, 0, space_pos)
    let content = strpart(content, space_pos + 1)

    let space_pos = match(content, " ")
    let end_line = strpart(content, 0, space_pos)
    let content = strpart(content, space_pos + 1)

    let space_pos = match(content, " ")
    let save_num_2 = strpart(content, 0, space_pos)
    let content = strpart(content, space_pos + 1)

    let space_pos = match(content, " ")
    let access_code = strpart(content, 0, space_pos)
    let content = strpart(content, space_pos + 1)

    let space_pos = match(content, " ")
    if space_pos == -1
      "no more space => fun_name is the last item => no class name
      let fun_name = content
      let class_name = ""
    else
      let fun_name = strpart(content, 0, space_pos)
      let class_name = strpart(content, space_pos + 1)
    endif

    "call <SID>Print_log("access_code: ".access_code."  class_name: ".class_name."  fun_name: ".fun_name)

    if g:private_switch_flag == 0
      if access_code == 0
        call <SID>Gen_fun_test(class_name, fun_name)
      endif
    else
      call <SID>Gen_fun_test(class_name, fun_name)
    endif
        
    let cur_row = cur_row + 1
  endwhile
  w
  exec 'edit '.g:source_path
endfunction

"gentestcode.sh 调用的测试代码生成入口
function! <SID>Init_all()
	w
	call system('echo gencode#singlefile#$(date "+%Y-%m-%d %H:%M:%S") >> ~/.btest/.bteststat_$(date "+%Y-%m-%d").data')
	let comake_flag = 0
	let temp = system('test -e ./*.prj; echo $?')
	let temp2 = system('test -e ./COMAKE; echo $?')
	if temp == 0
		let comake_flag = 1
		call system("mkdir -p ".g:relate_path.'/'.g:test_dir_str)
    elseif temp2 == 0
        let comake_flag = 2
        call system("mkdir -p ".g:relate_path.'/'.g:test_dir_str)
	else
		let temp = system('test -e '.g:relate_path.'/'.g:test_dir_str.'Makefile; echo $?')
		if temp != 0
			call <SID>Gen_makefile()
		endif
	endif

	let g:source_path = expand("%:p")	
	let g:source_name = bufname("%")
	let g:source_name = substitute( g:source_path, '.*/', '', '')

	if system ('test -e '.g:object_name.' ; echo $?') == 0
		echo "目标文件已经存在，不再进行全生成!"
		if comake_flag == 1
			call <SID>Gen_comake_file()
        elseif comake_flag == 2
            call <SID>Gen_comake2_file()
		endif
		return 
	endif

  let tmp_file = ".tmp/tmpfile"
  let g:info_file = ".tmp/".g:source_name.".info"
  "call <SID>Print_log("source_path: ".g:source_path." source_name:".g:source_name)
        
  call system("mkdir -p .tmp")
  call system("btest_parser ".g:source_path) 
  call system("sort -n ".tmp_file." > ".g:info_file."; rm ".tmp_file) 
              
  let g:create_flag = 0
  call <SID>Gen_test_code()
  
	exec 'normal \<ESC>'
	if comake_flag == 1
		call <SID>Gen_comake_file()
    elseif comake_flag == 2
		call <SID>Gen_comake2_file()
	endif
	echo "Init_all done"
endfunction


"追加单个case的外部接口，使用vim快捷键调用
function! <SID>Proc_create_test()
	w
	call system('echo gencode#singlefunc#$(date "+%Y-%m-%d %H:%M:%S") >> ~/.btest/.bteststat_$(date "+%Y-%m-%d").data')
	let comake_flag = 0
	let temp = system('test -e ./*.prj; echo $?')
    let temp2 = system('test -e ./COMAKE; echo $?')
	if temp == 0
		let comake_flag = 1
		call system("mkdir -p ".g:relate_path.'/'.g:test_dir_str)
    elseif temp2 == 0
        let comake_flag = 2
        call system("mkdir -p ".g:relate_path.'/'.g:test_dir_str)
	else
		let temp = system('test -e '.g:relate_path .'/'.g:test_dir_str.'Makefile; echo $?')
		if temp != "0"
			call <SID>Gen_makefile()
		endif
	endif

	let g:source_path = expand("%:p")	
	let g:source_name = bufname("%")
	let g:source_name = substitute( g:source_path, '.*/', '', '')

	let temp = system('test -d '.g:relate_path.'/'.g:test_dir_str.'; echo $?')
	if temp != "0"
		call system('mkdir -p '.g:relate_path.'/'.g:test_dir_str)
	endif

	let g:flag_c_cpp = 0
	if match(expand("%:p:t"), '\.c') >=0 
		let g:flag_c_cpp = 1	
	endif

	let fun_reg = <SID>Get_fun_reg()
	let line = getline(".")
	"echo line
	let start = match(line, fun_reg, 0) 
	if start < 0
		echo "none function"
		call <SID>Proc_create_class_test()
		return
	endif
	call cursor(line, start + 1)
	let fun_name = <SID>Get_function_name( start )

	if system ('test -e '.g:object_name.' ; echo $?') != 0
		echo "object_file not find"
		call <SID>Create_file()
	endif
	if fun_name == ""
		echo "none function"
		call <SID>Proc_create_class_test()
		return
	else
		let class_name = <SID>Get_colon_classname(fun_name)
		if g:flag_c_cpp == 1 && class_name != "" 
			call <SID>Create_test(class_name, fun_name)
			return
		endif
		let class_name = <SID>Get_class_name()
		"echo "class_name :".class_name
		"echo "return_type :".g:return_type
		"echo "function name :".fun_name
		"echo '----------'
		if  g:return_type == ""
			if class_name == fun_name  
				call <SID>Create_test(class_name, fun_name)
			elseif class_name != "" && class_name != '#is_private_fun' && <SID>Is_class_fun() == 1
				call <SID>Create_test(class_name, fun_name)
			elseif class_name == "" && <SID>Not_in_codeblock('{','','}') == 1
				call <SID>Create_test("", fun_name)
			endif
		elseif class_name != "" && class_name != '#is_private_fun' && <SID>Is_class_fun() == 1
			call <SID>Create_test(class_name, fun_name)
		elseif class_name == "" && g:return_type != 'throw' && g:return_type != 'new'
			call <SID>Create_test("", fun_name)
		endif
	endif
	call <SID>For_test()
	if comake_flag == 1
		call <SID>Gen_comake_file()
    elseif comake_flag == 2
		call <SID>Gen_comake2_file()
	endif
endfunction

"追加单个class的测试代码的外部接口，使用vim快捷键调用
function! <SID>Proc_create_class_test()
	w
	call system('echo gencode#singleclass#$(date "+%Y-%m-%d %H:%M:%S") >> ~/.btest/.bteststat_$(date "+%Y-%m-%d").data')
	let comake_flag = 0
    let temp = system('test -e ./*.prj; echo $?')
    let temp2 = system('test -e ./COMAKE; echo $?')
	if temp == 0
		let comake_flag = 1
		call system("mkdir -p ".g:relate_path.'/'.g:test_dir_str)
    elseif temp2 == 0
        let comake_flag = 2
        call system("mkdir -p ".g:relate_path.'/'.g:test_dir_str)
	else
		let temp = system('test -e '.g:relate_path.'/'.g:test_dir_str.'Makefile; echo $?')
		if temp != "0"
			call <SID>Gen_makefile()
		endif
	endif

	let g:source_path = expand("%:p")	
	let g:source_name = bufname("%")
	let g:source_name = substitute( g:source_path, '.*/', '', '')
	let fun_reg = <SID>Get_fun_reg()

	if system ('test -e '.g:object_name.' ; echo $?') != 0
		call <SID>Create_file()
	endif

	let line = getline(".")
	let start = match(line, '\k', 0)
	if start < 0
		echo "no class"
		return 
	endif 
	let keyword =  strpart(line, start, 5)
	if keyword != 'class'
		echo "no class"
		return
	endif
	let ori_row = line(".")
	let ori_colomn = col(".")
	call cursor(ori_row, start + 5)
	let left_bracket_row = search( '{', 'W')
	if left_bracket_row <= 0 
		echo "no class"
		return
	endif
	let left_bracket_colomn = col(".")
	let right_bracket_row = searchpair('{', '', '}', 'W')
	if right_bracket_row <= 0 
		echo "no class"
		return
	endif
	let right_bracket_colomn = col(".")
	call cursor(left_bracket_row, left_bracket_colomn)
	while 1
		let row = <SID>Search_inline(fun_reg,'cW',right_bracket_row)
		if row <= 0
			break
		endif
		let fun_name = <SID>Get_function_name( col(".") - 1)
		"echo fun_name
		if fun_name !=""
			let class_name = <SID>Get_class_name()
			if  g:return_type == ""
				if class_name == fun_name  
					call <SID>Create_test(class_name, fun_name)
				elseif class_name != "" && class_name != '#is_private_fun' && <SID>Is_class_fun() == 1
					call <SID>Create_test(class_name, fun_name)
				elseif class_name == "" && <SID>Not_in_codeblock('{','','}') == 1
					call <SID>Create_test("", fun_name)
				endif
			elseif class_name != "" && class_name != '#is_private_fun' && <SID>Is_class_fun() == 1
				call <SID>Create_test(class_name, fun_name)
			elseif class_name == "" &&  g:return_type != 'throw' && g:return_type != 'new'
				call <SID>Create_test("", fun_name)
			endif
		endif
		if row == right_bracket_row
			break
		endif
		call cursor(row , col('$'))
	endwhile
	call cursor( ori_row, ori_colomn)
	if comake_flag == 1
		call <SID>Gen_comake_file()
    elseif comake_flag == 2
		call <SID>Gen_comake2_file()
	endif
	exec 'normal \<ESC>'
	echo 'create class test done!'
endfunction

"代码跳转的接口，由vim快捷键调用
function! <SID>Proc_jumpto_testcode()
	w
	call system('echo gencode#jumpsource#$(date "+%Y-%m-%d %H:%M:%S") >> ~/.btest/.bteststat_$(date "+%Y-%m-%d").data')
	let file_name = expand("%:t")

	if match( expand("%:t"), 'test_.*\.cpp') == 0
		b# 
		return
	endif

	let g:source_path = expand("%:p")	
	let g:source_name = bufname("%")
	let g:source_name = substitute( g:source_path, '.*/', '', '')

	let temp = system('test -d '.g:relate_path.'/'.g:test_dir_str.'; echo $?')
	if temp != "0"
		call system('mkdir -p '.g:relate_path.'/'.g:test_dir_str)
	endif

	let g:flag_c_cpp = 0
	if match(expand("%:p:t"), '\.c') >=0 
		let g:flag_c_cpp = 1	
	endif

	let fun_reg = <SID>Get_fun_reg()

	let line = getline(".")
	"echo line
	let start = match(line, fun_reg, 0) 

	let fun_name = ""
	if start >= 0
		call cursor(line, start + 1)
		let fun_name = <SID>Get_function_name( start )
	endif

	if system ('test -e '.g:object_name.' ; echo $?') != 0
		echo "object_file not find"
		call <SID>Create_file()
	endif

	if fun_name == ""
		let class_name = <SID>Get_class_name_inline()
		if class_name != ""
			"echo class_name
			"echo class_name
			call <SID>Jump_class_testcode('class\s\+test_'.class_name.'_')
		else
			echo "none function and none class"
		endif
		return
	else
		let class_name = <SID>Get_colon_classname(fun_name)
		if g:flag_c_cpp == 1 && class_name != "" 
			call <SID>Jump_testcode(class_name, fun_name)
			return
		endif
		let class_name = <SID>Get_class_name()
		"echo "class_name :".class_name
		"echo "return_type :".g:return_type
		"echo "function name :".fun_name
		"echo <SID>Is_class_fun()
		"echo '----------'

		if  g:return_type == ""
			if class_name == fun_name  
				call <SID>Jump_testcode(class_name, fun_name)
			elseif class_name != "" && class_name != '#is_private_fun' && <SID>Is_class_fun() ==1 
				call <SID>Jump_testcode(class_name, fun_name)
			elseif class_name == "" && <SID>Not_in_codeblock('{','','}') == 1
				call <SID>Jump_testcode("", fun_name)
			endif
		elseif class_name != "" && class_name != '#is_private_fun' && <SID>Is_class_fun() == 1
			call <SID>Jump_testcode(class_name, fun_name)
		elseif class_name == "" && g:return_type != 'throw' && g:return_type != 'new'
			call <SID>Jump_testcode("", fun_name)
		else
			echo "no jump point!"
		endif

	endif
endfunction


function! <SID>Proc_backto_origincode()
	bpre
endfunction

"打印统计的接口，由vim快捷键调用
function! <SID>List_statics()
	w
	call system('echo gencode#liststatics#$(date "+%Y-%m-%d %H:%M:%S") >> ~/.btest/.bteststat_$(date "+%Y-%m-%d").data')
	call system('rm -f .statics_temp')

	let g:source_path = expand("%:p")	
	let g:source_name = bufname("%")
	let g:source_name = substitute( g:source_path, '.*/', '', '')
	let fun_reg = <SID>Get_fun_reg()

	"if object file not exsits , return
	if system ('test -e '.g:object_name.' ; echo $?') == 1
		echo "目标文件 ".g:object_name ." 不存在"
		echo "List statics done"
		return 
	endif

  let tmp_file = ".tmp/tmpfile"
  let g:info_file = ".tmp/".g:source_name.".info"
  "call <SID>Print_log("source_path: ".g:source_path." source_name:".g:source_name)
                
  "let temp = system("test -e ".g:info_file."; echo $?")
  "if temp != 0
    call system("mkdir -p .tmp")
    call system("btest_parser ".g:source_path) 
    call system("sort -n ".tmp_file." > ".g:info_file."; rm ".tmp_file)
  "endif
  
  call <SID>Gen_statics()
  
	exec 'normal \<ESC>'
	let temp = system('test -e .statics_temp ; echo $?')
	if temp == 0
		echo system( 'cat .statics_temp')
		echo "List statics done"
	else
		echo "no funtion to list"
	endif
endfunction

"追加测试代码中没有覆盖的函数的测试用例
function! <SID>Proc_append_new_suite()
	w
	call system('echo gencode#appendsuite#$(date "+%Y-%m-%d %H:%M:%S") >> ~/.btest/.bteststat_$(date "+%Y-%m-%d").data')
	call system('rm -f .statics_temp')
	let comake_flag = 0
	let temp = system('test -e ./*.prj; echo $?')
    let temp2 = system('test -e ./COMAKE; echo $?')
	if temp == 0
		let comake_flag = 1
		call system("mkdir -p ".g:relate_path.'/'.g:test_dir_str)
    elseif temp2 == 0
        let comake_flag = 2
        call system("mkdir -p ".g:relate_path.'/'.g:test_dir_str)
	else
		let temp = system('test -e '.g:relate_path.'/'.g:test_dir_str.'Makefile; echo $?')
		if temp != "0"
			call <SID>Gen_makefile()
		endif
	endif

	let g:source_path = expand("%:p")	
	let g:source_name = bufname("%")
	let g:source_name = substitute( g:source_path, '.*/', '', '')
	
  let g:create_flag = 0
	if system('test -e '.g:object_name.'; echo $?') == 0
		let g:create_flag = 1
	endif

  let tmp_file = ".tmp/tmpfile"
  let g:info_file = ".tmp/".g:source_name.".info"
  "call <SID>Print_log("append source_path: ".g:source_path." source_name: ".g:source_name)

  call system("mkdir -p .tmp")
  call system("btest_parser ".g:source_path)
  call system("sort -n ".tmp_file." > ".g:info_file."; rm ".tmp_file)
                          
  call <SID>Append_new_suite()
  
  exec 'normal \<ESC>'
	if comake_flag == 1
		call <SID>Gen_comake_file()
    elseif comake_flag == 2
		call <SID>Gen_comake2_file()
	endif
	let temp = system('test -e .statics_temp ; echo $?')
	if temp == 0
		echo system( 'cat .statics_temp')
		echo "Append new suite done"
	else
		echo "no funtion to append"
	endif
endfunction

"支持private，protected函数的测试
function! <SID>Private_support()
  let base = getcwd().'/'.g:relate_path.'/'.g:test_dir_str
  "echo base
  call system("private_support.sh ".base)
endfunction

"私有函数测试的开关
function! <SID>Private_switch()
	if g:private_switch_flag == 0
		echo "** 私有和保护函数测试开启!"
    "此功能会对源代码进行修改，请谨慎使用!"
		echo "** 再次按下该快捷键关闭此功能"
		let g:private_switch_flag = 1
    call <SID>Private_support()
	else
		echo "** 私有和保护函数测试关闭!"
		let g:private_switch_flag = 0
	endif
endfunction

"class to class 开关
function! <SID>Class_to_class_switch()
	if g:class_to_class_flag == 0
		echo "** 开启class to class 模式"
		echo "** 再次按下该快捷键切换到function to class 模式"
		let g:class_to_class_flag = 1
		if system( "test -e btest.conf ; echo $? ") == 0
			call system(g:change_conf. "gen_mode ". "class_to_class")
		else
			call system('touch .class_to_class')
		endif
	else
		echo "** 开启function to class 模式"
		echo "** 再次按下该快捷键切换到class to class 模式"
		let g:class_to_class_flag = 0
		if system( "test -e btest.conf ; echo $? ") == 0
			call system(g:change_conf. "gen_mode ". "function_to_class")
		else
			call system('rm -f .class_to_class')
		endif
	endif
endfunction
  
function! <SID>Print_help_info()
	echo "btest快捷键助信息:"
	echo "  \\j  全文件扫描生成"
	echo "  \\k  当前行函数或类生成"
	echo "  \\l  当前行类生成"
	echo "  ctrl+j 被测代码中，当前行函数和类跳转"
	echo "  \\p  打印全文件函数对应的case数目"
	echo "  \\o  追加测试代码没有的函数的用例"
	echo "  \\i  私有函数测试开关"
	echo "  \\u  class to class 模式开关"
	echo "  \\h  快捷键帮助信息"
endfunction


"#####请不要更改这段注释,请只修改下面的快捷键，而不修改其格式，请不要在下面增添代码和注释
map <unique> <C-J> :call <SID>Proc_jumpto_testcode()<CR>
map <unique> \h :call <SID>Print_help_info()<CR>
map <unique> \i :call <SID>Private_switch()<CR>
map <unique> \j :call <SID>Init_all()<CR>
map <unique> \k :call <SID>Proc_create_test()<CR>
map <unique> \l :call <SID>Proc_create_class_test()<CR>
map <unique> \o :call <SID>Proc_append_new_suite()<CR>
map <unique> \p :call <SID>List_statics()<CR>
map <unique> \u :call <SID>Class_to_class_switch()<CR>
