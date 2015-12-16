package com.doer.modes.live.tools
{
	import com.doer.config.ComplexConf;

	public class LiveVideoInfo
	{
		/**
		 * 视频主键
		 * **/
		public var renderVideoKey:String = null;
		
		/**
		 * 音频主键
		 * **/
		public var renderAudioKey:String = null;
		
		/**
		 * 录制视频主键
		 * **/
		public var recorderVideoKey:String = null;
		
		/**
		 * 录制音频主键
		 * **/
		public var recorderAudioKey:String = null;
		
		/**
		 * 地址
		 * **/
		public var address:String = null;
		
		/**
		 * 标示
		 * **/
		public var id:String = null;
		
		/**
		 * 是否录制端
		 * **/
		public var isRecord:Boolean = false;
		
		/**
		 * 摄像头是否开启
		 * **/
		public var cameraOpen:Boolean = false;
		
		/**
		 * 麦克风是否开启
		 * **/
		public var micphoneOpen:Boolean = false;
		
		/**
		 * 使用的摄像头索引
		 * **/
		public var cameraIndex:int = 0;
		
		/**
		 * 使用的麦克风索引
		 * **/
		public var micphoneIndex:int = 0;
		
		/**
		 * 声音
		 * **/
		public var soundVolume:Number = 80;
		
		/**
		 * 麦克风音量
		 * **/
		public var micphoneVolume:Number = 80;
		
		/**
		 * 视频录制宽度
		 * **/
		public var recordWidth:Number = 0;
		
		/**
		 * 视频录制高度
		 * **/
		public var recordHeight:Number = 0;
		
		/**
		 * 渲染宽度
		 * **/
		public var rendWidth:Number = 0;
		
		/**
		 * 渲染高度
		 * **/
		public var rendHeight:Number = 0;
		
		/**
		 * 是否是第二个摄像头
		 * **/
		public var isDoubleCamera:Boolean = false;
		
		public function LiveVideoInfo(id:String,videoKey:String,audioKey:String,recordWidth:Number,recordHeight:Number,address:String,isRecord:Boolean,isDoubleCamera:Boolean)
		{
			this.renderVideoKey = videoKey;
			this.renderAudioKey = audioKey;
			this.address = address;
			this.id = id;
			this.isRecord = isRecord;
			this.isDoubleCamera = isDoubleCamera;
			this.recordWidth = recordWidth;
			this.recordHeight = recordHeight;
			this.rendWidth = recordWidth;
			this.rendHeight = recordHeight;
			
			onRefreshProperty();
		}
		
		/**
		 * 刷新设置参数
		 * **/
		public function onRefreshProperty():void
		{
			this.cameraIndex = isDoubleCamera ? ComplexConf.subCameraIndex : ComplexConf.mainCameraIndex;
			this.micphoneIndex = ComplexConf.micphoneIndex;
			this.micphoneVolume = ComplexConf.micphoneVolume;
			this.soundVolume = ComplexConf.soundVolume;

			if(ComplexConf.userId == id)
			{
				this.cameraOpen = isDoubleCamera ? ComplexConf.isSubCameraOn : ComplexConf.isMainCameraOn;
				this.micphoneOpen = ComplexConf.isMicphoneOn;
				
			}else
			{
				this.cameraOpen = false;
				this.micphoneOpen = false;
			}
		}
		
		/**
		 * 设置渲染分辨率
		 * **/
		public function setRendDetail(detail:String):void
		{
			var arr:Array = detail.split("x");
			
			this.rendWidth = Number(arr[0]);
			this.rendHeight = Number(arr[1]);
		}
		
	}
}