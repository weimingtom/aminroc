-- ����û����ֳ���(���� / 2)
MAX_USER_NAME_LEN = 20;

-- ���������ֳ���(���� / 2)
MAX_TEAM_NAME_LEN = 20;

-- ����������ֳ���(���� / 2)
MAX_TEAM_CHAT_LEN = 60;

-- ��Կ�ļ�
KEY = 'keys/090427';

-- ����ģʽ
__DEBUG__ = true;

-- �ṹ����
TREE_CONFIG{
	['TestDemo'] = {
		maxOnline = 9000,		-- �����������
		maxTeam = 1500,			-- �����ö���
		minUserForTeam = 2,		-- ������Ϸ����
		maxUserForTeam = 8,		-- �����Ϸ����
	},
	['Bomber'] = {
		maxOnline = 9000,
		maxTeam = 1500,
		minUserForTeam = 2,
		maxUserForTeam = 4,
	},
}
