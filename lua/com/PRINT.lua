-- 输出
PRINT = {
	-- 打印项目
	ITEM = function(word,var)
		io.write('|- [lua]'.. word ..':'.. var ..'\n');
	end,
	-- 打印错误
	ERROR = function(str)
		io.write('!='.. str ..'\n');
	end,
	-- 打印消息
	MSG = function(str)
		io.write('[MSG] '.. str ..'\n');
	end
}

