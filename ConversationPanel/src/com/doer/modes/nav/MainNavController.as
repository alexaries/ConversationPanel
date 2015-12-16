package com.doer.modes.nav
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
	import com.metaedu.client.messages.nebula.ClientComplexChangeScreenMode;
	import com.metaedu.client.messages.nebula.ClientComplexChatCtrl;
	import com.metaedu.client.messages.nebula.ClientComplexQuit;
	import com.metaedu.client.messages.nebula.ClientComplexRaise;
	import com.metaedu.client.messages.nebula.ClientComplexRaiseCtrl;
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;
	import com.metaedu.client.messages.nebula.NebulaParticipantType;
	import com.metaedu.client.messages.nebula.NebulaPlatformType;
	import com.metaedu.client.messages.nebula.NebulaScreenMode;
	import com.metaedu.client.messages.nebula.NebulaScreenType;
	import com.metaedu.client.messages.nebula.ServerComplexChatCtrlInform;
	import com.metaedu.client.messages.nebula.ServerComplexEnterInform;
	import com.metaedu.client.messages.nebula.ServerComplexEnterResp;
	import com.metaedu.client.messages.nebula.ServerComplexRaiseCtrlInform;
	import com.metaedu.client.messages.nebula.ServerComplexRaiseInform;
	import com.metaedu.client.messages.nebula.ServerPassiveOutInform;
	import com.metaedu.client.messages.nebula.ServerSignInResp;
	import com.metaedu.client.messages.nebula.complex.OnlineUnit;
	import com.metaedu.client.messages.nebula.complex.RaiseCtrlType;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	
	import spark.components.Group;
	
	import view.common.buttons.NavButton;
	import view.modes.nav.NavView;
	import view.modes.nav.main.MainNavContent;
	
	public class MainNavController extends AbstrackController 
	{
		/**
		 * 导航栏view引用
		 * **/
		public var mainNavContent:MainNavContent = null;
		
		/**
		 * 主Nav引用
		 * **/
		private var navView:NavView = null;
		
		public function MainNavController(metaManager:MetaManager, modeId:int,container:Group,navGroup:MainNavContent)
		{
			this.mainNavContent = navGroup;
			this.navView = container as NavView;
			
			super(metaManager, modeId);
			
			this.modeView = navGroup;
			this.modeView.controller = this;
			
			invalidateHandler();
			
			try
			{
				ExternalInterface.addCallback("onCloseWindow",dispatchQuit);
			} 
			catch(error:Error) 
			{
				
			}
			
		}
		
		override public function reset():void
		{
			NavToolConf.getInstance().reset();
			
			navView.reset();
		}
		
		/**
		 * 添加导航栏按钮监听
		 * **/
		private function invalidateHandler():void
		{
			mainNavContent.addEventListener(MouseEvent.CLICK,onNavButtonHandler);
			
			registCommand(LocalCommandType.CMD_LOGIN_COMPLETE);
			registCommand(LocalCommandType.CMD_ACTIVITESCREEN_CHANGE);
			registCommand(LocalCommandType.CMD_SET_NAV_NUMS);
			registCommand(LocalCommandType.CMD_NAV_BLACKBORD);
			registCommand(LocalCommandType.CMD_NAV_SET);
			registCommand(LocalCommandType.CMD_NAV_VIDEO_SHARE);
			registCommand(LocalCommandType.CMD_NAV_STUDENTLIST);
			registCommand(LocalCommandType.CMD_NAV_CHAT);
			
		}
		
		/**
		 * 收到聊天权限切换
		 * **/
		private function onRcvExchangeChat(info:ServerComplexChatCtrlInform):void
		{
			ComplexConf.enableChat = info.enable;
		}
	
		/**
		 * 收到举手权限变更
		 * **/
		private function onRcvExchangeRaise(info:ServerComplexRaiseCtrlInform):void
		{
			if(info.ctrlType == RaiseCtrlType.DISABLE)
				ComplexConf.enableRaise = false;
			else if(info.ctrlType == RaiseCtrlType.ENABLE)
				ComplexConf.enableRaise = true;
			else if(info.ctrlType == RaiseCtrlType.CLEAR)
			{
				if(mainNavContent.uniqueGroup.btnRise != null)
					mainNavContent.uniqueGroup.btnRise.selected = false;
			}
				
		}
		
		
		private function onCloseWindow():void
		{
			if(AppConf.platform == NebulaPlatformType.WEB)
			{
				try
				{
					ExternalInterface.call("onAsCloseWindow");
				} 
				catch(error:Error) 
				{
					
				}
				
			}else
			{
				if(ComplexConf.isLoginComplete)
					dispatchQuit();
				else
					(FlexGlobals.topLevelApplication as IMainClass).onLogout();
				
			}
			
		}
		
		private function dispatchQuit():void
		{
			var logoutInfo:ClientComplexQuit = new ClientComplexQuit();
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,logoutInfo));
			
		}
		
		private function onNavButtonHandler(e:MouseEvent):void
		{
			if(e.target == mainNavContent.uniqueGroup.btnClose)
			{
				Tools.alert("是否退出课堂？",onCloseWindow);
				return;
			}
			
			if(e.target is NavButton && e.target.groupName == "unique")
			{
				e.target.selected = !e.target.selected;
			}
			
			if(e.target is NavButton && e.target.groupName == "tools")
			{
				NavToolConf.getInstance().setTool(e.target.name,e.target.selected,false);
			}
			
			if(e.target is NavButton && e.target.groupName == "color")
			{
				NavToolConf.getInstance().setColorTool(e.target.name,false);
			}
			
			if(e.target is NavButton && e.target.groupName == "size")
			{
				NavToolConf.getInstance().setSizeTool(e.target.name,false);
			}
			
			if(e.target == mainNavContent.toolGroup.btnPen)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_PEN,{selected : e.target.selected})); //画笔1
			}
			else if(e.target == mainNavContent.toolGroup.btnHand)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_HAND,{selected : e.target.selected})); //拖地
			}
			else if(e.target == mainNavContent.toolGroup.btnEraser)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_ERASER,{selected : e.target.selected})); //橡皮
			}
			else if(e.target == mainNavContent.toolGroup.btnClear)
			{
				Tools.alert("是否清除绘图？",function():void{
					
					sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_CLEAR,{selected : e.target.selected}));  //清空
					
				});
				
				
			}
			else if(e.target == mainNavContent.toolGroup.btnText)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_TEXT,{selected : e.target.selected}));   //文字
			}
			else if(e.target == mainNavContent.mainGroup.btnBlackbord)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_BLACKBORD,{id : ModeTypes.MODE_BLACKBORD_ID,selected : e.target.selected})); //黑板
			}
			else if(e.target == mainNavContent.mainGroup.btnCourse)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_COURSE,{id : ModeTypes.MODE_COURSE_ID,selected : e.target.selected})); //课件
			}
			else if(e.target == mainNavContent.mainGroup.btnMedia)//多媒体
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_MEDIA,{id : ModeTypes.MODE_MEDIA_ID,selected : e.target.selected})); //多媒体
			}
			else if(e.target == mainNavContent.uniqueGroup.btnChat)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_CHAT,{id : ModeTypes.MODE_CHAT_ID,selected : e.target.selected})); //聊天
			}
			else if(e.target == mainNavContent.uniqueGroup.btnFastQuestion)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_FASTQUESTION,{id : ModeTypes.MODE_FASTQUESTION_ID,selected : e.target.selected})); //快速问答
			}
			
			else if(e.target == mainNavContent.uniqueGroup.btnStudentList)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_STUDENTLIST,{id : ModeTypes.MODE_STUDENTLIST_ID,selected : e.target.selected})); //学生列表
			}
			else if(e.target == mainNavContent.mainGroup.btnResource)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_RESOURCES,{id : ModeTypes.MODE_SKYDRIVE_ID,selected : e.target.selected})); //资源引用
			}else if(e.target == mainNavContent.uniqueGroup.btnRise)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_RAISE,{selected : e.target.selected}));
				
				if(ComplexConf.participantType == NebulaParticipantType.CHARGE)
					mainNavContent.uniqueGroup.btnRise.selected = false;
				
			}else if(e.target == mainNavContent.uniqueGroup.btnClipScreen)
			{
				ComplexConf.isClipScreen = e.target.selected;
				
				var msg:ClientComplexChangeScreenMode = new ClientComplexChangeScreenMode();
				
				msg.screenMode = ComplexConf.isClipScreen ? NebulaScreenMode.DOUBLE : NebulaScreenMode.SINGLE;
				
				sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,msg));
				
			}else if(e.target == mainNavContent.uniqueGroup.btnSet)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_SET,{selected : e.target.selected}));
			}else if(e.target == mainNavContent.mainGroup.btnCamera)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_VIDEO_SHARE,{selected : e.target.selected,isSub : false}));
			}else if(e.target == mainNavContent.mainGroup.btnSyn)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_DESKTOP_SYN,{selected : e.target.selected, isSub : false}));
			}
			
		}
		
		
		override public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
			if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_CHAT_CTRL_INFORM)
			{
				onRcvExchangeChat(JsonUtils.convertJsonToClass(refContent,ServerComplexChatCtrlInform));
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_RAISE_CTRL_INFORM)
			{
				onRcvExchangeRaise(JsonUtils.convertJsonToClass(refContent,ServerComplexRaiseCtrlInform));
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_RAISE_INFORM)
			{
				onRcvRaiseInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexRaiseInform));
			}
		}
		
		private function onRcvRaiseInfo(info:ServerComplexRaiseInform):void
		{
			if(info.id == ComplexConf.userId && ComplexConf.participantType != NebulaParticipantType.CHARGE)
			{
				mainNavContent.uniqueGroup.btnRise.selected = info.enable;
			}
		}
		
		override public function onCommand(cmd:LocalCommand):void
		{
			if(cmd.command == LocalCommandType.CMD_LOGIN_COMPLETE)
			{
//				removeCommand(LocalCommandType.CMD_LOGIN_COMPLETE);
				
				onLoginInfo(cmd.data as ServerComplexEnterResp);
				
			}else if(cmd.command == LocalCommandType.CMD_ACTIVITESCREEN_CHANGE)
			{
				if(ComplexConf.participantType == NebulaParticipantType.CHARGE || ComplexConf.participantType == ComplexConf.Temp_ParticipantType )
					mainNavContent.setToolsEnable((ComplexConf.activeScreen == NebulaScreenType.BOARD || ComplexConf.activeScreen == NebulaScreenType.DOCUMENT));
				
				NavToolConf.getInstance().isSynTools = (ComplexConf.activeScreen == ComplexConf.subActiveScreen && ComplexConf.activeScreen == NebulaScreenType.BOARD)
					
				
			}else if(cmd.command == LocalCommandType.CMD_SET_NAV_NUMS)
			{
				if(cmd.data['hand'] != null)
					mainNavContent.handedNum = cmd.data['hand'];
				
				if(cmd.data['chat'] != null)
					mainNavContent.chatNum = cmd.data['chat'];
			}else if(cmd.command == LocalCommandType.CMD_NAV_SET)
			{
				if(!cmd.data.selected)
				{
					mainNavContent.uniqueGroup.btnSet.selected = false;
				}
			}else if(cmd.command == LocalCommandType.CMD_NAV_VIDEO_SHARE)
			{
				if(!cmd.data.selected)
				{
					mainNavContent.mainGroup.btnCamera.selected = false;
				}
			}else if(cmd.command == LocalCommandType.CMD_NAV_STUDENTLIST)
			{
				if(!cmd.data.selected)
					mainNavContent.uniqueGroup.btnStudentList.selected = false;
			}else if(cmd.command == LocalCommandType.CMD_NAV_CHAT)
			{
				if(!cmd.data.selected)
					mainNavContent.uniqueGroup.btnChat.selected = false;
			}
		}
		
		private function onLoginInfo(loginInfo:ServerComplexEnterResp):void
		{
			ComplexConf.enableChat = loginInfo.enableChat;
			ComplexConf.enableRaise = loginInfo.enableRaise;
			
			for each(var status:OnlineUnit in ComplexConf.onlines)
			{
				if(status.id == ComplexConf.userId && ComplexConf.participantType != NebulaParticipantType.CHARGE)
				{
					ComplexConf.isRaise = status.isRaise;
				}
			}
			
		}
		
	}
}