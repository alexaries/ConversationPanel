package com.doer.vmode
{
	import com.doer.config.ModeTypes;
	import com.doer.manager.MetaManager;
	import com.doer.net.login.LoginController;
	import com.metaedu.client.messages.nebula.ServerComplexEnterResp;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import flash.events.Event;
	
	import view.modes.mvmode.VideoView;

	public class VideoAnalysis
	{
		private var metaManager:MetaManager = null;
		
		private var dataMode:AnalysisMode = null;
		
		private var videoView:VideoView = null;
		
		private var patcher:AnalysisPatcher = null;
		
		public function VideoAnalysis(metaManager:MetaManager,videoView:VideoView)
		{
			this.metaManager = metaManager;
			this.videoView = videoView;
			
			videoView.analysis = this;
			
			dataMode = new AnalysisMode();
			dataMode.loadData();
			dataMode.addEventListener(Event.COMPLETE,onLoadComplete);
	
			patcher = new AnalysisPatcher(metaManager,dataMode,this);
				
		}
		
		private function onLoadComplete(e:Event):void
		{
			dataMode.removeEventListener(Event.COMPLETE,onLoadComplete);
			
			metaManager.mainClass.videoMask.visible = true;
			
			(metaManager.getControllerById(ModeTypes.MODE_LOGIN_ID) as LoginController).onLoginConversationReplay(JsonUtils.convertJsonToClass(dataMode.datas[0].data,ServerComplexEnterResp));
			
			videoView.totalTime = dataMode.getTotalTime();
			
		}
		
		/**
		 * 时间
		 * **/
		public function onTime(time:Number):void
		{
			videoView.onTime(time);
		}
		
		/**
		 * 播放完成
		 * **/
		public function onComplete():void
		{
			videoView.onComplete();
		}
		
		/**
		 * 快进/快退
		 * **/
		public function seek(time:Number):void
		{
			patcher.seek(time);
		}
		
		/**
		 * 播放
		 * **/
		public function play():void
		{
			patcher.play();
		}
		
		/**
		 * 暂停
		 * **/
		public function pause():void
		{
			patcher.pause();
		}
		
	}
}