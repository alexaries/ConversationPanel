package com.doer.net.socket
{
	import com.doer.common.Tools;
	import com.doer.config.AppConf;
	import com.doer.config.ComplexConf;
	import com.doer.config.ModeTypes;
	import com.doer.interfaces.IMainClass;
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.net.login.LoginController;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.log.LogPak;
	import com.metaedu.client.messages.nebula.ClientGroupsTotal;
	import com.metaedu.client.messages.nebula.ClientSignOut;
	import com.metaedu.client.messages.nebula.NebulaLanguageType;
	import com.metaedu.client.messages.nebula.NebulaMessage;
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;
	import com.metaedu.client.messages.nebula.NebulaMessagePackage;
	import com.metaedu.client.messages.nebula.NebulaPlatformType;
	import com.metaedu.client.messages.nebula.ServerBoardSignInResp;
	import com.metaedu.client.messages.nebula.ServerGroupsTotalResp;
	import com.metaedu.client.messages.nebula.ServerPassiveOutInform;
	import com.metaedu.client.messages.nebula.ServerSignInResp;
	import com.metaedu.client.messages.nebula.ServerSignOutResp;
	import com.metaedu.client.messages.nebula.group.GroupBasic;
	import com.metaedu.client.socket.INebulaSocketHandler;
	import com.metaedu.client.socket.NebulaSocketContainer;
	import com.metaedu.client.utils.text.JsonUtils;
	import com.metaedu.client.utils.text.TimeUtils;
	import com.metaedu.client.websupport.WebDaoHelper;
	import com.metaedu.client.websupport.dao.ConnStatusDao;
	import com.metaedu.client.websupport.model.ConnStatus;
	import com.strong.socket.SocketContainer;
	
	import flash.external.ExternalInterface;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	import view.common.Alert;
	
	public class SocketController extends AbstrackController implements INebulaSocketHandler
	{	
		/**
		 * 日志输出
		 * **/
		private static var log:LogPak = new LogPak(SocketController);
		
		/**
		 * socket消息容器
		 * **/
		public var socketContainer:NebulaSocketContainer = null;
		
		/**
		 * 本地消息缓存队列
		 * **/
		private var localQueue:Vector.<NebulaMessagePackage> = new Vector.<NebulaMessagePackage>();
		
		public function SocketController(metaManager:MetaManager, modeId:int, container:Group=null)
		{
			
			super(metaManager, modeId, container);
			
			invalidateCommands();
			
			socketContainer = new NebulaSocketContainer(this);
			
		}
		
		/***
		 * 初始化添加本地消息监听
		 * */
		private function invalidateCommands():void
		{
			registCommand(LocalCommandType.CMD_SEND_TO_SERVER);
		}
		
		override public function onCommand(cmd:LocalCommand):void
		{
			if(cmd.command == LocalCommandType.CMD_SEND_TO_SERVER)
			{
				
				var msg:NebulaMessage = cmd.data as NebulaMessage;
				
				msg.setDispachMark(ComplexConf.complexId == null ? "" : ComplexConf.complexId);
				
				socketContainer.handFire(new NebulaMessagePackage(msg)); //发送到服务端
			}
		}
		
		override public function onDestroy():void
		{
			super.onDestroy();
		}

		public function connect():void
		{
			socketContainer.start();
		
		}
		
		public function quit():void
		{
			var msg:ClientSignOut = new ClientSignOut();
			
			msg.time = TimeUtils.getDateStandard(new Date());
			
			socketContainer.handFire(new NebulaMessagePackage(msg));
			
		}
		
		/** 重置 OFFLINE 状态 */
		public function offlineClear():void {
			// 重置消息队列
		}
		
		
		/** 主动登出操作
		 * @param refMsg 主动登出消息
		 */
		public function signOut(refMsg:ServerSignOutResp):void {
			// 登出操作\
			
			(FlexGlobals.topLevelApplication as IMainClass).onQuit();
			
		}
		
		/** 被动登出操作
		 * @param refMsg 被动登出消息
		 */
		override public function signOutPassive(refMsg:ServerPassiveOutInform):void {
			// 被动下线操作
			var alert:Alert = Tools.alert("该账号已在其他地方登录！",function():void{
				
				if(AppConf.platform == NebulaPlatformType.WEB)
					ExternalInterface.call("onAsCloseWindow");
				else
					ExternalInterface.call("onQuit");
				
			},null,true);
			
		}
		
		/** 登录成功 */
		public function signInOK(refMsg:ServerSignInResp):void {
			// 登陆成功操作
			(metaManager.getControllerById(ModeTypes.MODE_LOGIN_ID) as LoginController).invalidateLogin(refMsg);
		}
		
		/** 黑板登录成功 */
		public function signInBoardOK(refMsg:ServerBoardSignInResp):void {
			(metaManager.getControllerById(ModeTypes.MODE_LOGIN_ID) as LoginController).invalidateBordLogin(refMsg);
		}
		
		/** 登录失败 */
		public function signInFail():void {
			
			Tools.alert("登录失败！",null,null,true);
			
		}
		
		/** 接收服务端消息 */
		public function reciveMessage(refContent:String, refBusinessType:int, refTimeStamp:String=''):void {
			// 接收业务消息处理
			
			if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_ENTER_RESP)
			{
				metaManager.getControllerById(ModeTypes.MODE_LOGIN_ID).onRcv(refContent,refBusinessType,refTimeStamp);
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_QUIT_RESP)
			{
				(FlexGlobals.topLevelApplication as IMainClass).onLogout();
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_BOARD_CALL_INFORM)
			{
				metaManager.getControllerById(ModeTypes.MODE_LOGIN_ID).onRcv(refContent,refBusinessType,refTimeStamp);
			}
			else
			{
				if(ComplexConf.isLoginComplete)
				metaManager.onRcv(refContent,refBusinessType,refTimeStamp);
			}
			
			
		}
		
		/**
		 * 添加消息到队列
		 * **/
		public function pushMessage(refMsg:NebulaMessagePackage):void
		{
			localQueue.push(refMsg);
		}
		
		/**
		 * 发送消息队列
		 * **/
		public function supplyMessages():Vector.<NebulaMessagePackage>
		{
			var queue:Vector.<NebulaMessagePackage> = new Vector.<NebulaMessagePackage>();
			
			while(localQueue.length > 0)
			{
				queue.push(localQueue.shift());
			}
			
			return queue;
		}

		/** 提供待发送的消息 */
		public function prepareMessages():Vector.<NebulaMessagePackage> {
			
			return null;
		}
		
		/** 协议版本错误 */
		public function protocolError():void {
			// 协议错误
			Tools.alert("协议版本错误！");
		}

		/**
		 * 服务地址
		 * **/
		public function get sevAddress():Vector.<String>
		{
			var preServAddrs:Vector.<String> = new Vector.<String>();
			preServAddrs.push(AppConf.messageAddr);
			
			return preServAddrs;
		}
		
		/** 更新本地最后收到的服务端消息时间戳 */
		public function set serverLastStamp(refStamp:String):void {
			
		}
		
		/** 最后收到的服务端消息时间戳 */
		public function get serverLastStamp():String {
			return "";
		}
		
		/** 更新本地最后收到的服务端消息时间戳 */
		public function set clientLastStamp(refStamp:String):void {
			
		}
		
		/** 最后收到的服务端消息时间戳 */
		public function get clientLastStamp():String {
			return "";
		}
		
		/** 设置服务端发送的 Nebula 通信令牌 */
		public function set session(refSession:String):void {
			AppConf.session = refSession;
		}
		
		/** 获取 Nebula 登录令牌 */
		public function get session():String {
			return AppConf.session;
		}
		
		/** 是否通用账号登陆 */
		public function get isGeneralLogin():Boolean {
			return ComplexConf.isGeneralLogin;
		}
		
		/** 机构编号 */
		public function get institutionId():String {
			return ComplexConf.institutionId;
		}
		
		/** 登录账号 */
		public function get account():String {
			return ComplexConf.account;
		}
		
		/** 登录密码 */
		public function get password():String {
			return ComplexConf.password;
		}
		
		/** 设备编号 */
		public function get deviceMark():String {
			return AppConf.deviceMark;
		}
		
		/** 平台类型 */
		public function get platform():int {
			return AppConf.platform; // ConnStatus 中默认为 0，即 Web 及桌面版本
		}
		
		public function get isBoard():Boolean
		{
			return ComplexConf.isBordMode;
		}
		
		public function get languageType():int
		{
			return NebulaLanguageType.SIMPLIFIED_CHINESE;
		}
		
		
		
	}
}