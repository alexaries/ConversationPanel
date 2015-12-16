package com.doer.modes
{
	import com.doer.config.ComplexConf;
	import com.doer.config.ModeTypes;
	import com.doer.interfaces.IController;
	import com.doer.manager.MetaManager;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.modes.nav.NavToolConf;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ClientComplexChangeScreen;
	import com.metaedu.client.messages.nebula.ClientComplexChangeScreenMode;
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;
	import com.metaedu.client.messages.nebula.NebulaScreenMode;
	import com.metaedu.client.messages.nebula.NebulaScreenType;
	import com.metaedu.client.messages.nebula.ServerComplexChangeScreenInform;
	import com.metaedu.client.messages.nebula.ServerComplexChangeScreenModeInform;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import flash.external.ExternalInterface;
	import flash.net.getClassByAlias;
	
	import mx.controls.Alert;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	
	import spark.components.Group;
	
	public class ModeController extends AbstrackController
	{
		/**
		 * 当前正在显示的主view的id
		 * **/
		private var curMainViewId:int = -1;
		
		/**
		 * 当前正在现实的辅屏id
		 * **/
		private var curSubViewId:int = -1;
		
		public function ModeController(metaManager:MetaManager, modeId:int, container:Group=null)
		{
			super(metaManager, modeId, container);
			
			invalidateCommands();
		}
		
		private function invalidateCommands():void
		{
			registCommand(LocalCommandType.CMD_NAV_BLACKBORD);
			registCommand(LocalCommandType.CMD_NAV_COURSE);
			registCommand(LocalCommandType.CMD_NAV_CHAT);
			registCommand(LocalCommandType.CMD_NAV_FASTQUESTION);
			registCommand(LocalCommandType.CMD_NAV_MEDIA);
			registCommand(LocalCommandType.CMD_NAV_STUDENTLIST);
			registCommand(LocalCommandType.CMD_NAV_RESOURCES);
			registCommand(LocalCommandType.CMD_NAV_UPLOAD);
			registCommand(LocalCommandType.CMD_NAV_VIDEO_SHARE);
			registCommand(LocalCommandType.CMD_NAV_DESKTOP_SYN);
			
			registCommand(LocalCommandType.CMD_ACTIVITESCREEN_CHANGE);
			registCommand(LocalCommandType.CMD_SUBACTIVITESCREEN_CHANGE);
			
			registCommand(LocalCommandType.CMD_PARTICIPANTTYPE_CHANGE);
			registCommand(LocalCommandType.CMD_SCREEN_CLIP_STATUE);
			
			try
			{
				ExternalInterface.addCallback("onQuitShare",onQuitShare);
				
			} 
			catch(error:Error) 
			{
				
			}
			
		}
		
		private function onQuitShare(arg:String):void
		{
		
			if(ComplexConf.isClipScreen)
			{
				
				if(ComplexConf.activeScreen == NebulaScreenType.DESKTOP)
				{
					var info1:ClientComplexChangeScreen = new ClientComplexChangeScreen();
					info1.screen = NebulaScreenType.BOARD;
					
					info1.index = 1;
				
					sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,info1));
				}
				
				if(ComplexConf.subActiveScreen == NebulaScreenType.DESKTOP)
				{
					var info2:ClientComplexChangeScreen = new ClientComplexChangeScreen();
					info2.screen = NebulaScreenType.BOARD;
					
					info2.index = 2;
					
					sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,info2));
				}
					
			}else
			{
				if(ComplexConf.activeScreen == NebulaScreenType.DESKTOP)
				{
					var info:ClientComplexChangeScreen = new ClientComplexChangeScreen();
					info.screen = NebulaScreenType.BOARD;
					
					info.index = 1;
					
					sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,info));
				}
			}
		}
		
		override public function onCommand(cmd:LocalCommand):void
		{
			if(cmd.command == LocalCommandType.CMD_ACTIVITESCREEN_CHANGE)
			{
				onChangeCurMainScreen();
			}else if(cmd.command == LocalCommandType.CMD_SUBACTIVITESCREEN_CHANGE)
			{
				onChangeSubScreen();
			}
			else if(cmd.command == LocalCommandType.CMD_PARTICIPANTTYPE_CHANGE)
			{
				onSetParticipantTypePower();
			}else if(cmd.command == LocalCommandType.CMD_SCREEN_CLIP_STATUE)
			{
				onScreenClipStatueChange();
			}
			else
			{
				
				if(cmd.command == LocalCommandType.CMD_NAV_BLACKBORD || cmd.command == LocalCommandType.CMD_NAV_COURSE || 
					cmd.command == LocalCommandType.CMD_NAV_MEDIA || cmd.command == LocalCommandType.CMD_NAV_VIDEO_SHARE ||
					cmd.command == LocalCommandType.CMD_NAV_DESKTOP_SYN
				)
				{
					var va:int = NebulaScreenType.BOARD;
					
					if(cmd.command == LocalCommandType.CMD_NAV_BLACKBORD)
						va = NebulaScreenType.BOARD;
					else if(cmd.command == LocalCommandType.CMD_NAV_COURSE)
						va= NebulaScreenType.DOCUMENT;
					else if(cmd.command == LocalCommandType.CMD_NAV_MEDIA)
						va = NebulaScreenType.MULTIMEDIA;
					else if(cmd.command == LocalCommandType.CMD_NAV_VIDEO_SHARE)
						va = NebulaScreenType.LIVE;
					else if(cmd.command == LocalCommandType.CMD_NAV_DESKTOP_SYN)
						va = NebulaScreenType.DESKTOP;
					
					
					var changeInfo:ClientComplexChangeScreen = new ClientComplexChangeScreen();
					changeInfo.screen = va;
					changeInfo.index = cmd.data.isSub ? 2 : 1;
					
					sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,changeInfo));
					
				}else
				{
					addViewById(cmd.data.id);
				}
				
				
			}
		}
		
		
		override public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
			if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_CHANGE_SCREEN_INFORM)
			{
				onRcvChangeScreen(JsonUtils.convertJsonToClass(refContent,ServerComplexChangeScreenInform));
				
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_CHANGE_SCREEN_MODE_INFORM)
			{
				onRcvChangeScreenMode(JsonUtils.convertJsonToClass(refContent,ServerComplexChangeScreenModeInform));
			}
			
			
		}
		
		
		/**
		 * 分屏状态改变
		 * **/
		private function onScreenClipStatueChange():void
		{
			if(!ComplexConf.isClipScreen)
			{
				removeSubScreen();	
			}else
			{
				if(!(ComplexConf.activeScreen == NebulaScreenType.BOARD && ComplexConf.subActiveScreen == NebulaScreenType.BOARD) ||
					!(ComplexConf.activeScreen == NebulaScreenType.DESKTOP && ComplexConf.subActiveScreen == NebulaScreenType.DESKTOP)
				)
				{
					onChangeSubScreen();
				}
			}
			
			metaManager.mainClass.changeSize();
			
		}
		
		/**
		 * 收到切换主界面消息
		 * **/
		private function onRcvChangeScreen(info:ServerComplexChangeScreenInform):void
		{
			
			if(info.index == 2)
			{
				ComplexConf.subActiveScreen = info.screen;
			}else
			{
				ComplexConf.activeScreen = info.screen;
			}
			
		}
		
		/**
		 * 切换单双屏模式
		 * **/
		private function onRcvChangeScreenMode(info:ServerComplexChangeScreenModeInform):void
		{
			ComplexConf.isClipScreen = info.screenMode == NebulaScreenMode.DOUBLE;
		}
		
		/**
		 * 设置权限
		 * **/
		private function onSetParticipantTypePower():void
		{
			for each( var controller:IController in metaManager.controllers)
			{
				if(controller.modeView != null)
					controller.modeView.setParticipantTypePower(ComplexConf.participantType);
			}
		}
		
		/**
		 * 移除辅屏
		 * **/
		private function removeSubScreen():void
		{
			if(curSubViewId != -1)
			metaManager.getControllerById(curSubViewId).removeView();
			
			metaManager.mainClass.subContent.width = 0;
		}
	
		
		/**
		 * 切换辅屏的当前视图
		 * **/
		private function onChangeSubScreen():void
		{
			metaManager.mainClass.changeSize();
			
			if(ComplexConf.subActiveScreen == NebulaScreenType.BOARD)
			{
				if(ComplexConf.isClipScreen && ComplexConf.activeScreen == NebulaScreenType.BOARD && ComplexConf.subActiveScreen == NebulaScreenType.BOARD)
					removeSubScreen();
				else
				{
					if(ComplexConf.isClipScreen)
						changeCurrentSubView(ModeTypes.MODE_SUB_BLACKBORD_ID);
				}
					
			}
			else if(ComplexConf.subActiveScreen == NebulaScreenType.DOCUMENT)
			{
				if(ComplexConf.isClipScreen)
					changeCurrentSubView(ModeTypes.MODE_SUB_COURSE_ID);
				
			}else if(ComplexConf.subActiveScreen == NebulaScreenType.MULTIMEDIA)
			{
				if(ComplexConf.isClipScreen)
				changeCurrentSubView(ModeTypes.MODE_SUB_MEDIA_ID);
				
			}else if(ComplexConf.subActiveScreen == NebulaScreenType.LIVE)
			{
				if(ComplexConf.isClipScreen)
				changeCurrentSubView(ModeTypes.MODE_SUB_LIVEVIDEO_SHARE_ID);
			}else if(ComplexConf.subActiveScreen == NebulaScreenType.DESKTOP)
			{
				
				if(ComplexConf.isClipScreen && ComplexConf.activeScreen == NebulaScreenType.DESKTOP && ComplexConf.subActiveScreen == NebulaScreenType.DESKTOP)
					removeSubScreen();
				else
				{
					if(ComplexConf.isClipScreen)
						changeCurrentSubView(ModeTypes.MODE_SUB_SYN_DESKTOP_ID);
				}
					
				
			}
		}
		
		/**
		 * 替换互斥的第二屏幕模块
		 * **/
		private function changeCurrentSubView(nextId:int):void
		{
			var cur:AbstrackController = metaManager.getControllerById(curSubViewId);
			var next:AbstrackController = metaManager.getControllerById(nextId);
			
			
			if(cur != null)
				cur.removeView();
			
			if(next != null)
			{
				next.addView();
				
				next.modeView.setParticipantTypePower(ComplexConf.participantType);
				
			}
			
			curSubViewId = nextId;
			
			
		}
		
		/**
		 * 切换当前最下层视图
		 * **/
		private function onChangeCurMainScreen():void
		{
			if(ComplexConf.isClipScreen && ( ComplexConf.activeScreen == NebulaScreenType.BOARD && ComplexConf.subActiveScreen == NebulaScreenType.BOARD
				|| ComplexConf.activeScreen == NebulaScreenType.DESKTOP && ComplexConf.subActiveScreen == NebulaScreenType.DESKTOP
				
			))
				removeSubScreen();
		
			metaManager.mainClass.changeSize();
			
			if(ComplexConf.activeScreen == NebulaScreenType.BOARD)
			{
				changeCurrentView(ModeTypes.MODE_BLACKBORD_ID);
				
				if(ComplexConf.isClipScreen && ComplexConf.subActiveScreen == NebulaScreenType.DESKTOP)
					onChangeSubScreen();
				
				
			}else if(ComplexConf.activeScreen == NebulaScreenType.DOCUMENT)
			{
				changeCurrentView(ModeTypes.MODE_COURSE_ID);
				
				if(ComplexConf.isClipScreen && (ComplexConf.subActiveScreen == NebulaScreenType.BOARD || ComplexConf.subActiveScreen == NebulaScreenType.DESKTOP))
					onChangeSubScreen();
				
			}else if(ComplexConf.activeScreen == NebulaScreenType.MULTIMEDIA)
			{
				changeCurrentView(ModeTypes.MODE_MEDIA_ID);
				
				if(ComplexConf.isClipScreen && (ComplexConf.subActiveScreen == NebulaScreenType.BOARD || ComplexConf.subActiveScreen == NebulaScreenType.DESKTOP))
					onChangeSubScreen();
				
			}else if(ComplexConf.activeScreen == NebulaScreenType.LIVE)
			{
				changeCurrentView(ModeTypes.MODE_LIVEVIDEO_SHARE_ID);
				
				if(ComplexConf.isClipScreen && (ComplexConf.subActiveScreen == NebulaScreenType.BOARD || ComplexConf.subActiveScreen == NebulaScreenType.DESKTOP))
					onChangeSubScreen();
			}else if(ComplexConf.activeScreen == NebulaScreenType.DESKTOP)
			{
				changeCurrentView(ModeTypes.MODE_SYN_DESKTOP_ID);
			}
			
		}
		
		/**
		 * 替换互斥的view
		 * **/
		private function changeCurrentView(nextId:int):void
		{
			var cur:AbstrackController = metaManager.getControllerById(curMainViewId);
			var next:AbstrackController = metaManager.getControllerById(nextId);
			
			
			if(cur != null)
				cur.removeView();
			
			next.addView();
			
			curMainViewId = nextId;
			
			next.modeView.setParticipantTypePower(ComplexConf.participantType);
		}
		
		/**
		 * 非互斥模块view
		 * **/
		private function addViewById(id:int):void
		{
			var controller:AbstrackController = metaManager.getControllerById(id);
			
			if(!controller.resident)
			{
				if(controller.modeView != null)
					controller.removeView();
				else
					controller.addView();
				
			}else
			{
				if(controller.modeView == null)
					controller.addView();
				else
				{
					var mView:IVisualElement = controller.modeView as IVisualElement;
					
					var parent:IVisualElementContainer = mView.parent as IVisualElementContainer;
					
					mView.visible = !mView.visible;
					
					parent.setElementIndex(mView,parent.numElements - 1);
					
				}
				
			}
			
			
			if(controller.modeView != null)
				controller.modeView.setParticipantTypePower(ComplexConf.participantType);
		}
		
		
	}
}