-- �ඨ��
Team = Node:new({
	--[�̳�]��������
	---------------------------
		-- ����
		type = NODE.TYPE.TEAM,
		-- ״̬
		state = NODE.STATE.NORMAL,

	--��������
	---------------------------
		minUserForTeam = 0,
		maxUserForTeam = 0,
		time = 0,
		owner = 0,
});

-- ��ʼ������
function Team:init()
	-- ˽������
	self._argFreeIndex = {};	-- ��������
	self._nameSet = {};
	self._indexSet = {};
	self._cache = {};

	for i = self.maxUserForTeam,1,-1 do
		table.insert(self._argFreeIndex,i);
	end
end

-- ����ӽ��
function Team:appendChild(n)
	-- �����������
	n.index = table.remove(self._argFreeIndex);
	-- ���ø��ӿ�
	Node.appendChild(self,n);
end

-- ɾ���ӽ��
function Team:removeChild(n)
	-- �����������
	table.insert(self._argFreeIndex,1,n.index);
	-- ���ø��ӿ�
	Node.removeChild(self,n);
end

-- �Ƿ���Ա
function Team:isAppendChild()
	if self.numChildren >= self.maxUserForTeam then
		return true;
	else
		return false;
	end
end

-- �û���Ϣ
function Team:OnUserMsg()

end

-- �㲥�¼�
function Team:broadcast(dataEx)
	for k,v in pairs(self._indexSet) do
		CNetSend(v.socket,dataEx);
	end
end

-- �㲥�¼�(����ָ��֮��)
function Team:broadcastButThis(user,dataEx)
	for k,v in pairs(self._indexSet) do
		if k ~= user.index then
			CNetSend(v.socket,dataEx);
		end
	end
end

-- �㲥�¼�(����״̬)
function Team:broadcastByState(dataEx,state)
	for k,v in pairs(self._indexSet) do
		if v.state == state then
			CNetSend(v.socket,dataEx);
		end
	end
end

-- �㲥�¼�(����״̬)(����ָ��֮��)
function Team:broadcastByStateButThis(exception,dataEx,state)
	for k,v in pairs(self._indexSet) do
		if v ~= exception and v.state == state then
			CNetSend(v.socket,dataEx);
		end
	end
end

-- ȫ������ָ��״̬
function Team:isAll(state)
	for k,v in pairs(self._indexSet) do
		if v.state ~= state then
			return false
		end
	end
	return true;
end

-- ȫ��������ָ��״̬
function Team:isAllNot(state)
	for k,v in pairs(self._indexSet) do
		if v.state == state then
			return false
		end
	end
	return true;
end

-- ��ʽ��
function Team:toString()
	return self.state .._2_.. self.index .._2_.. self.name .._2_.. self.numChildren .._2_.. self.maxUserForTeam;
end

-- ������ʾ
function Team:updateDisplay(msg,time,node)
	if node then
		self._cache[node] = msg;
		local t = {};
		for k,v in pairs(self._cache) do
			table.insert(t,v);
		end
		self.style = table.concat(t,_1_);
	end
	-- �ϴ�����
	if time > 0 then
		-- ���ø��ӿ�
		local parent = self.parentNode;
		if parent then
			parent:updateDisplay(msg,time - 1,self);
		end
	end
end

-- ���������ӽ��
function Team:setAllChildState(state)
	for k,v in pairs(self._indexSet) do
		v.state = state;
		v:updateDisplay(v:toString(),1);
	end
end

-- ���������ӽ��
function Team:setAllChildPos(pos)
	for k,v in pairs(self._indexSet) do
		v.pos = pos;
	end
end


