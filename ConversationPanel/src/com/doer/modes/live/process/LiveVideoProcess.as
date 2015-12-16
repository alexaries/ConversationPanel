package com.doer.modes.live.process
{
	import com.doer.config.AppConf;
	import com.doer.config.ComplexConf;
	import com.doer.modes.live.tools.LiveVideoInfo;
	import com.doer.modes.live.video.LiveVideoRender;
	import com.metaedu.client.messages.nebula.NebulaParticipantType;
	import com.metaedu.client.messages.nebula.NebulaPlatformType;
	import com.metaedu.client.utils.text.TimeUtils;
	import com.strong.rtmp.RtmpSeparateRender;
	
	import view.modes.live.LiveVideo;
	import view.modes.live.LiveView;

	public class LiveVideoProcess
	{
		/**
		 * video详情
		 * **/
		public var videoInfo:LiveVideoInfo = null;
		
		/**
		 * view
		 * **/
		private var liveView:LiveView = null;
		
		/**
		 * 持有的video
		 * **/
		private var video:LiveVideo = null;
		
		public function LiveVideoProcess(liveView:LiveView,id:String,isDoubleCamera:Boolean)
		{
			this.liveView = liveView;
			
			invalidateVideoInfo(id,isDoubleCamera);
		}
		
		private function invalidateVideoInfo(id:String,isDoubleCamera:Boolean):void
		{
			
			var detail:String = isDoubleCamera ? ComplexConf.videoDetail2 : ComplexConf.videoDetail1;
			
			var arr:Array = detail.split("x");
			
			videoInfo = new LiveVideoInfo(id,null,null,Number(arr[0]),Number(arr[1]),AppConf.isRecord ? "rtmp://" + AppConf.streamAddr + "/livod" : AppConf.rtmpLiveAddress,false,isDoubleCamera); 
			
			video = liveView.getRenderVideo(id,isDoubleCamera);
			video.setInfo(videoInfo);
			
		}
		
		/**
		 * video标示
		 * **/
		public function get id():String
		{
			return videoInfo.id;
		}
		
		/**
		 * 是否双摄像头
		 * **/
		public function get isDoubleCamera():Boolean
		{
			return videoInfo.isDoubleCamera;
		}
		
		/**
		 * 获取渲染器
		 * **/
		public function getRender():LiveVideoRender
		{
			return video.getRender();
		}
		
		/**
		 * 刷新
		 * **/
		public function onRefreshProperty():void
		{
			if(videoInfo.isDoubleCamera && AppConf.platform != NebulaPlatformType.BOARD)
			{
				return;	
			}
			
			videoInfo.onRefreshProperty();
			video.onRefreshProperty();
			
			if(videoInfo.recorderAudioKey == null && videoInfo.id == ComplexConf.userId && videoInfo.micphoneOpen)
				openAudioRecord();
			
			if(videoInfo.recorderVideoKey == null && videoInfo.id == ComplexConf.userId && videoInfo.cameraOpen)
				openVideoRecord();
			
		}
		
		/**
		 * 打开音频录制
		 * **/
		public function openAudioRecord():void
		{
			
			var timeStr:String = getDateStandard(new Date());
			
			var audioKey:String = id + "/" + timeStr + "-audio";
			
			video.openAudioRecord(audioKey);
		}
		
		/**
		 * 移除音频录制
		 * **/
		public function removeAudioRecord():void
		{
			video.removeAudioRecord();			
		}
		
		/**
		 * 打开视频录制
		 * **/
		public function openVideoRecord():void
		{
			
			var timeStr:String = getDateStandard(new Date());
			
			if(isDoubleCamera)
				timeStr += "-1"
			
			var videoKey:String = id + "/" + timeStr + "-video";
			
			video.openVideoRecord(videoKey);
			
		}
		
		/**
		 * 移除视频录制
		 * **/
		public function removeVideoRecord():void
		{
			video.removeVideoRecord();
		}
		
		/**
		 * 添加video渲染
		 * **/
		public function openVideoRender(videoKey:String,detail:String,time:Number):void
		{			
			videoInfo.setRendDetail(detail);
			
			video.openVideoRender(videoKey,time);

		}
		
		/**
		 * 移除video渲染
		 * **/
		public function removeVideoRender():void
		{
			video.removeVideoRender();
		}
		
		/**
		 * 添加音频渲染
		 * **/
		public function openAudioRender(audioKey:String,time:Number):void
		{
			video.openAudioRender(audioKey,time);
		}
		
		/**
		 * 移除音频渲染
		 * **/
		public function removeAudioRender():void
		{
			video.removeAudioRender();
		}
		
		/**
		 * 销毁资源/移除视频
		 * **/
		public function onDestroy():void
		{
			video.onDestroy();
			
			video = null;
			
			liveView = null;
			videoInfo = null;
			
		}
		
		/** 返回标准格式日期字符串（至秒）*/
		public static function getDateStandard(date:Date):String {
			
			var curYear:String = '' + date.fullYear;
			var curMonth:String = (date.month + 1) < 10 ? '0' + (date.month + 1) : '' + (date.month + 1);
			var curDay:String = date.date < 10 ? '0' + date.date : '' + date.date;
			var curHour:String = date.hours < 10 ? '0' + date.hours : '' + date.hours;
			var curMinute:String = date.minutes < 10 ? '0' + date.minutes : '' + date.minutes;
			var curSecond:String = date.seconds < 10 ? '0' + date.seconds : '' + date.seconds;
			return curYear + "/" + curMonth + "/" + curDay + "/" + curHour + "-" + curMinute + "-" + curSecond;
		}
		
	}
}




