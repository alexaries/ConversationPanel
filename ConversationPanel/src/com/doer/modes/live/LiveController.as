package com.doer.modes.live
{
	import com.doer.common.Tools;
	import com.doer.config.AppConf;
	import com.doer.config.ComplexConf;
	import com.doer.config.ModeTypes;
	import com.doer.interfaces.ISProcessor;
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.modes.live.process.LiveVideoManager;
	import com.doer.modes.live.tools.LiveVideoInfo;
	import com.doer.modes.live.video.LiveVideoRender;
	import com.doer.modes.studentlist.StudentListController;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ClientComplexAudioProviderAnswer;
	import com.metaedu.client.messages.nebula.ClientComplexAudioPublish;
	import com.metaedu.client.messages.nebula.ClientComplexAudioUnpublish;
	import com.metaedu.client.messages.nebula.ClientComplexLiveCtrl;
	import com.metaedu.client.messages.nebula.ClientComplexVideo2Publish;
	import com.metaedu.client.messages.nebula.ClientComplexVideo2Unpublish;
	import com.metaedu.client.messages.nebula.ClientComplexVideoProviderAnswer;
	import com.metaedu.client.messages.nebula.ClientComplexVideoPublish;
	import com.metaedu.client.messages.nebula.ClientComplexVideoUnpublish;
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;
	import com.metaedu.client.messages.nebula.ServerComplexAudioProviderAnswerInform;
	import com.metaedu.client.messages.nebula.ServerComplexAudioProviderAskInform;
	import com.metaedu.client.messages.nebula.ServerComplexAudioPublishInform;
	import com.metaedu.client.messages.nebula.ServerComplexAudioUnpublishInform;
	import com.metaedu.client.messages.nebula.ServerComplexEnterResp;
	import com.metaedu.client.messages.nebula.ServerComplexLiveCtrlInform;
	import com.metaedu.client.messages.nebula.ServerComplexOtherEnterInform;
	import com.metaedu.client.messages.nebula.ServerComplexOtherQuitInform;
	import com.metaedu.client.messages.nebula.ServerComplexTalkingStatusInform;
	import com.metaedu.client.messages.nebula.ServerComplexVideo2PublishInform;
	import com.metaedu.client.messages.nebula.ServerComplexVideo2UnpublishInform;
	import com.metaedu.client.messages.nebula.ServerComplexVideoProviderAnswerInform;
	import com.metaedu.client.messages.nebula.ServerComplexVideoProviderAskInform;
	import com.metaedu.client.messages.nebula.ServerComplexVideoPublishInform;
	import com.metaedu.client.messages.nebula.ServerComplexVideoUnpublishInform;
	import com.metaedu.client.messages.nebula.ServerPassiveOutInform;
	import com.metaedu.client.messages.nebula.ServerSignInResp;
	import com.metaedu.client.messages.nebula.complex.EnterInfo;
	import com.metaedu.client.messages.nebula.complex.KeyUserInfo;
	import com.metaedu.client.messages.nebula.complex.MyStatus;
	import com.metaedu.client.messages.nebula.complex.QuitInfo;
	import com.metaedu.client.messages.nebula.complex.TalkingStatus;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import flash.events.Event;
	import flash.net.Socket;
	import flash.utils.setTimeout;
	
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	import view.common.Alert;
	import view.modes.live.LiveView;
	
	public class LiveController extends AbstrackController 
	{
		private var _talkings:Vector.<TalkingStatus> = null;
		
		/** 用户各端状态 */
		public var devStatus:MyStatus = null;
		
		/**
		 * 音视频流程
		 * **/
		public var liveManager:LiveVideoManager = null;
		
		public function LiveController(metaManager:MetaManager, modeId:int, container:Group, liveView:LiveView)
		{
			this.modeView = liveView;
			this.modeView.controller = this;
			this.liveManager = new LiveVideoManager(this,modeView as LiveView);
			
			super(metaManager, modeId,container);
		
			invalidateCommands();
		}
		
		/**
		 * 获取当前正在展示的视频的信息
		 * **/
		public function getLiveVideoInfo():Vector.<LiveVideoInfo>
		{
			return liveManager.getLiveVideoInfo();
		}
		
		override public function reset():void
		{
			liveManager.removeAllProcess();
		}
		
		override public function onDestroy():void
		{
			(modeView as LiveView).onDestroy();
			
			liveManager.removeAllProcess();
			liveManager = null;
		}
		
		/**
		 * 发言状态
		 * **/
		public function get talkings():Vector.<TalkingStatus>
		{
			_talkings = (metaManager.getControllerById(ModeTypes.MODE_STUDENTLIST_ID) as StudentListController).talkings;
			
			return _talkings;
		}

		/**
		 * @private
		 */
		public function set talkings(value:Vector.<TalkingStatus>):void
		{
			_talkings = value;
		}

		private function invalidateCommands():void
		{
			registCommand(LocalCommandType.CMD_LOGIN_COMPLETE);	
			registCommand(LocalCommandType.CMD_SETTER_CHANGE);
			registCommand(LocalCommandType.CMD_VIDEO1_CHANGE);
			registCommand(LocalCommandType.CMD_VIDEO2_CHANGE);
			registCommand(LocalCommandType.CMD_AUDIO_CHANGE);
			
		}
		
		override public function onCommand(cmd:LocalCommand):void
		{
			if(cmd.command == LocalCommandType.CMD_LOGIN_COMPLETE)
			{
				//removeCommand(LocalCommandType.CMD_LOGIN_COMPLETE);
				
				onLoginInfo(cmd.data as ServerComplexEnterResp);
				
			}else if(cmd.command == LocalCommandType.CMD_SETTER_CHANGE)
			{
				onRefreshValue();
			}else if(cmd.command == LocalCommandType.CMD_VIDEO1_CHANGE)
			{
				onVideo1Change();
			}else if(cmd.command == LocalCommandType.CMD_VIDEO2_CHANGE)
			{
				onVideo2Change();
				
			}else if(cmd.command == LocalCommandType.CMD_AUDIO_CHANGE)
			{
				onAudioChange();
			}
		}
	
		/**
		 * 打开/关闭第一视频
		 * **/
		private function onVideo1Change():void
		{
			if(ComplexConf.isMainCameraOn)
			{
				
				Tools.alert("将此设备设置为视频提供端？",function():void{
					
					//打开视频
					liveManager.openVideoRecorder(ComplexConf.userId);
					//发送设置视频提供段消息
					sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,new ClientComplexVideoProviderAnswer()));
					
					
				},function():void{
					
					ComplexConf.isMainCameraOn = false;
					
				});
			}else
			{
				sendRemoveVideo();
				
				liveManager.onRemoveVideoRecorder(ComplexConf.userId);
			}
			
		}
		
		/**
		 * 打开/关闭第二视频
		 * **/
		private function onVideo2Change():void
		{
			if(ComplexConf.isSubCameraOn)
				liveManager.openVideoRecorder(ComplexConf.userId,true);
			else
			{
				
				sendRemoveVideo2();
				
				liveManager.onRemoveVideoRecorder(ComplexConf.userId,true);
			}
				
		}
		
		/**
		 * 打开/关闭音频
		 * **/
		private function onAudioChange():void
		{
			if(ComplexConf.isMicphoneOn)
			{
				Tools.alert("将此设备设置为音频提供端？",function():void{
					
					//打开视频
					liveManager.openAudioRecorder(ComplexConf.userId);
					//发送设置音频提供端消息
					sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,new ClientComplexAudioProviderAnswer()));
					
				},function():void{
					
					ComplexConf.isMicphoneOn = false;
					
				});
			}else
			{
				sendRemoveAudio();
				
				liveManager.onRemoveAudioRecorder(ComplexConf.userId);
			}
			
		}
		
		/**
		 * 刷新音视频设置参数
		 * **/
		private function onRefreshValue():void
		{
			liveManager.onRefreshProperty();
		}
		
		private function onLoginInfo(loginInfo:ServerComplexEnterResp):void
		{
			this.devStatus = loginInfo.status;
			
			this.modeView.invalidate();
			this.liveManager.invalidate();
		
			sendCommand(new LocalCommand(LocalCommandType.CMD_LIVE_INVALIDATED,loginInfo));
		}
		
		/**
		 * 发送打开音频录制消息到服务端
		 * **/
		public function sendOpenAudio(audioKey:String,time:Number):void
		{
			var audioMsg:ClientComplexAudioPublish = new ClientComplexAudioPublish();
			
			audioMsg.url = audioKey;
			audioMsg.time = time.toString();
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,audioMsg)); //发送消息到服务端
		}
		
		/**
		 * 发送打开录制消息到服务端
		 * **/
		public function sendOpenVideo(videoKey:String,time:Number,isDoubleCamera:Boolean):void
		{
			if(!isDoubleCamera)
			{
				var videoMsg:ClientComplexVideoPublish = new ClientComplexVideoPublish();
				videoMsg.url = videoKey;
				videoMsg.time = time.toString();
				videoMsg.detail = ComplexConf.videoDetail1;
				
				sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,videoMsg));
			}else
			{
				var msg:ClientComplexVideo2Publish = new ClientComplexVideo2Publish();
				msg.time = time.toString();
				msg.url = videoKey;
				msg.detail = ComplexConf.videoDetail2;
				
				sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,msg));
				
			}
			
		}
		
		/**
		 * 发送移除视频消息
		 * **/
		public function sendRemoveVideo():void
		{
			var videoMsg:ClientComplexVideoUnpublish = new ClientComplexVideoUnpublish();
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,videoMsg));
			
		}
		
		/**
		 * 移除视频2
		 * **/
		public function sendRemoveVideo2():void
		{
			var msg:ClientComplexVideo2Unpublish = new ClientComplexVideo2Unpublish();
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,msg));
			
		}
		
		/**
		 * 发送移除音频消息
		 * **/
		public function sendRemoveAudio():void
		{
			var audioMsg:ClientComplexAudioUnpublish = new ClientComplexAudioUnpublish();
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,audioMsg));
		}
		
		override public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
		
			switch(refBusinessType)
			{
				case NebulaMessageBusinessType.SERVER_COMPLEX_AUDIO_PUBLISH_INFORM: //收到被人发布音频流
				{
					onRcvAudioPublishInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexAudioPublishInform));
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_VIDEO_PUBLISH_INFORM:
				{
					
					onRcvVideoPublishInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexVideoPublishInform))
					
					break;
				}
				
				case NebulaMessageBusinessType.SERVER_COMPLEX_TALKING_STATUS_INFORM:
				{

					onRcvComplexTalking(JsonUtils.convertJsonToClass(refContent,ServerComplexTalkingStatusInform));
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_AUDIO_UNPUBLISH_INFORM:
				{
					onRcvCloseAudio(JsonUtils.convertJsonToClass(refContent,ServerComplexAudioUnpublishInform));
					
					break;
				}
				case NebulaMessageBusinessType.SERVER_COMPLEX_VIDEO_UNPUBLISH_INFORM:
				{
					
					onRcvCloseVideo(JsonUtils.convertJsonToClass(refContent,ServerComplexVideoUnpublishInform));
					
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_OTHER_QUIT_INFORM:
				{
					onRcvOtherLogout(JsonUtils.convertJsonToClass(refContent,ServerComplexOtherQuitInform));
					
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_OTHER_ENTER_INFORM:
				{
					onRcvOtherLogin(JsonUtils.convertJsonToClass(refContent,ServerComplexOtherEnterInform));
					
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_VIDEO2_PUBLISH_INFORM:
				{
					onRcvVideo2Info(JsonUtils.convertJsonToClass(refContent,ServerComplexVideo2PublishInform));
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_VIDEO2_UNPUBLISH_INFORM:
				{
					onRcvVideo2Close(JsonUtils.convertJsonToClass(refContent,ServerComplexVideo2UnpublishInform));
					break;
				}
				
				case NebulaMessageBusinessType.SERVER_COMPLEX_AUDIO_PROVIDER_ASK_INFORM://收到被要求设置音频提供端
				{
					onRcvAudioProviderAsk(JsonUtils.convertJsonToClass(refContent,ServerComplexAudioProviderAskInform));
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_AUDIO_PROVIDER_ANSWER_INFORM: //收到其他端要求设置音频消息
				{
					onRcvAudioProviderInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexAudioProviderAnswerInform));
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_VIDEO_PROVIDER_ANSWER_INFORM://收到其他的设置视频提供端
				{
					
					onRcvVideoProvideoInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexVideoProviderAnswerInform));
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_VIDEO_PROVIDER_ASK_INFORM://收到被要求提供视频
				{
					onRcvVideoProviderAsk(JsonUtils.convertJsonToClass(refContent,ServerComplexVideoProviderAskInform));
					break;
				}
					
				default:
				{
					break;
				}
			}
			
			
		}
	
		/**
		 * 收到被要求设置为音频提供端
		 * **/
		private function onRcvAudioProviderAsk(info:ServerComplexAudioProviderAskInform):void
		{
			
		}
		
		/**
		 * 收到设置音频提供端消息
		 * **/
		private function onRcvAudioProviderInfo(info:ServerComplexAudioProviderAnswerInform):void
		{
			if(AppConf.platform != info.platform)
			{
				ComplexConf.isMicphoneOn = false;
				liveManager.onRemoveAudioRecorder(ComplexConf.userId);
			}
				
		}
		
		
		/**
		 * 收到被要求设置为视频提供端
		 * **/
		private function onRcvVideoProviderAsk(info:ServerComplexVideoProviderAskInform):void
		{
			
		}
		
		/**
		 * 收到设置视频提供端消息
		 * **/
		private function onRcvVideoProvideoInfo(info:ServerComplexVideoProviderAnswerInform):void
		{
			if(AppConf.platform != info.platform)
			{
				ComplexConf.isMainCameraOn = false;
				liveManager.onRemoveVideoRecorder(ComplexConf.userId);
			}
				
		}
		
		/**
		 * 收到辅助摄像头发布视频
		 * **/
		private function onRcvVideo2Info(info:ServerComplexVideo2PublishInform):void
		{
			liveManager.onRcvOpenVideo(info.id,info.url,info.detail,Number(info.time),true);
		}
		
		/**
		 * 关闭第二视频
		 * **/
		private function onRcvVideo2Close(info:ServerComplexVideo2UnpublishInform):void
		{
			if(info.id != ComplexConf.userId)
				liveManager.onRemoveVideoRender(info.id,true);
		}
		
		
		/**
		 * 收到别人登录消息
		 * **/
		private function onRcvOtherLogin(info:ServerComplexOtherEnterInform):void
		{
			for each(var enterInfo:EnterInfo in info.infos)
			{
				if(enterInfo.id == ComplexConf.chargInfo.id)
				{
					(modeView as LiveView).video1.nameText = enterInfo.surname + enterInfo.name;
				}
			}
		}
		
		/**
		 * 收到别人登出消息
		 * **/
		private function onRcvOtherLogout(info:ServerComplexOtherQuitInform):void
		{
			for each(var quitInfo:QuitInfo in info.infos)
			{
				if(quitInfo.id == ComplexConf.chargInfo.id)
				{
					liveManager.onRemoveAudioRender(quitInfo.id);
					liveManager.onRemoveVideoRender(quitInfo.id);
					liveManager.onRemoveVideoRender(quitInfo.id,true);
				}else
					liveManager.removeVideoProcess(quitInfo.id);
			}
			
			
		}
		
		/**
		 * 收到关闭音频消息
		 * **/
		private function onRcvCloseAudio(audioInfo:ServerComplexAudioUnpublishInform):void
		{
			if(audioInfo.id != ComplexConf.userId)
				liveManager.onRemoveAudioRender(audioInfo.id);
		}
		
		/**
		 * 收到关闭视频消息
		 * **/
		private function onRcvCloseVideo(videoInfo:ServerComplexVideoUnpublishInform):void
		{
			if(videoInfo.id != ComplexConf.userId)
				liveManager.onRemoveVideoRender(videoInfo.id);
		}
		
		/**
		 * 收到被授权发言通知
		 * **/
		private function onRcvComplexTalking(complex:ServerComplexTalkingStatusInform):void
		{
			if(complex.id == ComplexConf.userId)
				liveManager.onComplexTalk(complex.id,complex.enable);
			else
			{
				if(complex.enable)
					liveManager.addVideoProcess(complex.id);
				else
					liveManager.removeVideoProcess(complex.id);
			}
				
			sendCommand(new LocalCommand(LocalCommandType.CMD_RENDER_CHANGE));
		}
		
		/**
		 * 收到别人发布音频消息
		 * **/
		private function onRcvAudioPublishInfo(audioInfo:ServerComplexAudioPublishInform):void
		{
			if(audioInfo.id != ComplexConf.userId)
				liveManager.onRcvOpenAudio(audioInfo.id,audioInfo.url,Number(audioInfo.time));
		}
		
		/**
		 * 收到别人发布视频消息
		 * **/
		private function onRcvVideoPublishInfo(videoInfo:ServerComplexVideoPublishInform):void
		{
			if(videoInfo.id != ComplexConf.userId)
				liveManager.onRcvOpenVideo(videoInfo.id,videoInfo.url,videoInfo.detail,Number(videoInfo.time));
		}
		
	}
}