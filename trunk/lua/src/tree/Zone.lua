-- �ඨ��
Zone = Node:new({
	--[�̳�]��������
	---------------------------
		-- ����
		type = NODE.TYPE.ZONE,
		-- ״̬
		state = NODE.STATE.NORMAL,

	--��������
	---------------------------
		maxOnline = 0,
		maxTeam = 0,
		minUserForTeam = 0,
		maxUserForTeam = 0,
});

-- ��ʼ������
function Zone:init()
	-- ˽������
	self._argFreeIndex = {};		-- ��������
	self._nameSet = {};
	self._indexSet ={};
	self._cache = {};

	for i = self.maxTeam,1,-1 do
		table.insert(self._argFreeIndex,i);
	end
end

-- ����ӽ��
function Zone:appendChild(n)
	-- �����������
	n.index = table.remove(self._argFreeIndex);
	-- ���ø��ӿ�
	Node.appendChild(self,n);
end

-- ɾ���ӽ��
function Zone:removeChild(n)
	-- �����������
	table.insert(self._argFreeIndex,n.index);
	-- ���ø��ӿ�
	Node.removeChild(self,n);
end

-- �Ƿ�����
function Zone:isAppendChild()
	if self.numChildren >= self.maxTeam then
		return true;
	else
		return false;
	end
end

-- �Ƿ�����
function Zone:isMaxOnline()
	local map = self[TreeEvent.ZONE_UPDATE];
	if not map then
		return false;
	end
	if map.length < self.maxOnline then
		return false
	end
	return true;
end

-- ������ʾ
function Zone:updateDisplay(msg,times,node)
	if node then
		self._cache[node] = msg;
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

