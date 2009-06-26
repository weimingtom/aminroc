-- �ඨ��
Root = Node:new({
	--[�̳�]��������
	---------------------------
		-- ����
		type = NODE.TYPE.ROOT,
		-- ״̬
		state = NODE.STATE.NORMAL,

	--[�̳�]�ӿ�
	---------------------------
		_nameSet = {},
		_indexSet ={},
});
-- ��һʵ��
ROOT = Root:new();

-- �ṹ����
------------------------------
function TREE_CONFIG(obj)
	for key,value in pairs(obj) do
		-- �����ռ����
		local z = Zone:new();
		-- ��������
		z.maxOnline = value.maxOnline;
		z.maxTeam = value.maxTeam;
		z.minUserForTeam = value.minUserForTeam;
		z.maxUserForTeam = value.maxUserForTeam;
		-- ����״̬
		z.name = key;
		z.state = NODE.STATE.NORMAL;
		z:updateInnerText();
		z:init();
		-- ����ӽ��
		ROOT:appendChild(z);
	end

	PRINT.ITEM("game number",ROOT.numChildren);
end
