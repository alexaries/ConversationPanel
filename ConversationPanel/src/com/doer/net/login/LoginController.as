package com.doer.net.login
{
	import com.doer.common.Tools;
	import com.doer.config.AppConf;
	import com.doer.config.ComplexConf;
	import com.doer.config.ModeTypes;
	import com.doer.interfaces.IMainClass;
	import com.doer.interfaces.ISProcessor;
	import com.doer.manager.MetaManager;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ClientComplexEnter;
	import com.metaedu.client.messages.nebula.ClientGroupsTotal;
	import com.metaedu.client.messages.nebula.ClientMembersTotal;
	import com.metaedu.client.messages.nebula.NebulaCharacterType;
	import com.metaedu.client.messages.nebula.NebulaMessage;
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;
	import com.metaedu.client.messages.nebula.NebulaMessagePackage;
	import com.metaedu.client.messages.nebula.NebulaParticipantType;
	import com.metaedu.client.messages.nebula.NebulaPlatformType;
	import com.metaedu.client.messages.nebula.NebulaScreenMode;
	import com.metaedu.client.messages.nebula.ServerBoardSignInResp;
	import com.metaedu.client.messages.nebula.ServerComplexBoardCallInform;
	import com.metaedu.client.messages.nebula.ServerComplexEnterResp;
	import com.metaedu.client.messages.nebula.ServerGroupsTotalResp;
	import com.metaedu.client.messages.nebula.ServerMembersTotalResp;
	import com.metaedu.client.messages.nebula.ServerPassiveOutInform;
	import com.metaedu.client.messages.nebula.ServerSignInResp;
	import com.metaedu.client.messages.nebula.complex.KeyUserInfo;
	import com.metaedu.client.messages.nebula.complex.OnlineUnit;
	import com.metaedu.client.messages.nebula.complex.TalkingStatus;
	import com.metaedu.client.messages.nebula.group.GroupBasic;
	import com.metaedu.client.messages.nebula.member.MemberBasic;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;

	public class LoginController extends AbstrackController 
	{
		
		private var loader:URLLoader = null;
		
		public function LoginController(metaManager:MetaManager,modeId:int)
		{
			super(metaManager,modeId);
			
			ComplexConf.commander = this;
			
		}
		
		/**
		 * 白板登录回复
		 * **/
		public function invalidateBordLogin(refMsg:ServerBoardSignInResp):void
		{
			AppConf.session = refMsg.session;
			ComplexConf.institutionName = refMsg.institutionName;
			ComplexConf.deviceName = refMsg.deviceName;
			
			(FlexGlobals.topLevelApplication as IMainClass).onConnect();
		}
		
		/**
		 * 初始化登录
		 * **/
		public function invalidateLogin(refMsg:ServerSignInResp):void
		{
			ComplexConf.userId = refMsg.userId;
			ComplexConf.account = refMsg.account;
			ComplexConf.avatar = refMsg.avatar;
			ComplexConf.name = refMsg.name;
			ComplexConf.surname = refMsg.surname;
			ComplexConf.sex = refMsg.sex;
			AppConf.session = refMsg.session;
			
			(FlexGlobals.topLevelApplication as IMainClass).onConnect();

		}
		
		/**
		 * 登录课堂会话
		 * **/
		public function loginConversation():void
		{
			ComplexConf.isLoginComplete = false;
			
			var complexEnter:ClientComplexEnter = new ClientComplexEnter();
			complexEnter.userId = ComplexConf.userId;
			complexEnter.platformType = AppConf.platform;
			complexEnter.camCount = Camera.names.length;
			complexEnter.micCount = Microphone.names.length;
			complexEnter.setDispachMark(ComplexConf.complexId);
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,complexEnter)); //指派本地全局消息
			
		}
		
		/**
		 * 登录课堂会话回复
		 * **/
		public function onLoginConversationReplay(response:ServerComplexEnterResp):void
		{
			ComplexConf.enableChat = response.enableChat;
			ComplexConf.enableRaise = response.enableRaise;
			
			ComplexConf.complexId = response.complexId;
			ComplexConf.participantType = response.participantType;
			ComplexConf.chargInfo = response.charge;
			ComplexConf.complexName = response.name;
			ComplexConf.onlines = response.units;
			
			ComplexConf.isClipScreen = response.screenMode == NebulaScreenMode.DOUBLE;
			
			ComplexConf.activeScreen = response.activeScreen;
			ComplexConf.subActiveScreen = response.activeScreen2;
			
			for each(var online:OnlineUnit in response.units)
			{
				if(online.id == ComplexConf.chargInfo.id)
				{
					ComplexConf.isChargeOnline = true;
					break;
				}
			}
			
			for each(var talk:TalkingStatus in response.talkings)
			{
				if(talk.id == ComplexConf.userId && ComplexConf.participantType != NebulaParticipantType.CHARGE)
				{
					metaManager.stoParticipantType = ComplexConf.participantType;
					
					ComplexConf.participantType = ComplexConf.Temp_ParticipantType;
					
					ComplexConf.isTalking = true;
					
					break;
				}
			}
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_LOGIN_COMPLETE,response));
			
			ComplexConf.isLoginComplete = true;
			
			(FlexGlobals.topLevelApplication as IMainClass).onLogin();

		}
		
		override public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
			try
			{
				if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_ENTER_RESP)
				{
					onLoginConversationReplay(JsonUtils.convertJsonToClass(refContent,ServerComplexEnterResp));
				}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_BOARD_CALL_INFORM)
				{
					onAskedLogin(JsonUtils.convertJsonToClass(refContent,ServerComplexBoardCallInform));
				}
			} 
			catch(error:Error) 
			{
				var data:Object = JSON.parse(refContent);
				
				Tools.alert("登录到课堂会话失败！");
			}
		}
		
		private function onAskedLogin(refMsg:ServerComplexBoardCallInform):void
		{
			ComplexConf.complexId = refMsg.complexId;
			ComplexConf.userId = refMsg.id;
			ComplexConf.name = refMsg.name;
			ComplexConf.surname = refMsg.surname;
			ComplexConf.sex = refMsg.sex;
			AppConf.session = refMsg.session;
			
			loginConversation();

		}
		
		
		
	}
}