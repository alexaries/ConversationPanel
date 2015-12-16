package com.doer.modes.live.process
{
	import com.doer.common.Tools;
	import com.doer.config.AppConf;
	import com.doer.config.ComplexConf;
	import com.doer.modes.live.LiveController;
	import com.doer.modes.live.tools.LiveVideoInfo;
	import com.doer.modes.live.video.LiveVideoRender;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ClientComplexAudioProviderAnswer;
	import com.metaedu.client.messages.nebula.ClientComplexVideoProviderAnswer;
	import com.metaedu.client.messages.nebula.NebulaParticipantType;
	import com.metaedu.client.messages.nebula.NebulaPlatformType;
	import com.metaedu.client.messages.nebula.complex.KeyUserInfo;
	import com.metaedu.client.messages.nebula.complex.TalkingStatus;
	import com.strong.rtmp.RtmpSeparateRender;
	
	import flash.media.Camera;
	import flash.media.Video;
	
	import view.modes.live.LiveView;

	public class LiveVideoManager
	{

		/**
		 * 控制器
		 * **/
		private var controller:LiveController = null;
		
		/**
		 * view
		 * **/
		private var liveView:LiveView = null;
		
		/**
		 * 视频组
		 * **/
		private var liveVideoProcesses:Vector.<LiveVideoProcess> = null;
		
		/**
		 * 直播流程
		 * **/
		public function LiveVideoManager(controller:LiveController,liveView:LiveView)
		{
			this.controller = controller;
			this.liveView = liveView;
			
			this.liveVideoProcesses = new Vector.<LiveVideoProcess>();
			
			invalidateCamerIndex();
		}
		
		private function invalidateCamerIndex():void
		{
			if(ComplexConf.mainCameraIndex == -1)
			{
				for(var i:int = 0; i < Camera.names.length; i ++)
				{
					if(Camera.names[i] != AppConf.vituralCameraName)
					{
						ComplexConf.mainCameraIndex = i;
						break;
					}
						
				}
			}
			
			if(ComplexConf.subActiveScreen == -1)
			{
				for(i = 0; i < Camera.names.length; i ++)
				{
					if(Camera.names[i] != AppConf.vituralCameraName && i != ComplexConf.mainCameraIndex)
					{
						ComplexConf.subCameraIndex = i;
						break;
					}
					
				}
			}
			
			if(ComplexConf.subCameraIndex == -1)
				ComplexConf.subCameraIndex = ComplexConf.mainCameraIndex;
			
		}
		
		/**
		 * 初始化
		 * **/
		public function invalidate():void
		{
			var talkings:Vector.<TalkingStatus> = controller.talkings;
			
			addVideoProcess(ComplexConf.chargInfo.id);
			
			addVideoProcess(ComplexConf.chargInfo.id,true);
			
			if(ComplexConf.participantType == NebulaParticipantType.CHARGE)
			{
				openAlertRecord("是否打开音视频？",ComplexConf.userId);
			}
			
			var talks:Vector.<TalkingStatus> = controller.talkings;
			
			for(var i:int = 0; i < talks.length; i ++)
			{
				if(ComplexConf.chargInfo.id != talkings[i].id)
				{
					addVideoProcess(talkings[i].id);
					
				}
			}
			
			
		}
		
		/**
		 * 打开弹框
		 * **/
		private function openAlertRecord(text:String,userId:String):void
		{
			Tools.alert(text,function():void{
				
				if(ComplexConf.isDoubleCamera && ComplexConf.participantType == NebulaParticipantType.CHARGE)
				{
					openAudioRecorder(userId);
					openVideoRecorder(userId);
					
					if(ComplexConf.isDoubleCamera && AppConf.platform == NebulaPlatformType.BOARD)
					{
						ComplexConf.isSubCameraOn = true;
						openVideoRecorder(userId,true); //打开第二摄像头
					}
						
				}else
				{
					openAudioRecorder(userId);
					openVideoRecorder(userId);
				}
				
				//发送设置音频提供端消息
				controller.sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,new ClientComplexAudioProviderAnswer()));
				
				//发送设置视频提供段消息
				controller.sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,new ClientComplexVideoProviderAnswer()));
				
				ComplexConf.isMainCameraOn = true;
				ComplexConf.isMicphoneOn = true;
				
			},function():void{
				
				ComplexConf.isMainCameraOn = false;
				ComplexConf.isSubCameraOn = false;
				ComplexConf.isMicphoneOn = false;
				
			});
		}
		
		/**
		 * 添加一个视频
		 * **/
		public function addVideoProcess(userId:String,isDoubleCamera:Boolean = false):void
		{
			var video:LiveVideoProcess = new LiveVideoProcess(liveView,userId,isDoubleCamera);
			
			liveVideoProcesses.push(video);
		
		}
		
		/**
		 * 移除一个录制流程
		 * **/
		public function removeVideoProcess(userId:String,isDoubleCamra:Boolean = false):void
		{
			for(var i:int = 0; i < liveVideoProcesses.length; i ++)
			{
				if(liveVideoProcesses[i].id == userId && isDoubleCamra)
				{
					liveVideoProcesses[i].onDestroy();
					liveVideoProcesses.splice(i,1);
					break;
				}
			}
		}
		
		/**
		 * 打开指定流程的音频录制
		 * **/
		public function openAudioRecorder(userId:String):void
		{
			for(var i:int = 0; i < liveVideoProcesses.length; i ++)
			{
				if(liveVideoProcesses[i].id == userId)
				{
					liveVideoProcesses[i].openAudioRecord();
					break;
				}
			}
		}
		
		/**
		 * 移除指定流程的音频录制
		 * **/
		public function onRemoveAudioRecorder(userId:String):void
		{
			for(var i:int = 0; i < liveVideoProcesses.length; i ++)
			{
				if(liveVideoProcesses[i].id == userId)
				{
					liveVideoProcesses[i].removeAudioRecord();
					break;
				}
			}
		}
		
		/**
		 * 打开指定流程的视频录制
		 * **/
		public function openVideoRecorder(userId:String,isDoubleCamera:Boolean = false):void
		{
			for(var i:int = 0; i < liveVideoProcesses.length; i ++)
			{
				if(liveVideoProcesses[i].id == userId && liveVideoProcesses[i].isDoubleCamera == isDoubleCamera)
				{
					liveVideoProcesses[i].openVideoRecord();
					break;
				}
			}
			
			liveView.reLocalVideos();
			
		}
		
		/**
		 * 移除指定流程的视频录制
		 * **/
		public function onRemoveVideoRecorder(userId:String,isDoubleCamera:Boolean = false):void
		{
			for(var i:int = 0; i < liveVideoProcesses.length; i ++)
			{
				if(liveVideoProcesses[i].id == userId && liveVideoProcesses[i].isDoubleCamera == isDoubleCamera)
				{
					liveVideoProcesses[i].removeVideoRecord();
					break;
				}
			}
			
			liveView.reLocalVideos();
			
		}
		
		/**
		 * 收到服务端打开一个音频流
		 * **/
		public function onRcvOpenAudio(userId:String,audioKey:String,time:Number):void
		{
			for(var i:int = 0; i < liveVideoProcesses.length; i ++)
			{
				if(liveVideoProcesses[i].id == userId)
				{
					liveVideoProcesses[i].openAudioRender(audioKey,time);
					break;
				}
			}
			
		}
		
		/**
		 * 收到服务端打开音频流
		 * **/
		public function onRcvOpenVideo(userId:String,videoKey:String,detail:String,time:Number,isDoubleCamera:Boolean = false):void
		{
			
			for(var i:int = 0; i < liveVideoProcesses.length; i ++)
			{
				if(liveVideoProcesses[i].id == userId && liveVideoProcesses[i].isDoubleCamera == isDoubleCamera)
				{
					liveVideoProcesses[i].openVideoRender(videoKey,detail,time);
					break;
				}
			}
			
			liveView.reLocalVideos();
		}
	
		/**
		 * 关闭音频
		 * **/
		public function onRemoveAudioRender(userId:String):void
		{
		
			for(var i:int = 0; i < liveVideoProcesses.length; i ++)
			{
				if(liveVideoProcesses[i].id == userId)
				{
					liveVideoProcesses[i].removeAudioRender();
					break;
				}
			}
			
			
		}
		
		/**
		 * 关闭视频
		 * **/
		public function onRemoveVideoRender(userId:String,isDoubleCamera:Boolean = false):void
		{
			for(var i:int = 0; i < liveVideoProcesses.length; i ++)
			{
				if(liveVideoProcesses[i].id == userId && liveVideoProcesses[i].isDoubleCamera == isDoubleCamera)
				{
					liveVideoProcesses[i].removeVideoRender();
					break;
				}
			}
			
			liveView.reLocalVideos();
			
		}
	
		/**
		 * 被授权 / 取消授权
		 * **/
		public function onComplexTalk(userId:String,enable:Boolean):void
		{
		
			if(enable)
			{
				addVideoProcess(userId);
				
				openAlertRecord("是否打开音视频？",userId);
				
			}else
			{
				Tools.alert("已被取消授权！");
				
				removeVideoProcess(userId);
			}
		}
		
		/**
		 * 移除所有process 
		 * **/
		public function removeAllProcess():void
		{
			while(liveVideoProcesses.length != 0)
			{
				var process:LiveVideoProcess = liveVideoProcesses.splice(0,1)[0];
				
				process.onDestroy();
				
			}
			
			liveVideoProcesses = new Vector.<LiveVideoProcess>();
			
		}
		
		/**
		 * 设置刷新
		 * **/
		public function onRefreshProperty():void
		{
			for(var i:int = 0; i < liveVideoProcesses.length; i ++)
			{
				if(!liveVideoProcesses[i].isDoubleCamera && liveVideoProcesses[i].id == ComplexConf.userId)
				{
					liveVideoProcesses[i].removeAudioRender();
					liveVideoProcesses[i].removeVideoRender();
				}
					
				liveVideoProcesses[i].onRefreshProperty();
			}
		}
		
		/**
		 * 获取当前正在显示的视频
		 * **/
		public function getLiveVideoInfo():Vector.<LiveVideoInfo>
		{
			var infos:Vector.<LiveVideoInfo> = new Vector.<LiveVideoInfo>();
			
			for(var i:int = 0; i < liveVideoProcesses.length; i ++)
			{
				infos.push(liveVideoProcesses[i].videoInfo);
			}
			
			return infos;
			
		}
		
		/**
		 * 获取指定render
		 * **/
		public function getRender(id:String,isDoubleCamera:Boolean):LiveVideoRender
		{
			for(var i:int = 0; i < liveVideoProcesses.length; i ++)
			{
				if(liveVideoProcesses[i].id == id && liveVideoProcesses[i].videoInfo.isDoubleCamera == isDoubleCamera)
				{
					return liveVideoProcesses[i].getRender();
				}
			}
			
			return null;
		}
		
	}
}