package __src{
	// 导入包
	import __def.*;
	
	import com.al.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.Security;
	import flash.text.*;
	import flash.utils.*;
	// 主类
	public class InitScene extends Sprite{
	/**舞台变量
	---------------------------*/
		public var tfPrompt:TextField;
		public var mcLogo:MovieClip; 

	/**接口变量
	---------------------------*/
		// 游戏对象
		private var game:URLLoader;
		// 环境参数
		private var params:Params;
		// 会话信息
		private var session:Session;
		// 初始化完成后调用的函数
		private var afterInited:Function;

	/**私有变量
	---------------------------*/
		private var keyLoader:Loader;
		private var infoLoader:URLLoader;

	/**私有常量
	---------------------------*/
		private const INIT_FINISH:String = '';
		
	/**构造 & 析构
	---------------------------*/
		// 构造函数
		public function InitScene(p:Params,s:Session,g:URLLoader,ai:Function):void{
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			this.params = p;
			this.session = s;
			this.game = g;
			this.afterInited = ai;
		}
		// 析构函数
		private function OnRemovedFormStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);

			this.keyLoader.unload();
			
			this.tfPrompt = null;
			this.mcLogo = null;
			this.keyLoader = null;
			this.infoLoader = null;
			
			this.params = null;
			this.session = null;
			this.game = null;
			this.afterInited = null;
		}
	
	/**公共函数
	---------------------------*/
		// 获得明文
		public function getMsg(cyp:String):String{
			return keyLoader.content['decrypt'](cyp); 
		}
		// 提示
		public function prompt(text:String):void{
			tfPrompt.text = text;
			tfPrompt.textColor = 0x00CBFF;
		}
		// 警告
		public function warn(text:String):void{
			tfPrompt.htmlText = "<a href='"+ params.navigation +"'><u>" + text + "!</u></a>";
			tfPrompt.textColor = 0x00FF00;
		}
		
	/**私有函数
	---------------------------*/
		// 添加到舞台
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			// 读取参数
			if(Security.sandboxType == 'localTrusted'){ //[本地调试模式]
				params.navigation = '/';				// 导航地址 
				params.key = 'keys/090427.swf';			// 钥匙文件
				params.server = '127.0.0.1';			// 服务器地址
				params.port = 1985;						// 游戏端口
				params.policyPort = 843;				// 策略端口
				params.path = 'games';					// 游戏资源目录
				params.game = 'TestDemo';				// 游戏文件
				params.info = 'infos/user.txt';			// 用户信息文件
			}
			else{
				params.navigation = loaderInfo.parameters.navigation || "/";
				params.key = loaderInfo.parameters.key;
				params.server = loaderInfo.parameters.server;
				params.port = parseInt(loaderInfo.parameters.port);
				params.policyPort = parseInt(loaderInfo.parameters.policyPort);
				params.path = loaderInfo.parameters.path;
				params.game = loaderInfo.parameters.game;
				params.info = loaderInfo.parameters.info;
				params.auto = parseInt(loaderInfo.parameters.auto); // 可选参数
			}
			// 判断参数
			if(!params.navigation){
				warn("未指定导航地址");
				return
			}
			if(!params.key){
				warn("未指定验证文件");
				return
			}
			if(!params.server){
				warn("未指定游戏服务器地址");
				return;
			}
			if(!params.port){
				warn("未指定游戏端口");
				return;
			}
			if(!params.policyPort){
				warn("未指定策略端口");
				return;
			}
			if(!params.path){
				warn("未指定资源路径");
				return;
			}
			if(!params.game){
				warn("未指定游戏");
				return
			}
			if(!params.info){
				warn("未指定用户信息的URL");
				return;
			}
			// 加载策略文件 - (最快&默认)端口:843
			Security.loadPolicyFile("xmlsocket://" + params.server + ":" + params.policyPort);
			
			prompt("加载验证文件...");
			keyLoader = new Loader();
			keyLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,OnComplete_Key);
			keyLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,OnIoError_Key);
			keyLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,OnSandBox_Key);
			keyLoader.load(new URLRequest(params.key));
		}
		// 1.[密钥]加载完成
		private function OnComplete_Key(e:Event):void {
			keyLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,OnComplete_Key);
			keyLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,OnIoError_Key);
			keyLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,OnSandBox_Key);
			
			prompt("读取用户信息中...");
			infoLoader = new URLLoader();
			infoLoader.addEventListener(Event.COMPLETE,OnComplete_Info);
			infoLoader.addEventListener(IOErrorEvent.IO_ERROR,OnIoError_Info);
			infoLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,OnSandBox_Info);
			infoLoader.load(new URLRequest(params.info));
		}
		// 2.[信息]加载完成  
		private function OnComplete_Info(e:Event):void {
			infoLoader.removeEventListener(Event.COMPLETE,OnComplete_Info);
			infoLoader.removeEventListener(IOErrorEvent.IO_ERROR,OnIoError_Info);
			infoLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,OnSandBox_Info);
			
			// 数据判断
			if(e.target.data == ''){
				warn("请先登陆");
				return;
			}
			try{
				var obj:* = AJson.decode(e.target.data);
				session.nickname = obj.nickname;
			}
			catch(e:*){
				warn("用户信息为非法的JSON格式");
				return;
			}
			prompt('加载游戏中...');
			game.dataFormat = URLLoaderDataFormat.BINARY;
			game.addEventListener(Event.COMPLETE,OnComplete_Game);
			game.addEventListener(IOErrorEvent.IO_ERROR,OnIoError_Game);
			game.addEventListener(SecurityErrorEvent.SECURITY_ERROR,OnSandBox_Info);
			game.addEventListener(ProgressEvent.PROGRESS,OnProgress_Game);
			game.load(new URLRequest(params.path + '/'  + params.game  + '.swf'));
		}
		// 3.[游戏]加载完成 
		private function OnComplete_Game(e:Event):void {
			game.removeEventListener(Event.COMPLETE,OnComplete_Game);
			game.removeEventListener(IOErrorEvent.IO_ERROR,OnIoError_Game);
			game.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,OnSandBox_Info);
			game.removeEventListener(ProgressEvent.PROGRESS,OnProgress_Game);
			
			// 数据判断
			if(e.target.bytesTotal <= 0){
				warn("错误游戏文件");
				return
			}
			
			prompt("连接服务器中...");
			afterInited();								// 完成初始化
		}
		// [密钥]连接错误 
		private function OnIoError_Key(e:IOErrorEvent):void {
			warn("找不到验证文件");
		}
		// [信息]连接错误 
		private function OnIoError_Info(e:IOErrorEvent):void {
			warn('找不到用户信息的地址');
		}
		// [游戏]连接错误 
		private function OnIoError_Game(e:IOErrorEvent):void {
			warn("找不到游戏的地址");
		}
		// [密钥]安全沙箱 
		private function OnSandBox_Key(e:SecurityErrorEvent):void {
			warn('不能加载验证文件');
		}
		// [信息]安全沙箱 
		private function OnSandBox_Info(e:SecurityErrorEvent):void {
			warn('不能读取用户信息');
		}
		// [游戏]安全沙箱 
		private function OnSandBox_Game(e:SecurityErrorEvent):void {
			warn("不能加载此游戏");
		}
		// [游戏]加载进度 
		private function OnProgress_Game(e:ProgressEvent):void {
			var percent:Number = (e.bytesLoaded / e.bytesTotal);
			var mc:MovieClip = mcLogo['mcProcess'];
			mc.y = mc.height - mc.height * percent;
		}
	}
}