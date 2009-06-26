-- �ඨ��
Node = {
	--��������
	---------------------------
		type = 0,			-- ����
		index = 0,			-- ��Ը�����������
		name = 0,			-- ����
		state = 0,			-- ״̬
		status = 0,			-- ���
		network = 0,		-- ����״̬
		style = '',			-- ��ʽ
		numChildren = 0,	-- �ӽ������
		parentNode = 0,		-- ���������

	--�ڲ�����
	---------------------------
		-- ��������
		_refCount = 0,

	-- �ӿ�
	---------------------------
		_nameSet = nil,
		_indexSet = nil,
		_cache = nil,
}

-- ��������
function Node:new(struct)
	local s = struct or {};
	setmetatable(s,self);
	self.__index = self;
	return s;
end

-- ����ӽ��
function Node:appendChild(n)
	-- ���
	if n.parentNode ~= 0 then
		n.parentNode:removeChild(n);
	end
	-- ����
	self.numChildren = self.numChildren + 1;
	self._nameSet[n.name] = n;
	self._indexSet[n.index] = n;
	-- �ӽ��
	n.parentNode = self;
	n._refCount = n._refCount + 1;
end

-- ɾ���ӽ��
function Node:removeChild(n)
	-- ����
	self.numChildren = self.numChildren - 1;
	self._nameSet[n.name] = nil;
	self._indexSet[n.index] = nil;
	-- �ӽ��
	n.parentNode = 0;
	n._refCount = n._refCount - 1;
end

-- ��¡
function Node:clone()
	return false;
end

-- ����¼�����
function Node:addEventListener(event)
	local tree = self.tree;
	local map = tree[event];

	if not map then
		tree[event] = {};
		map = tree[event];
		map.set = {}
		map.length = 0;
	end

	map.set[self] = 1;
	map.length = map.length + 1;
	return true;
end

-- ɾ���¼�����
function Node:removeEventListener(event)
	local tree = self.tree;
	local map = tree[event];

	map.set[self] = nil;
	map.length = map.length - 1;
end

-- �ɷ��¼�
function Node:dispatchEvent(event,dataEx)
	local tree = self;
	local set = tree[event].set;

	for k,v in pairs(set) do
		CNetSend(k.socket,dataEx);
	end
end

-- �ַ�����ʽ��
function Node:toString()
	return nil;
end

-- ��������
function Node:setAttribute(name,v)
	rawset(self,name,v);
end

-- �Ƴ�����
function Node:removeAttribute(name)
	self[name] = nil;
end

-- ��ȡ����
function Node:getAttribute(name)
	return self[name];
end

-- �������ַ����ӽ��
function Node:getChildByName(name)
	return self._nameSet[name];
end

-- �������ַ����ӽ��
function Node:getChildByIndex(index)
	return self._indexSet[index];
end

-- ���ص�һ���ӽ��
function Node:firstChild()
	for k,v in pairs(self._indexSet) do
		return v;
	end
end


-- �����ڲ��ı�
function Node:updateInnerText()
end

-- �����ⲿ�ı�
function Node:updateOuterText()
end

-- ������ʾ
function Node:updateDisplay()
end
