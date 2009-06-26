-- ������
NODE = {
	-- �������
	TYPE = {
		ROOT = 1,				-- �����
		ZONE = 2,				-- �ռ���
		TEAM = 3,				-- ������
		USER = 4,				-- �û����
	},
	-- ״̬
	STATE = {
		NORMAL		= 1,		-- ����
		HIDDEN		= 2,		-- ����
		RELEASE		= 3,		-- �ͷ�

		WAIT		= 5,		-- �ȴ�
		READY		= 6,		-- ׼��
		PLAY		= 7,		-- ��Ϸ

		SYNC_TIME	= 8,		-- ͬ��ʱ����
	},
	-- ���
	STATUS = {
		UNDEFINED	= 1,		-- δ��ȷ
		GUEST		= 2,		-- �ο�
		MEMBER		= 3,		-- ��Ա
	},
	-- ����״̬
	NETWORK = {
		NORMAL		= 1,		-- ����
		OFFLINE		= 0,		-- ����
	},
}
