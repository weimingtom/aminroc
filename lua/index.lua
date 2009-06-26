--
-- Developed by AminLab
-- ------------------------------------
-- date:2009-06-02
-- site:http://www.aminLab.cn
-- ------------------------------------
--
-- ���ð�·��
package.path  = package.path .. ';../?.lua;../lua/?.lua;../lua/src/?.lua';

-- �����
require('com.PRINT');
require('com.string');
require('com.table');

require('def.NODE');
require('def.USER');
require('def.AEvent');
require('def.TreeEvent');

require('src.Guest');
require('src.tree.Node');
require('src.tree.Root');
require('src.tree.Zone');
require('src.tree.Team');
require('src.tree.User');

-----------------------------
--|
--|		ȫ�ֱ���
--|
-----------------------------
argUser = {}; 		-- socket����

-----------------------------
--|
--|		Lua�ӿں���
--|
-----------------------------
	-- ��ʼ��
	function OnInit()
		-- ���������ļ�
		require('config');
		require(KEY);
		-- ����ģʽ
		if __DEBUG__ then
			_G['_CNetSend'] = _G['CNetSend'];
			_G['CNetSend'] = function(socket,dataEx)
				print('[send:' .. socket ..']',dataEx);
				_G['_CNetSend'](socket,dataEx);
			end
		end
		-- ��סȫ�ֱ�
		setmetatable(_G,{__newindex = LOCK_ADD});
		return 0;
	end

	-- ��������
	function OnAEvent(socket,dataEx)
		-- ����ʱ�����(����ģʽ)
		local startTime;
		if __DEBUG__ then
			startTime = CGetTime();
			print('[recv:' .. socket ..']',dataEx);
		end
		-- ��ȡ�û�
		local user;
		if not argUser[socket] then
			user = User:new();
			user.socket = socket
			argUser[socket] = user;
		else
			user = argUser[socket];
		end
		-- ��������
		local arg = dataEx:split(_EN_);
		if #arg > 2 then
			PRINT.ERROR("!! Error package");
			return 1;
		end
		local event = arg[1];
		if not event then
			PRINT.ERROR("!! Unknonw evnet");
			return 1;
		end
		-- ��ȡ��ں���
		local line = _G[user.status];
		local func = line[event .. user.pos];
		if not func then
			print("------------------ error");
			print("event:" .. event);
			print("user.socket:".. user.socket);
			print("user.dataEx:".. dataEx);
			print("user.pos:" .. user.pos);
			if user.tree ~= 0 then
				print("tree.name:" .. user.tree.name);
			end
			print("msg:" .. user.msg);
			print("------------------ end");
			user.network = NODE.NETWORK.OFFLINE;	-- close it?you choose
			return 1;
		end
		-- ��������
		local err_no = func(user,arg[2]);
		if __DEBUG__ then
			io.write('--------------------------------------- spend time:' .. (CGetTime() - startTime) .. '\n');
		end
		return err_no;
	end

	-- ���ӹر�
	function OnClose_Socket(socket)
		-- ��ȡ�û�
		local user = argUser[socket];
		-- ������������
		if not user then
			PRINT.MSG('unknow user,ID is:' .. socket);
			return
		end
		local zone = user.link;
		user.network = NODE.NETWORK.OFFLINE;

		-- �ڿռ���
		if user.pos == USER.POS.ZONE then
			user:removeEventListener(TreeEvent.ZONE_UPDATE);
		-- �ڶ�����
		elseif user.pos == USER.POS.TEAM then
			_G[user.status][AEvent.EXIT_TEAM .. USER.POS.TEAM](user,nil);
		-- ����Ϸ��
		elseif user.pos == USER.POS.GAME then
			_G[user.status][AEvent.EXIT_TEAM .. USER.POS.TEAM](user,nil);
		end

		-- ע���ʺ�
		argUser[socket] = nil;
		if __DEBUG__ then
			PRINT.MSG('A socket was closed,ID is:' .. socket);
		end
	end

