-- �ඨ��
User = Node:new({
	--[�̳�]��������
	---------------------------
		-- ����
		type = NODE.TYPE.USER,
		-- ״̬
		state = NODE.STATE.NORMAL,
		-- ��ݱ�ʶ
		status	= NODE.STATUS.GUEST,
		-- ����״̬
		network = NODE.NETWORK.NORMAL,

	--��������
	---------------------------
		-- �������ڵ�
		tree = 0,
		-- socket
		socket = 0,
		-- ����
		msg = '',
		-- λ��
		pos = USER.POS.FREE,
});

-- ��ʽ��
function User:toString()
	return self.state .._2_.. self.index .._2_.. self.name;
end

-- ������ʾ
function User:updateDisplay(msg,times,node)
	if node and msg then
		self._cache[root] = msg;
		local t = {};
		for k,v in pairs(self._cache) do
			table.insert(t,v);
		end
		self.style = table.concat(t,_1_);
	end
	-- �ϴ�����
	if times > 0 then
		-- ���ø��ӿ�
		local parent = self.parentNode;
		if parent then
			parent:updateDisplay(msg,times - 1,self);
		end
	end
end
