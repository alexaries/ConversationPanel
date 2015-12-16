package com.doer.modes.blackbord
{
	import com.doer.common.Delegation;
	import com.doer.common.interfaces.IDelegate;
	import com.doer.config.AppConf;
	import com.doer.config.ComplexConf;
	import com.doer.interfaces.ISProcessor;
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.meta.paint.ShapeStyle;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.modes.nav.MainNavController;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ClientComplexClean;
	import com.metaedu.client.messages.nebula.ClientComplexDraw;
	import com.metaedu.client.messages.nebula.ClientComplexMove;
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;
	import com.metaedu.client.messages.nebula.NebulaParticipantType;
	import com.metaedu.client.messages.nebula.NebulaScreenType;
	import com.metaedu.client.messages.nebula.ServerComplexCleanInform;
	import com.metaedu.client.messages.nebula.ServerComplexDrawInform;
	import com.metaedu.client.messages.nebula.ServerComplexEnterResp;
	import com.metaedu.client.messages.nebula.ServerComplexMoveInform;
	import com.metaedu.client.messages.nebula.ServerComplexTalkingStatusInform;
	import com.metaedu.client.messages.nebula.ServerPassiveOutInform;
	import com.metaedu.client.messages.nebula.ServerSignInResp;
	import com.metaedu.client.messages.nebula.complex.draw.Dot;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import mx.containers.Canvas;
	
	import spark.components.Group;
	
	import view.modes.blackbord.BlackbordView;
	
	public class BlackbordController extends AbstrackController implements IDelegate
	{
		public var blackbordMode:BlackbordMode = null;
		
		public var delegation:Delegation = new Delegation();
		
		public function BlackbordController(manager:MetaManager, modeId:int,container:Group)
		{
			blackbordMode = BlackbordMode.getInstance();
			
			super(manager, modeId,container);
			
			invalidateCommands();
		}
		
		private function invalidateCommands():void
		{
			registCommand(LocalCommandType.CMD_LOGIN_COMPLETE);
			registCommand(LocalCommandType.CMD_NAV_PEN);
			registCommand(LocalCommandType.CMD_NAV_ERASER);
			registCommand(LocalCommandType.CMD_NAV_CLEAR);
			registCommand(LocalCommandType.CMD_NAV_TEXT);
			registCommand(LocalCommandType.CMD_NAV_HAND);
			
		}
		
		override public function reset():void
		{
			blackbordMode.clearData();
			
			if(modeView != null)
				removeView();
			
		}

		/**
		 * 发送移动消息到服务端
		 * **/
		public function sendMoveInfo(x:Number):void
		{
			if(ComplexConf.participantType == NebulaParticipantType.CHARGE || ComplexConf.participantType == ComplexConf.Temp_ParticipantType )
			{
				var moveInfo:ClientComplexMove = new ClientComplexMove();
				
				moveInfo.x = x;
				moveInfo.screen = NebulaScreenType.BOARD;
				moveInfo.index = delegation.isSecondScreen ? 2 : 1;
				
				blackbordMode.showX = x;
				
				sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,moveInfo));
			}
		}
		
		public function saveDelegatePaintdata(data:Object):void
		{
			blackbordMode.savePaintData(data);

			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,BlackbordMode.changeLocalDataToSendData(data,delegation.isSecondScreen)));
			
		}

		public function getInvalidatePaintdata(bookId:String,pageId:int):Array
		{
			return blackbordMode.getInvalidateData();
		}
		
		public function clear():void
		{
			blackbordMode.clearData();
			
			var clearInfo:ClientComplexClean = new ClientComplexClean();
			
			clearInfo.screen = NebulaScreenType.BOARD
			clearInfo.index = delegation.isSecondScreen ? 2 : 1;
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,clearInfo));
		}

		override public function onCommand(cmd:LocalCommand):void
		{
			if(cmd.command == LocalCommandType.CMD_LOGIN_COMPLETE)
			{
//				removeCommand(LocalCommandType.CMD_LOGIN_COMPLETE); //移除监听
				
				onLoginInfo(cmd.data as ServerComplexEnterResp);
				
			}else
			{
				if(modeView != null)
				{
					delegation.onCommand(cmd);
				}
			}
		}
		
		private function onLoginInfo(loginInfo:ServerComplexEnterResp):void
		{
			blackbordMode.onLoginInfo(loginInfo.board);
				
			if(loginInfo.activeScreen == NebulaScreenType.BOARD)
			{
				ComplexConf.activeScreen = NebulaScreenType.BOARD;
			}
		}
		
		override public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
			if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_DRAW_INFORM)
			{
				onRcvServerDrawInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexDrawInform));
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_MOVE_INFORM)
			{
				onRcvMoveInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexMoveInform));
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_CLEAN_INFORM)
			{
				onRcvCleanInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexCleanInform));
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_TALKING_STATUS_INFORM)
			{
				onRcvTalkInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexTalkingStatusInform));
			}
		}
		
		/**
		 * 收到授权消息
		 * **/
		private function onRcvTalkInfo(info:ServerComplexTalkingStatusInform):void
		{
			if(!info.enable && info.id == ComplexConf.userId)
			{
				if(modeView != null)
				{
					(modeView as BlackbordView).getCanvas().active = false;
					
				}
				
				delegation.removeTextCompent();
			}
		}
		
		/**
		 * 清除
		 * **/
		private function onRcvCleanInfo(cleanInfo:ServerComplexCleanInform):void
		{
			if(cleanInfo.screen == NebulaScreenType.BOARD)
			{
				blackbordMode.clearData();
				
				var blackBord:BlackbordView = modeView as BlackbordView;
				
				if(blackBord != null && blackBord.getCanvas() != null && 
					(cleanInfo.index == 2 && delegation.isSecondScreen || cleanInfo.index == 1 && !delegation.isSecondScreen))
				blackBord.getCanvas().clear();
			}
		}
		
		/**
		 * 收到移动消息
		 * **/
		private function onRcvMoveInfo(moveInfo:ServerComplexMoveInform):void
		{
			if(moveInfo.screen == NebulaScreenType.BOARD)
			{
				
				var blackBord:BlackbordView = modeView as BlackbordView;
				
				if(blackBord != null && blackBord.canvas != null && (moveInfo.index == 2 && delegation.isSecondScreen || moveInfo.index == 1 && !delegation.isSecondScreen))
				{
					var rect:Rectangle = blackBord.getCanvas().getShowArea();
					
					blackBord.showPaintArea(moveInfo.x * rect.height);
					blackBord.setNotch();
				}
			}
			
		}
		
		/**
		 * 收到绘图消息
		 * **/
		private function onRcvServerDrawInfo(drawInfo:ServerComplexDrawInform):void
		{
			if(drawInfo.screen == NebulaScreenType.BOARD)
			{
				var data:Object = BlackbordMode.changeServDataToLocal(drawInfo);
				
				blackbordMode.savePaintData(data);
				
				if(drawInfo.index == 2 && delegation.isSecondScreen || drawInfo.index == 1 && !delegation.isSecondScreen)
				{
					delegation.addPaintData(data);
				}
			}
			
			
		}
		
		override public function registView():IView
		{
			var bord:BlackbordView = new BlackbordView();
			
			bord.delegation = delegation;
			
			return bord;
		}
		
	}
}