-------------------------------------
--
--		��������ģʽ
--
-------------------------------------
if not _G['CNetSend'] then
	-- ���ͺ���
	_G['CNetSend'] = function(socket,dataEx)
		dataEx = tostring(dataEx);
		local arg = dataEx:split(_EN_);
		local en = arg[1];
		if en == AEvent.REQUEST_TO then
			__temp__ = KEYER.decrypt(arg[2]);
		end
	end
	-- ��ȡʱ��
	_G['CGetTime'] = function()
		return os.time();
	end
	-- ȫ�ֶ���
	_G['__temp__'] = '';
	_G['_CB_'] = '\001';
	_G['_EN_'] = '\003';
	_G['_1_']  = '\022';
	_G['_2_']  = '\030';
end

-------------------------------------
--
--		��Ԫ����
--
-------------------------------------
--~ OnInit();
--~ -- user 1
--~ OnAEvent(1,'10');
--~ OnAEvent(1,'11' .. _EN_ .. __temp__ .._1_.."user_1" );
--~ OnAEvent(1,'20' .. _EN_ .. "TestDemo");
--~ OnAEvent(1,'21');
--~ OnAEvent(1,'30' .. _EN_ .. "test-team");
--~ OnAEvent(1,'33');
--~ -- user 2
--~ OnAEvent(2,'10');
--~ OnAEvent(2,'11' .. _EN_ .. __temp__ .._1_.. "user_2");
--~ OnAEvent(2,'20' .. _EN_ .. "TestDemo");
--~ OnAEvent(2,'21');
--~ OnAEvent(2,'31' .. _EN_ .. "1");
--~ OnAEvent(2,'33');

--~ OnAEvent(2,'34' .. _EN_ .. '1');

--~ -- user 3
--~ OnAEvent(3,'10');
--~ OnAEvent(3,'11' .. _EN_ .. __temp__ .._1_.. "user_3");
--~ OnAEvent(3,'20' .. _EN_ .. "TestDemo");
--~ OnAEvent(3,'21');
--~ OnAEvent(3,'31' .. _EN_ .. "1");
--~ OnAEvent(3,'33');
--~ -- user 4
--~ OnAEvent(4,'10');
--~ OnAEvent(4,'11' .. _EN_ .. __temp__ .._1_.. "user_4");
--~ OnAEvent(4,'20' .. _EN_ .. "TestDemo");
--~ OnAEvent(4,'21');
--~ OnAEvent(4,'31' .. _EN_ .. "1");
--~ OnAEvent(4,'33');
--~ -- ready
--~ OnAEvent(1,'40');
--~ OnAEvent(2,'40');
--~ OnAEvent(3,'40');
--~ OnAEvent(4,'40');

--~ -- boardcast data
--~ OnAEvent(1,'50' .. _EN_ .. "game data");
--~ OnAEvent(2,'50' .. _EN_ .. "game data");
--~ OnAEvent(3,'50' .. _EN_ .. "game data");
--~ OnAEvent(4,'50' .. _EN_ .. "game data");
--~ -- boardcast data but this
--~ OnAEvent(1,'51' .. _EN_ .. "game data");
--~ OnAEvent(2,'51' .. _EN_ .. "game data");
--~ OnAEvent(3,'51' .. _EN_ .. "game data");
--~ OnAEvent(4,'51' .. _EN_ .. "game data");
--~ -- send data
--~ OnAEvent(1,'52' .. _EN_ .. "1" .._2_.."1" .._1_.."game data");
--~ OnAEvent(2,'52' .. _EN_ .. "1" .._2_.."2" .._1_.."game data");
--~ OnAEvent(3,'52' .. _EN_ .. "1" .._2_.."2" .._1_.."game data");
--~ OnAEvent(4,'52' .. _EN_ .. "1" .._2_.."2" .._1_.."game data");
--~ -- send data and cc this
--~ OnAEvent(1,'53' .. _EN_ .. "1" .._2_.."2" .._1_.."game data");
--~ OnAEvent(2,'53' .. _EN_ .. "1" .._2_.."2" .._1_.."game data");
--~ OnAEvent(3,'53' .. _EN_ .. "1" .._2_.."2" .._1_.."game data");
--~ OnAEvent(4,'53' .. _EN_ .. "1" .._2_.."2" .._1_.."game data");
--~ -- exit game
--~ OnAEvent(1,'54');
--~ OnAEvent(2,'54');
--~ OnAEvent(3,'54');
--~ OnAEvent(4,'54');
--~ -- ready(second game)
--~ OnAEvent(1,'40');
--~ OnAEvent(2,'40');
--~ OnAEvent(3,'40');
--~ OnAEvent(4,'40');
