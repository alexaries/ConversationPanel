package com.doer.modes.live.video
{
	import com.doer.config.AppConf;
	import com.doer.config.ComplexConf;
	import com.doer.modes.live.tools.LiveVideoInfo;
	import com.doer.utils.LocalEvent;
	import com.strong.rtmp.RtmpProtocolType;
	import com.strong.rtmp.RtmpRecorderEvent;
	import com.strong.rtmp.RtmpSeparateRecorder;
	import com.strong.rtmp.RtmpSeparateRender;
	
	import flash.display.Sprite;
	
	import mx.core.UIComponent;
	
	import view.modes.live.LiveVideo;
	import view.modes.share.LiveShareTool;

	public class LiveVideoRender
	{
		
		/**
		 * 视频详情
		 * **/
		public var videoInfo:LiveVideoInfo = null;
		
		/**
		 * 录制器
		 * **/
		public var recorder:RtmpSeparateRecorder = null;
		
		/**
		 * 监听器
		 * **/
		public var render:RtmpSeparateRender = null;
		
		/**
		 * 持有的video
		 * **/
		public var video:LiveVideo = null;
		
		/**
		 * video容器
		 * **/
		public var videoContainer:UIComponent = null;
		
		/**
		 * 渲染模式
		 * **/
		public var rendMode:String = LiveShareTool.fill_width;
		
		public function LiveVideoRender(video:LiveVideo,videoInfo:LiveVideoInfo)
		{
			this.videoInfo = videoInfo;
			this.video = video;
			
			this.videoContainer = video.ui;
			
			invalidate();
		}
		
		private function invalidateContent():void
		{
			setRecorderSize();
			setRenderSize();
			
			if( videoInfo.renderVideoKey != null)
			{
				if(!videoContainer.contains(render))
					videoContainer.addChild(render);
			}else
			{
				if(videoContainer.contains(render))
					videoContainer.removeChild(render);
			}
				
			if(videoInfo.recorderVideoKey != null)
			{
				if(!videoContainer.contains(recorder))
					videoContainer.addChild(recorder);
			}else
			{
				if(videoContainer.contains(recorder))
					videoContainer.removeChild(recorder);
			}
		
		}
		
		/**
		 * 设置分享到屏幕
		 * **/
		public function setShare(ui:UIComponent,rendMode:String):void
		{
			this.rendMode = rendMode;
			this.videoContainer = ui;
			
			invalidateContent();
		}
		
		/**
		 * 设置大小
		 * **/
		public function resizeContainer():void
		{
			setRenderSize();
			setRecorderSize();
		}
		
		private function setRecorderSize():void
		{
			var sX:Number = 1;
			var sY:Number = 1;
			
			if(rendMode == LiveShareTool.fill_width)
			{
				sY = sX = videoContainer.width / videoInfo.recordWidth;
			}else if(rendMode == LiveShareTool.fill_height)
			{
				sX = sY = videoContainer.height / videoInfo.recordHeight;
			}else if(rendMode == LiveShareTool.fill_screen)
			{
				sX = videoContainer.width / videoInfo.recordWidth;
				sY = videoContainer.height / videoInfo.recordHeight;
				
			}
			
			recorder.width = videoInfo.recordWidth * sX;
			recorder.height = videoInfo.recordHeight * sY;
			
			recorder.x = videoContainer.width / 2 - recorder.width / 2;
			recorder.y = videoContainer.height / 2 - recorder.height / 2;
		}
		
		private function setRenderSize():void
		{
			var sX:Number = 1;
			var sY:Number = 1;
			
			if(rendMode == LiveShareTool.fill_width)
			{
				sY = sX = videoContainer.width / videoInfo.rendWidth;
			}else if(rendMode == LiveShareTool.fill_height)
			{
				sX = sY = videoContainer.height / videoInfo.rendHeight;
			}else if(rendMode == LiveShareTool.fill_screen)
			{
				sX = videoContainer.width / videoInfo.rendWidth;
				sY = videoContainer.height / videoInfo.rendHeight;
				
			}
		
			render.width = videoInfo.rendWidth * sX;
			render.height = videoInfo.rendHeight * sY;
			
			render.x = videoContainer.width / 2 - render.width / 2;
			render.y = videoContainer.height / 2 - render.height / 2;
		}
		
		/**
		 * 恢复分享
		 * **/
		public function restore():void
		{
			this.videoContainer = video == null ? null : video.ui;
			this.rendMode = LiveShareTool.fill_width;
			
			if(videoContainer != null)
				invalidateContent();
		}
		
		/***
		 * 初始化
		 * **/
		public function invalidate():void
		{
			render = new RtmpSeparateRender(videoInfo.rendWidth,videoInfo.rendHeight);
			render.setProtocol(RtmpProtocolType.RTMP,1935,80);
			
			recorder = new RtmpSeparateRecorder(true,false,videoInfo.recordWidth,videoInfo.recordHeight);
			recorder.setProtocol(RtmpProtocolType.RTMP,1935,80);
			
			
			recorder.addEventListener(RtmpRecorderEvent.AUDIO_RECORD_CHECK,onAudioCheckHandler);
			recorder.addEventListener(RtmpRecorderEvent.VIDEO_RECORD_CHECK,onVideoCheckHandler);
			
			
		}
		
		/**
		 * 音频检查
		 * **/
		private function onAudioCheckHandler(e:RtmpRecorderEvent):void
		{
			video.dispatchEvent(new LocalEvent(LiveVideo.LIVE_AUDIO_CHECK,{isDoubleCamera : videoInfo.isDoubleCamera, info : e.info}));
		}
		
		/**
		 * 视频检查
		 * **/
		private function onVideoCheckHandler(e:RtmpRecorderEvent):void
		{
			video.dispatchEvent(new LocalEvent(LiveVideo.LIVE_VIDEO_CHECK,{isDoubleCamera : videoInfo.isDoubleCamera, info : e.info}));
		}
		
		
		/**
		 * 打开音频渲染
		 * **/
		public function openAudioRender(audioKey:String,time:Number):void
		{
			videoInfo.renderAudioKey = audioKey;
			
			if(!AppConf.isRecord)
				render.openAudio(videoInfo.address,videoInfo.renderAudioKey);
			else
				render.openAudio(videoInfo.address,videoInfo.renderAudioKey,true,time);
			
			render.setVolume(videoInfo.soundVolume);
		}
		
		/**
		 * 移除音频渲染
		 * **/
		public function removeAudioRender():void
		{
			videoInfo.renderAudioKey = null;
			
			render.closeAudio();
		}
		
		/**
		 * 打开视频渲染
		 * **/
		public function openVideoRender(videoKey:String,time:Number):void
		{
			videoInfo.renderVideoKey = videoKey;
			
			if(!AppConf.isRecord)
				render.openVideo(videoInfo.address,videoInfo.renderVideoKey);
			else
				render.openVideo(videoInfo.address,videoInfo.renderVideoKey,true,time);
			
			invalidateContent();
			
		}
		
		/**
		 * 移除视频渲染
		 * **/
		public function removeVideoRender():void
		{
			videoInfo.renderVideoKey = null;
			
			render.closeVideo();
			
			invalidateContent();
		}
		
		/**
		 * 打开音频录制
		 * **/
		public function openAudioRecord(audioKey:String):void
		{
			videoInfo.recorderAudioKey = audioKey;
			
			recorder.openAudio(videoInfo.address, videoInfo.recorderAudioKey, videoInfo.micphoneIndex, videoInfo.micphoneVolume);
		}
		
		/**
		 * 移除音频录制
		 * **/
		public function removeAudioRecord():void
		{
			videoInfo.recorderAudioKey = null;
			
			recorder.closeAudio();
		}
		
		/**
		 * 打开视频录制
		 * **/
		public function openVideoRecord(videoKey:String):void
		{
			
			videoInfo.recorderVideoKey = videoKey;
			
			recorder.openVideo(videoInfo.address, videoInfo.recorderVideoKey, videoInfo.cameraIndex, videoInfo.recordWidth, videoInfo.recordHeight, 8192*5);
			
			invalidateContent();
			
		}
		
		/**
		 * 移除视频录制
		 * **/
		public function removeVideoRecord():void
		{
			videoInfo.recorderVideoKey = null;
			
			recorder.closeVideo();
			
			invalidateContent();
		}
		
		/**
		 * 刷新设置参数
		 * **/
		public function onRefreshProperty():void
		{
			render.setVolume(videoInfo.soundVolume);
			
			if(videoInfo.recorderAudioKey != null)
				openAudioRecord(videoInfo.recorderAudioKey);
			
			if(videoInfo.recorderVideoKey != null)
				openVideoRecord(videoInfo.recorderVideoKey);
			
		}
		
		/**
		 * 销毁资源
		 * **/
		public function onDestroy():void
		{
			
			if(videoContainer.contains(recorder))
				videoContainer.removeChild(recorder);
			
			
			if(videoContainer.contains(render))
				videoContainer.removeChild(render);
			
			if(videoInfo.recorderVideoKey != null)
				recorder.closeVideo();
			
			if(videoInfo.recorderAudioKey != null)
				recorder.closeAudio();
			
			if(videoInfo.renderVideoKey != null)
				render.closeVideo();
				
			if(videoInfo.renderAudioKey != null)
				render.closeAudio();
			
			
			recorder.removeEventListener(RtmpRecorderEvent.AUDIO_RECORD_CHECK,onAudioCheckHandler);
			recorder.removeEventListener(RtmpRecorderEvent.VIDEO_RECORD_CHECK,onVideoCheckHandler);
			
			recorder = null;
			render = null;
			
			video = null;
			videoInfo = null;
			
		}
		
	}
}