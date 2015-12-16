package com.doer.modes.media.player
{
	import com.doer.modes.media.MediaController;
	import com.doer.modes.media.interfaces.IMediaCtr;
	import com.doer.modes.media.interfaces.IPlayer;
	import com.doer.modes.skydrive.files.UsedFileInfo;
	import com.metaedu.client.messages.nebula.complex.MediaCtrlType;
	import com.strong.rtmp.RtmpPlayerEvent;
	import com.strong.rtmp.RtmpProtocolType;
	import com.strong.rtmp.RtmpVodPlayer;
	
	import flash.display.Sprite;
	
	import view.modes.share.LiveShareTool;
	
	public class VodPlayer extends Sprite implements IPlayer
	{
		/**
		 * 服务器名
		 * **/
		public var sevName:String = null;
		
		/**
		 * 文件名
		 * **/
		public var fileName:String = null;
		
		/**
		 * 文件标示
		 * **/
		public var id:String = null;
		
		/** 文件标志
		 * **/
		public var suffix:String = null;
		
		/**
		 * 分辨率描述
		 * **/
		public var detail:String = null;
		
		/**
		 * 是否是video
		 * **/
		[Bindable]
		public var isVideo:Boolean = false;
		
		/**
		 * 多媒体名称
		 * **/
		[Bindable]
		public var mediaName:String = null;
		
		[Bindable]
		public var renderMode:String = LiveShareTool.fill_height;
		
		/**
		 * rtmp点播播放器
		 * **/
		private var video:RtmpVodPlayer = null;
		
		/**
		 * 控制器
		 * **/
		private var videoController:IMediaCtr = null;
		
		/**
		 * 多媒体控制器
		 * **/
		private var controller:MediaController = null;
		
		private var videoWidth:Number = 0;
		
		private var videoHeight:Number = 0;
		
		private var _ctrType:int = MediaCtrlType.PLAY;
		
		private var _time:Number = 0;
		
		private var _duration:Number = 0;
		
		public function VodPlayer(controller:MediaController,width:Number,height:Number)
		{
			this.videoWidth = width;
			this.videoHeight = height;
			
			this.controller = controller;
		}
		
		[Bindable]
		public function get ctrType():int
		{
			return _ctrType;
		}

		public function set ctrType(value:int):void
		{
			_ctrType = value;
		}

		/**
		 * 设置当前高宽
		 * **/
		public function setSize(width:Number, height:Number):void
		{
			this.videoWidth = width;
			this.videoHeight = height;
			
			setRenderMode(this.renderMode);
		}
		
		/***
		 * 设置渲染模式
		 * **/
		public function setRenderMode(renderMode:String):void
		{
			this.renderMode = renderMode;
			
			if(detail != null)
			{
				var arr:Array = detail.split("x");
				
				var w:Number = Number(arr[0]);
				var h:Number = Number(arr[1]);
				
				var sX:Number = 1;
				var sY:Number = 1;
				
				if(renderMode == LiveShareTool.fill_width)
				{
					sY = sX = videoWidth / w;
				}else if(renderMode == LiveShareTool.fill_height)
				{
					sX = sY = videoHeight / h;
				}else if(renderMode == LiveShareTool.fill_screen)
				{
					sX = videoWidth / w;
					sY = videoHeight / h;
					
				}
				
				if(video != null)
				{
					video.width = w * sX;
					video.height = h * sY;
					
				}
				
				if(this.parent != null)
				{
					this.x = this.parent.width / 2 - this.width / 2;
					this.y = this.parent.height / 2 - this.height / 2;
				}
			}

		}
		
		public function set time(value:Number):void
		{
			_time = value;
		}
		
		public function get time():Number
		{
			return _time;
		}
		
		public function set duration(value:Number):void
		{
			_duration = value;
		}
		
		public function get duration():Number
		{
			return _duration;
		}
	
		public function readyMedia(sevName:String, fileName:String, id:String, suffix:String, name:String,detail:String):void
		{
			this.sevName = sevName;
			this.fileName = fileName;
			this.id = id;
			this.suffix = suffix;
			this.mediaName = name;
			this.detail = detail;
			this.isVideo = UsedFileInfo.isVideo(suffix);
			
			this.time = 0;
			this.duration = 0;
			this.ctrType = MediaCtrlType.PLAY;
			
			video = new RtmpVodPlayer(this.videoWidth,this.videoHeight);
			video.setProtocol(RtmpProtocolType.AUTO,1935,80);
			addChild(video);
			
			setSize(this.videoWidth,this.videoHeight);
			
			video.addEventListener(RtmpPlayerEvent.TOTAL,onPlayerInfo);
			video.addEventListener(RtmpPlayerEvent.TIME,onPlayerInfo);
			video.addEventListener(RtmpPlayerEvent.PAUSE,onPlayerInfo);
			video.addEventListener(RtmpPlayerEvent.PLAY,onPlayerInfo);
			video.addEventListener(RtmpPlayerEvent.STOP,onPlayerInfo);
			video.addEventListener(RtmpPlayerEvent.VOLUME,onPlayerInfo);
			video.addEventListener(RtmpPlayerEvent.STEP,onPlayerInfo);
			
			
			var path:String = fileName.substr(0,fileName.lastIndexOf("."));
			
			path = (isVideo ? "flv" : "mp3") + ":" + path;
			
			video.open(sevName,path);
		}
		
		private var stoTime:Number = -1;
		
		
		/**
		 * 播放器事件
		 * **/
		private function onPlayerInfo(e:RtmpPlayerEvent):void
		{
			if(e.type == RtmpPlayerEvent.TIME)
			{
				this.time = Number(e.info);
				
				if(videoController != null && ctrType == MediaCtrlType.PLAY)
					videoController.onMediaTime(this.time,this.duration);
				
				if(stoTime == -1)
					stoTime = time;
				
				if(Math.abs(time - stoTime) >= 5)
				{
					controller.sendMediaInfo(id,time,ctrType);
					
					stoTime = time;
				}
				
				
			}else if(e.type == RtmpPlayerEvent.TOTAL)
			{
				this.duration = Number(e.info);
				
				if(videoController != null )
					videoController.onMediaTime(this.time,this.duration);
				
			}else if(e.type == RtmpPlayerEvent.STOP)
			{
				this.ctrType = MediaCtrlType.STOP;
				
				this.time = 0;
				
				if(videoController != null )
					videoController.onComplete();
			}
		}
		
		
		public function setController(videoController:IMediaCtr):void
		{
			this.videoController = videoController;
		}
		
		public function resume():void
		{
			if(ctrType == MediaCtrlType.STOP && id != null)
			{
				readyMedia(sevName,fileName,id,suffix,mediaName,detail);
				
				seek(time);
			}
			
			ctrType = MediaCtrlType.PLAY;
			
			if(video != null)
			video.play();
		}
		
		public function pause():void
		{
			ctrType = MediaCtrlType.PAUSE;
			
			if(video != null)
			video.pause();
		}
		
		public function stop():void
		{
			ctrType = MediaCtrlType.STOP;
			
			onDestroy();
		}
		
		public function seek(time:Number):void
		{
			this.time = time;
			
			if(video != null)
			video.stepDirect(time);

		}
		
		public function disponse():void
		{
			if(video != null)
			{
				ctrType = MediaCtrlType.STOP;
				
				video.stop();
				
				video.removeEventListener(RtmpPlayerEvent.TOTAL,onPlayerInfo);
				video.removeEventListener(RtmpPlayerEvent.TIME,onPlayerInfo);
				video.removeEventListener(RtmpPlayerEvent.PAUSE,onPlayerInfo);
				video.removeEventListener(RtmpPlayerEvent.PLAY,onPlayerInfo);
				video.removeEventListener(RtmpPlayerEvent.STOP,onPlayerInfo);
				video.removeEventListener(RtmpPlayerEvent.VOLUME,onPlayerInfo);
				video.removeEventListener(RtmpPlayerEvent.STEP,onPlayerInfo);
				
				removeChild(video);
				
				video = null;
			}
			
			this.sevName = null;
			this.fileName = null;
			this.id = null;
			this.suffix = null;
			this.mediaName = null;
			this.detail = null;
			this.isVideo = false;
			
			this.time = 0;
			this.duration = 0;
			this.ctrType = MediaCtrlType.PLAY;
		}
		
		public function onDestroy():void
		{
			if(video != null)
			{
				ctrType = MediaCtrlType.STOP;
				
				video.stop();
				
				video.removeEventListener(RtmpPlayerEvent.TOTAL,onPlayerInfo);
				video.removeEventListener(RtmpPlayerEvent.TIME,onPlayerInfo);
				video.removeEventListener(RtmpPlayerEvent.PAUSE,onPlayerInfo);
				video.removeEventListener(RtmpPlayerEvent.PLAY,onPlayerInfo);
				video.removeEventListener(RtmpPlayerEvent.STOP,onPlayerInfo);
				video.removeEventListener(RtmpPlayerEvent.VOLUME,onPlayerInfo);
				video.removeEventListener(RtmpPlayerEvent.STEP,onPlayerInfo);
				
				removeChild(video);
				
				video = null;
			}
		}
		
	}
}