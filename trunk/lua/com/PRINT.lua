-- ���
PRINT = {
	-- ��ӡ��Ŀ
	ITEM = function(word,var)
		io.write('|- [lua]'.. word ..':'.. var ..'\n');
	end,
	-- ��ӡ����
	ERROR = function(str)
		io.write('!='.. str ..'\n');
	end,
	-- ��ӡ��Ϣ
	MSG = function(str)
		io.write('[MSG] '.. str ..'\n');
	end
}

