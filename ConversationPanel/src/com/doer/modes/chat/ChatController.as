package com.doer.modes.chat
{
	import com.doer.config.ComplexConf;
	import com.doer.interfaces.ISProcessor;
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ClientComplexChat;
	import com.metaedu.client.messages.nebula.ClientComplexChatCtrl;
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;
	import com.metaedu.client.messages.nebula.ServerComplexChatInform;
	import com.metaedu.client.messages.nebula.ServerPassiveOutInform;
	import com.metaedu.client.messages.nebula.ServerSignInResp;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import spark.components.Group;
	
	import view.modes.chat.ChatView;
	
	public class ChatController extends AbstrackController 
	{
		private var chatDatas:Array = new Array();
		
		public var chatNotReadNums:int = 0;
		
		public function ChatController(metaManager:MetaManager, modeId:int, container:Group=null)
		{
			super(metaManager, modeId, container);
			
			registCommand(LocalCommandType.CMD_NAV_CHAT);
			registCommand(LocalCommandType.CMD_CHAT_POWER_CHANGE);
			
		}
		
		override public function reset():void
		{
			if(modeView != null)
				removeView();
		}
		
		/**
		 * 获取初始化聊天信息
		 * **/
		public function getInvalidateData():Array
		{
			return chatDatas;
		}
		
		/**
		 * 发送聊天消息
		 * **/
		public function sendChatMsg(content:String):void
		{
			var obj:Object = {id : ComplexConf.userId, content : content};
			
			var chatInfo:ClientComplexChat = new ClientComplexChat();
			
			chatInfo.content = content;
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,chatInfo));
			
			chatDatas.push({id : ComplexConf.userId, content : content});
			
			if(chatDatas.length > 100)
				chatDatas.shift();
			
			(modeView as ChatView).onRefresh(obj);
		}
		
		
		override public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
			if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_CHAT_INFORM)
			{
				onRcvChat(JsonUtils.convertJsonToClass(refContent,ServerComplexChatInform));
			}
		}
		
		/**
		 * 收到聊天
		 * **/
		private function onRcvChat(chatInfo:ServerComplexChatInform):void
		{
			chatDatas.push({id : chatInfo.id, content : chatInfo.content});
			
			if(chatDatas.length > 100)
				chatDatas.shift();
			
			if(modeView != null )
			{
				(modeView as ChatView).onRefresh({id : chatInfo.id, content : chatInfo.content});
			}
				
			if(modeView == null || !(modeView as ChatView).visible || !(modeView as ChatView).isUpdate)
			{
				if(chatInfo.id != ComplexConf.userId)
				{
					chatNotReadNums ++;
					
					sendCommand(new LocalCommand(LocalCommandType.CMD_SET_NAV_NUMS,{chat : chatNotReadNums}));
				}
				
			}else
			{
				clearNotRead();
			}
		}
		
		/**
		 * 清除未读
		 * **/
		public function clearNotRead():void
		{
			chatNotReadNums = 0;
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SET_NAV_NUMS,{chat : chatNotReadNums}));
		}
		
		override public function get resident():Boolean
		{
			return true;
		}
		
		override public function onCommand(cmd:LocalCommand):void
		{
			if(cmd.command == LocalCommandType.CMD_NAV_CHAT)
			{
				clearNotRead();
			}else if(cmd.command == LocalCommandType.CMD_CHAT_POWER_CHANGE)
			{
				if(modeView != null)
				(modeView as ChatView).onPowerChange();
			}
		}
		
		override public function registView():IView
		{
			var chatView:ChatView = new ChatView();
			
			chatView.x = container.width/2 - chatView.width/2;
			
			chatView.y = container.height/2 - chatView.height/2;
			
			return chatView;
		}
		
		/**
		 * 切换聊天权限
		 * **/
		public function onExchangeChat():void
		{
			ComplexConf.enableChat = !ComplexConf.enableChat;
			
			var msg:ClientComplexChatCtrl = new ClientComplexChatCtrl();
			msg.enable = ComplexConf.enableChat;
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,msg));
			
		}
		
		
		
	}
}