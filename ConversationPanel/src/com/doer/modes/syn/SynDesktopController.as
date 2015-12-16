package com.doer.modes.syn
{
	import com.doer.config.ComplexConf;
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ClientComplexDesktopCtrl;
	import com.metaedu.client.messages.nebula.ClientComplexDesktopPublish;
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;
	import com.metaedu.client.messages.nebula.ServerComplexDesktopCtrlInform;
	import com.metaedu.client.messages.nebula.ServerComplexDesktopPublishInform;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import spark.components.Group;
	
	import view.modes.syn.SynDesktopView;
	
	public class SynDesktopController extends AbstrackController
	{
		public function SynDesktopController(metaManager:MetaManager, modeId:int, container:Group=null)
		{
			super(metaManager, modeId, container);
		}
		
		override public function reset():void
		{
			if(modeView != null)
				removeView();
		}
		
		/**
		 * 发送同步消息
		 * **/
		public function sendSynInfo(videoKey:String,time:Number,detail:String):void
		{
			
			var info:ClientComplexDesktopPublish = new ClientComplexDesktopPublish();
			
			info.url = videoKey;
			info.time = time.toString();
			info.detail = detail;
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,info));
			
		}
		
		override public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
			if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_DESKTOP_PUBLISH_INFORM)
			{
				onRcvSynInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexDesktopPublishInform));
			}
		}
		
		/**
		 * 收到同步桌面消息
		 * **/
		private function onRcvSynInfo(info:ServerComplexDesktopPublishInform):void
		{
			if(modeView != null)
			{
				(modeView as SynDesktopView).onRcvSynInfo(info.url,info.detail,Number(info.time));
			}
		}
		
		override public function registView():IView
		{
			return new SynDesktopView();
		}
		
	}
}