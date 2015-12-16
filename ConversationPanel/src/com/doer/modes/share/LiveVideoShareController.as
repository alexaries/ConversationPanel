package com.doer.modes.share
{
	import com.doer.config.ComplexConf;
	import com.doer.config.ModeTypes;
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.modes.live.LiveController;
	import com.doer.modes.live.process.LiveVideoManager;
	import com.doer.modes.live.tools.LiveVideoInfo;
	import com.doer.modes.live.video.LiveVideoRender;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ClientComplexChangeScreen;
	import com.metaedu.client.messages.nebula.ClientComplexLiveCtrl;
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;
	import com.metaedu.client.messages.nebula.NebulaParticipantType;
	import com.metaedu.client.messages.nebula.NebulaScreenType;
	import com.metaedu.client.messages.nebula.ServerComplexEnterResp;
	import com.metaedu.client.messages.nebula.ServerComplexLiveCtrlInform;
	import com.metaedu.client.messages.nebula.complex.LiveContainer;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import flash.utils.setTimeout;
	
	import spark.components.Group;
	
	import view.modes.share.LiveVideoShareView;
	
	public class LiveVideoShareController extends AbstrackController
	{
		/**
		 * 当前正在分享的视频id
		 * **/
		public var active:String = "";
		
		/**
		 * 是否第二摄像头
		 * **/
		public var liveIndex:int = 1;
		
		/**
		 * 主屏
		 * **/
		public var screenIndex:int = 1;
		
		public function LiveVideoShareController(metaManager:MetaManager, modeId:int, container:Group=null)
		{
			super(metaManager, modeId, container);
			
			
			invalidateCommands();
		}
		
		private function invalidateCommands():void
		{
			registCommand(LocalCommandType.CMD_LIVE_INVALIDATED);	
			registCommand(LocalCommandType.CMD_RENDER_CHANGE);
		}
		
		override public function onCommand(cmd:LocalCommand):void
		{
			if(cmd.command == LocalCommandType.CMD_LIVE_INVALIDATED)
			{
				//removeCommand(LocalCommandType.CMD_LIVE_INVALIDATED);
				
				onLoginInfo(cmd.data as ServerComplexEnterResp);
				
			}else if(cmd.command == LocalCommandType.CMD_RENDER_CHANGE)
			{
				var shareView:LiveVideoShareView = modeView as LiveVideoShareView;
				
				if(shareView != null)
				{
					shareView.invalidate();
				}
			}
		}
		
		protected function onLoginInfo(loginInfo:ServerComplexEnterResp):void
		{
		
			if(ComplexConf.activeScreen == NebulaScreenType.LIVE || ComplexConf.subActiveScreen == NebulaScreenType.LIVE)
			{
				var lives:LiveContainer = loginInfo.lives;
				
				if(screenIndex == 1)
				{
					this.active = lives.activeLive;
					this.liveIndex = lives.activeLiveIndex;
				}else
				{
					this.active = lives.activeLive2;
					this.liveIndex = lives.activeLiveIndex2;
				}
				
				
			}
			
			
		}
		
		public function getRender(id:String,isDoubleCamera:Boolean):LiveVideoRender
		{
			return (metaManager.getControllerById(ModeTypes.MODE_LIVEVIDEO_ID) as LiveController).liveManager.getRender(id,isDoubleCamera);
			
		}
		
		public function getLiveVideoInfo():Vector.<LiveVideoInfo>
		{
			return (metaManager.getControllerById(ModeTypes.MODE_LIVEVIDEO_ID) as LiveController).getLiveVideoInfo(); 
		}
		
		/**
		 * 分享视频
		 * **/
		public function sendShareVideoInfo(videoInfo:LiveVideoInfo):void
		{	
			
			var shareController:LiveVideoShareController = screenIndex == 1 ? 
				metaManager.getControllerById(ModeTypes.MODE_SUB_LIVEVIDEO_SHARE_ID) as LiveVideoShareController : 
				metaManager.getControllerById(ModeTypes.MODE_LIVEVIDEO_SHARE_ID) as LiveVideoShareController;
			
			if(shareController.active == videoInfo.id && (shareController.liveIndex == 2) == videoInfo.isDoubleCamera)
			{
				var ctrInfo:ClientComplexLiveCtrl = new ClientComplexLiveCtrl();
				
				ctrInfo.index = shareController.screenIndex;
				ctrInfo.liveIndex = 1;
				ctrInfo.id = "";
				
				sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,ctrInfo));
			}
			
			var info:ClientComplexLiveCtrl = new ClientComplexLiveCtrl();
			
			info.index = screenIndex;
			info.liveIndex = videoInfo.isDoubleCamera ? 2 : 1;
			info.id = videoInfo.id;
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,info));
			
			
			
		}
		
		override public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
			if(NebulaMessageBusinessType.SERVER_COMPLEX_LIVE_CTRL_INFORM)
			{
				onRcvShareVideoInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexLiveCtrlInform));
			}
		}
		
		/**
		 * 收到视频源消息
		 * **/
		protected function onRcvShareVideoInfo(info:ServerComplexLiveCtrlInform):void
		{
			var render:LiveVideoRender =  (metaManager.getControllerById(ModeTypes.MODE_LIVEVIDEO_ID) as LiveController).liveManager.getRender(info.id,info.liveIndex == 2);
			
			var shareView:LiveVideoShareView = modeView as LiveVideoShareView;
			
			if(info.id == "")
			{
				
				if(info.index == screenIndex)
				{
					this.active = "";
					this.liveIndex = 1;
					
					if(shareView != null)
						shareView.removeRender();
					
				}
				
				
			}else
			{
				
				if(info.index == screenIndex)
				{
					this.active = info.id;
					this.liveIndex = info.liveIndex;
					
					if(shareView != null)
						shareView.setRender(render);
				}
			}
	
		}
		
		override public function registView():IView
		{
			return new LiveVideoShareView();
		}
		
		
		
	}
}