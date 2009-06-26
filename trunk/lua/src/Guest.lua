-- �ο�״̬
_G[NODE.STATUS.GUEST] = {

	-- �������
	[AEvent.REQUEST_TO .. USER.POS.FREE] = function(user,dataEx)
		-- �õ�����
		local cyp,msg = KEYER.make();
		-- 1.��������
		user.msg = msg;
		user.pos = USER.POS.VALIDATE;
		-- 2.������Ϣ
		CNetSend(user.socket,AEvent.REQUEST_TO .._EN_.. cyp);
	end,

	-- ��֤���
	[AEvent.VALIDATE_ID .. USER.POS.VALIDATE] = function(user,dataEx)
		local arg = dataEx:split(_1_);
		-- ��������
		if user.msg ~= arg[1] then
			CNetSend(user.socket,AEvent.ERROR_MSG);
			return 1;
		end
		-- ��������
		if not arg[2] or string.len(arg[2]) > MAX_USER_NAME_LEN then
			CNetSend(user.socket,AEvent.ERROR_USER_NAME);
			return 1;
		end
		-- 1.��������
		user.pos = USER.POS.WAIT;
		user.name = arg[2];
		-- 2.������Ϣ
		CNetSend(user.socket,AEvent.VALIDATE_ID);
	end,

	-- ����ռ�
	[AEvent.JOIN_ZONE .. USER.POS.WAIT] = function(user,dataEx)
		local zone = ROOT:getChildByName(dataEx);
		-- û�˿ռ�
		if not zone then
			CNetSend(user.socket,AEvent.NOTEXIST_ZONE);
			return;
		end
		-- �ռ�����
		if zone:isMaxOnline() then
			CNetSend(user.socket,AEvent.OVERFLOW_SOCKETS);
			return;
		end
		-- 1.��������
		user.pos = USER.POS.ZONE;
		user.tree = zone;
		-- 2.�����¼�
		user:addEventListener(TreeEvent.ZONE_UPDATE);
		-- 3.������Ϣ
		CNetSend(user.socket,AEvent.JOIN_ZONE .._EN_.. zone.maxTeam);
	end,

	-- ��ȡ�����б�
	[AEvent.TEAM_LIST .. USER.POS.ZONE] = function(user,dataEx)
		-- ��������
		-- CNetSend(user.socket,"2232153asd1452789c1000245211c100b34510cvb44511cvb14512cvb24513cvb34514cvb14515cvb44516cvb14517cvb14518cvb145219cvb14520cvb14521cvb14522cvb1455000end34");
		CNetSend(user.socket,AEvent.TEAM_NUMBER .._EN_.. user.tree.numChildren .._CB_.. AEvent.TEAM_LIST .._EN_.. user.tree.style);
	end,

	-- ��������
	[AEvent.CREATE_TEAM .. USER.POS.ZONE] = function(user,dataEx)
		-- �����Ƿ�̫��
		if not dataEx or string.len(dataEx) > MAX_TEAM_NAME_LEN then
			CNetSend(user.socket,AEvent.CREATE_TEAM_2);
			return;
		end
		-- �õ�����
		local zone = user.tree;
		-- zone�Ķ��������Ƿ�ﵽ����
		if zone:isAppendChild() then
			CNetSend(user.socket,AEvent.OVERFLOW_TEAM);
			return;
		end
		-- ��������
		local team = Team:new();
		-- 1.��������
		team.name = dataEx;
		team.minUserForTeam = zone.minUserForTeam;
		team.maxUserForTeam = zone.maxUserForTeam;
		team.time = CGetTime();
		team.state = NODE.STATE.WAIT;
		team.owner = 1;	-- ӵ����
		-- 2.��ʼ��
		team:init();

		-- 1.��ӽ��
		zone:appendChild(team);
		-- 2.�Զ��������
		_G[user.status][AEvent.JOIN_TEAM .. USER.POS.ZONE](user,team.index);
		-- 3.�ɷ��µĶ�������
		zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_NUMBER .._EN_.. zone.numChildren);
	end,

	-- �������
	[AEvent.JOIN_TEAM .. USER.POS.ZONE] = function(user,dataEx)

		-- �õ�����
		local zone = user.tree;
		local team = zone:getChildByIndex(tonumber(dataEx));

		-- �޴˶���
		if not team then
			CNetSend(user.socket,AEvent.NOTEXIST_TEAM);
			return;
		end
		-- ��Ա���
		if team:isAppendChild() then
			CNetSend(user.socket,AEvent.OVERFLOW_USER);
			return;
		end
		-- 1.��������¼�
		user:removeEventListener(TreeEvent.ZONE_UPDATE);
		-- 2.��������
		user.pos = USER.POS.TEAM;
		user.state = NODE.STATE.WAIT;
		-- 3.��ӽ��
		team:appendChild(user);
		-- 4.������Ϣ
		CNetSend(user.socket,AEvent.JOIN_TEAM .._EN_.. team.index .._1_.. user.index .._1_.. team.minUserForTeam .._1_.. team.maxUserForTeam .._1_.. team.name .._1_.. team.owner);

		-- 1.��ʽ����Ϣ
		local msg = user:toString();
		-- 2.������ʾ
		user:updateDisplay(msg,1);
		-- 3.�㲥�¼�
		team:broadcastButThis(user,AEvent.USER_LIST .._EN_.. msg);

		-- 1.��ʽ����Ϣ
		msg = team:toString();
		-- 2.������ʾ
		team:updateDisplay(msg,1);
		-- 3.�ɷ��¼�
		zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_LIST .._EN_.. msg);
	end,

	-- �˳�����
	[AEvent.EXIT_TEAM .. USER.POS.TEAM] = function(user,dataEx)

		local zone = user.tree;
		local team = user.parentNode;

		-- 1.��������
		user.state = NODE.STATE.RELEASE;
		-- 2.��ʽ����Ϣ
		local msg = user:toString();
		-- 3.������ʾ
		user:updateDisplay(nil,1);
		-- 4.ɾ���ڵ�
		team:removeChild(user);
		-- 5.�㲥�¼�
		team:broadcast(AEvent.USER_LIST .._EN_.. msg);

		-- �Ƿ�ӵ����
		if team.owner == user.index and team.numChildren ~= 0 then
			team.owner = team:firstChild().index;
			team:broadcast(AEvent.SWITCH_OWNER .._EN_.. team.owner);
		end

		-- 1.�ȴ�����
		if team.state == NODE.STATE.WAIT then

			-- 1.����Ϊ��
			if team.numChildren == 0 then
				-- 1.��������
				team.state = NODE.STATE.RELEASE;
				-- 2.��ʽ����Ϣ
				msg = team:toString();
				-- 3.������ʾ(���)
				team:updateDisplay(nil,1);
				-- 4.ɾ�����
				zone:removeChild(team);
				-- 5.�ɷ��ϲ��¼�
				local es = AEvent.TEAM_NUMBER .._EN_.. zone.numChildren .._CB_.. AEvent.TEAM_LIST .._EN_.. msg;
				zone:dispatchEvent(TreeEvent.ZONE_UPDATE,es);

			-- 2.����ʣ������ȫ��׼����
			elseif team:isAll(NODE.STATE.READY) and team.numChildren >= team.minUserForTeam then
				-- 1.���������ӽ��
				team:setAllChildState(NODE.STATE.PLAY);
				team:setAllChildPos(USER.POS.GAME);
				-- 2.�㲥�¼�
				team:broadcast(AEvent.PLAY);

				-- 1.��������
				team.state = NODE.STATE.HIDDEN;
				-- 2.��ʽ����Ϣ
				msg = team:toString();
				-- 3.������ʾ
				team:updateDisplay(nil,1);
				-- 4.�����¼�
				zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_LIST .._EN_.. msg);

			-- 3.������ʾ
			else
				-- 1.��ʽ����Ϣ
				msg = team:toString();
				-- 2.������ʾ
				team:updateDisplay(msg,1);
				-- 3.�ɷ��¼�
				zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_LIST .._EN_.. msg);
			end

		-- 2.��Ϸ����
		elseif team.state == NODE.STATE.HIDDEN then

			-- 1.����Ϊ��
			if team.numChildren == 0 then
				-- 1.������ʾ(���)
				team:updateDisplay(nil,1);
				-- 2.ɾ�����
				zone:removeChild(team);
				-- 3.�ɷ����������¼�
				zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_NUMBER .._EN_.. zone.numChildren);

			-- 2.��Ϸ����
			elseif team:isAllNot(NODE.STATE.PLAY) then
				-- 1.��������
				team.state = NODE.STATE.WAIT;
				-- 2.��ʽ����Ϣ
				msg = team:toString();
				-- 3.������ʾ
				team:updateDisplay(msg,1);
				-- 4.�����¼�
				zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_LIST .._EN_.. msg);
			end
		end

		-- ���ؿռ�
		if user.network == NODE.NETWORK.NORMAL then
			CNetSend(user.socket,AEvent.EXIT_TEAM);
			user.pos = USER.POS.ZONE;
			user:addEventListener(TreeEvent.ZONE_UPDATE);
		end
	end,

	-- �û��б�
	[AEvent.USER_LIST .. USER.POS.TEAM] = function(user,dataEx)
		CNetSend(user.socket,AEvent.USER_LIST .._EN_.. user.parentNode.style);
	end,

	-- ӵ��Ȩת��
	[AEvent.SWITCH_OWNER .. USER.POS.TEAM] = function(user,dataEx)
		local team = user.parentNode;
		if user.index == team.owner then
			local index = tonumber(dataEx);
			if index then
				team.owner = index;
				team:broadcast(AEvent.SWITCH_OWNER .._EN_.. team.owner);
			end
		else
			CNetSend(user.socket,AEvent.DENY_SWITCH_OWNER);
		end
	end,

	-- ׼��
	[AEvent.READY .. USER.POS.TEAM] = function(user,dataEx)
		local zone = user.tree;
		local team = user.parentNode;

		if user.state ~= NODE.STATE.WAIT then
			CNetSend(user.socket,AEvent.ISNOT_WAIT_STATUS);
			return;
		end

		-- 1.��������
		user.state = NODE.STATE.READY;
		-- 2.��ʽ����Ϣ
		local msg = user:toString();
		-- 3.������ʾ
		user:updateDisplay(msg,1);
		-- 4.�㲥�¼�
		team:broadcast(AEvent.USER_LIST .._EN_.. msg);
		-- 5.������Ϣ
		CNetSend(user.socket,AEvent.READY);

		-- ����ʣ������ȫ��׼����
		if team:isAll(NODE.STATE.READY) and team.numChildren >= team.minUserForTeam then
			-- 1.���������ӽ��
			team:setAllChildState(NODE.STATE.PLAY);
			team:setAllChildPos(USER.POS.GAME);
			-- 2.�㲥�¼�
			team:broadcast(AEvent.PLAY);

			-- 1.��������
			team.state = NODE.STATE.HIDDEN;
			-- 2.��ʽ����Ϣ
			msg = team:toString();
			-- 3.������ʾ
			team:updateDisplay(nil,1);
			-- 4.�����¼�
			zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_LIST .._EN_.. msg);
		end
	end,

	-- ȡ��
	[AEvent.CANCEL .. USER.POS.TEAM] = function(user,dataEx)
		local team = user.parentNode;

		if user.state ~= NODE.STATE.READY then
			CNetSend(user.socket,AEvent.ISNOT_READY_STATUS);
			return;
		end

		-- 1.��������
		user.state = NODE.STATE.WAIT;
		-- 2.��ʽ����Ϣ
		local msg = user:toString();
		-- 3.������ʾ
		user:updateDisplay(msg,1);
		-- 4.�㲥�¼�
		team:broadcast(AEvent.USER_LIST .._EN_.. msg);
		-- 5.������Ϣ
		CNetSend(user.socket,AEvent.CANCEL);
	end,

	-- ����
	[AEvent.CHAT .. USER.POS.TEAM] = function(user,dataEx)
		if not dataEx or string.len(dataEx) > MAX_TEAM_CHAT_LEN then
			CNetSend(user.socket,AEvent.ERROR_CHAT_DATA);
			return;
		end
		local team = user.parentNode;
		team:broadcast(AEvent.CHAT .._EN_.. user.index .._1_.. dataEx);
	end,

	-- ָ������
	[AEvent.CHAT_TO .. USER.POS.TEAM] = function(user,dataEx)
		local team = user.parentNode;
		local arg = dataEx:split(_1_);
		-- ������
		if not arg[2] or string.len(arg[2]) > MAX_TEAM_CHAT_LEN then
			CNetSend(user.socket,AEvent.ERROR_CHAT_DATA);
			return;
		end
		-- �޶���
		local goal = team:getChildByIndex(tonumber(arg[1]));
		if not goal then
			CNetSend(user.socket,AEvent.NOTEXIST_CHAT_OBJECT .._EN_.. arg[2]);
			return;
		end
		-- ���
		if goal == user then
			CNetSend(user.socket,AEvent.ERROR_CHAT_OBJECT);
			return;
		end
		CNetSend(user.socket,AEvent.CHAT_TO .._EN_.. user.index .._1_.. goal.index .._1_.. arg[2]);
		CNetSend(goal.socket,AEvent.CHAT_TO .._EN_.. user.index .._1_.. goal.index .._1_.. arg[2]);
	end,

	-- �߳��û�
	[AEvent.REMOVE .. USER.POS.TEAM] = function(user,dataEx)
		local team = user.parentNode;
		local index = tonumber(dataEx);
		if not index or index == user.index then
			CNetSend(user.socket,AEvent.DENY_REMOVE);
			return;
		end
		if user.index ~= team.owner then
			CNetSend(user.socket,AEvent.DENY_REMOVE);
			return;
		end
		local goal = team:getChildByIndex(index);
		if not goal then
			CNetSend(user.socket,AEvent.DENY_REMOVE);
			return;
		end
		_G[goal.status][AEvent.EXIT_TEAM .. USER.POS.TEAM](goal,nil);

	end,

	-- �㲥
	[AEvent.BROADCAST .. USER.POS.GAME] = function(user,dataEx)
		if not dataEx then
			CNetSend(user.socket,AEvent.ERROR_BROADCAST_DATA);
			return;
		end
		local team = user.parentNode;
		team:broadcastByState(AEvent.BROADCAST .._EN_.. (CGetTime() - team.time) .._1_.. user.index .._1_.. dataEx,NODE.STATE.PLAY);
	end,

	-- �㲥(���˷�����)
	[AEvent.BROADCAST_BUT_THIS .. USER.POS.GAME] = function(user,dataEx)
		if not dataEx then
			CNetSend(user.socket,AEvent.ERROR_BROADCAST_DATA);
			return;
		end
		local team = user.parentNode;
		team:broadcastByStateButThis(user,AEvent.BROADCAST_BUT_THIS .._EN_.. (CGetTime() - team.time) .._1_.. user.index .._1_.. dataEx,NODE.STATE.PLAY);
	end,

	-- ָ������
	[AEvent.SEND_TO .. USER.POS.GAME] = function(user,dataEx)
		local team = user.parentNode;
		local arg = dataEx:split(_1_);
		-- ������
		if not arg[2] then
			CNetSend(user.socket,AEvent.ERROR_SENDTO_DATA);
			return;
		end
		local range = arg[1]:split(_2_);
		local err = {};
		for i=1,#range do
			local goal = team:getChildByIndex(tonumber(range[i]));
			if (not goal) or (goal.state ~= NODE.STATE.PLAY) then
				table.insert(err,range[i]);
			else
				CNetSend(goal.socket,AEvent.SEND_TO .._EN_.. (CGetTime() - team.time) .._1_.. user.index .._1_.. arg[2]);
			end
		end
		-- �Ƿ��д���
		if #err ~= 0 then
			CNetSend(user.socket,AEvent.NOTEXIST_SENDTO_OBJECT .._EN_.. table.concat(err,','));
		end
	end,

	-- ָ������(�ҳ��͸�������)
	[AEvent.SEND_TO_AND_CC_THIS .. USER.POS.GAME] = function(user,dataEx)
		local team = user.parentNode;
		local arg = dataEx:split(_1_);
		-- ������
		if not arg[2] then
			CNetSend(user.socket,AEvent.ERROR_SENDTO_DATA);
			return;
		end
		local range = arg[1]:split(_2_);
		-- ���뷢����
		table.insert(range,tostring(user.index));
		local err = {};
		for i=1,#range do
			local goal = team:getChildByIndex(tonumber(range[i]));
			if (not goal) or (goal.state ~= NODE.STATE.PLAY) then
				table.insert(err,range[i]);
			else
				CNetSend(goal.socket,AEvent.SEND_TO_AND_CC_THIS .._EN_.. (CGetTime() - team.time) .._1_.. user.index .._1_.. arg[2]);
			end
		end
		-- �Ƿ��д���
		if #err ~= 0 then
			CNetSend(user.socket,AEvent.NOTEXIST_SENDTO_OBJECT .._EN_.. table.concat(err,','));
		end
	end,

	-- �˳���Ϸ
	[AEvent.EXIT_GAME .. USER.POS.GAME] = function(user,dataEx)
		local zone = user.tree;
		local team = user.parentNode;

		if user.state ~= NODE.STATE.PLAY then
			CNetSend(user.socket,AEvent.ISNOT_PLAY_STATUS);
			return;
		end

		-- 1.��������
		user.state = NODE.STATE.WAIT;
		user.pos = USER.POS.TEAM;
		-- 2.��ʽ����Ϣ
		local msg = user:toString();
		-- 3.������ʾ
		user:updateDisplay(msg,1);
		-- 4.�����¼�
		CNetSend(user.socket,AEvent.EXIT_GAME);
		-- 5.�㲥�¼�
		team:broadcastButThis(user,AEvent.USER_LIST .._EN_.. msg);

		if team:isAllNot(NODE.STATE.PLAY) then
			-- 1.��������
			team.state = NODE.STATE.WAIT;
			-- 2.��ʽ����Ϣ
			msg = team:toString();
			-- 3.������ʾ
			team:updateDisplay(msg,1);
			-- 4.�����¼�
			zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_LIST .._EN_.. msg);
		end
	end,

	-- ͬ��������ʱ��
	[AEvent.SYNC_SERVER_TIME .. USER.POS.GAME] = function(user,dataEx)
		local team = user.parentNode;
		CNetSend(user.socket,AEvent.SYNC_SERVER_TIME .._EN_.. (CGetTime() - team.time));
	end,
}
