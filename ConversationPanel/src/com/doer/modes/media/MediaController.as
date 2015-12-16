package com.doer.modes.media
{
	import com.doer.common.Tools;
	import com.doer.config.AppConf;
	import com.doer.config.ComplexConf;
	import com.doer.config.ModeTypes;
	import com.doer.interfaces.ISProcessor;
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.modes.media.interfaces.IMediaCtr;
	import com.doer.modes.media.interfaces.IPlayer;
	import com.doer.modes.media.player.VodPlayer;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ClientComplexChangeScreen;
	import com.metaedu.client.messages.nebula.ClientComplexMediaCtrl;
	import com.metaedu.client.messages.nebula.ClientComplexMediaProvider;
	import com.metaedu.client.messages.nebula.NebulaCharacterType;
	import com.metaedu.client.messages.nebula.NebulaFileStatus;
	import com.metaedu.client.messages.nebula.NebulaFileUsingType;
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;
	import com.metaedu.client.messages.nebula.NebulaParticipantType;
	import com.metaedu.client.messages.nebula.NebulaScreenType;
	import com.metaedu.client.messages.nebula.ServerComplexAddFileInform;
	import com.metaedu.client.messages.nebula.ServerComplexAddFilePageInform;
	import com.metaedu.client.messages.nebula.ServerComplexChangeScreenInform;
	import com.metaedu.client.messages.nebula.ServerComplexEnterResp;
	import com.metaedu.client.messages.nebula.ServerComplexMediaCtrlInform;
	import com.metaedu.client.messages.nebula.ServerComplexMediaProviderInform;
	import com.metaedu.client.messages.nebula.ServerPassiveOutInform;
	import com.metaedu.client.messages.nebula.ServerSignInResp;
	import com.metaedu.client.messages.nebula.complex.MediaCtrlType;
	import com.metaedu.client.messages.nebula.complex.MultimediaContainer;
	import com.metaedu.client.messages.nebula.complex.MultimediaUnit;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import flash.media.Video;
	import flash.sampler.stopSampling;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.formats.Suffix;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	
	import spark.components.Group;
	
	import view.modes.media.MediaView;
	import view.modes.tools.media.MinMediaTool;
	
	public class MediaController extends AbstrackController 
	{
		/** 多媒体容器 */
		public var multimedias:MultimediaContainer = null;
		
		
		/**
		 * 是否第二个屏幕上的
		 * **/
		public var isSecondScreen:Boolean = false;
		
		/**
		 * 播放器
		 * **/
		public var player:VodPlayer = null;
		
		
		private var mediaTool:MinMediaTool = null;
		
		private var toolContainer:Group = null;
		
		/**
		 * 是否发起端
		 * **/
		public var isDispatcher:Boolean = true;
		
		
		public function MediaController(metaManager:MetaManager, modeId:int, container:Group=null,toolContainer:Group=null)
		{
			super(metaManager, modeId, container);

			player = new VodPlayer(this,600,400)
			this.toolContainer = toolContainer;
			
			invalidateCommands();
		}
		
		override public function reset():void
		{
			if(modeView != null)
				removeView();
			
			player.disponse();
		}
		
		/**
		 * 设置
		 * **/
		private function refreshPlayer():void
		{
			var active:String = isSecondScreen ? multimedias.activeMultimedia2 : multimedias.activeMultimedia;
			
			if(active != "")
			{
				var info:MultimediaUnit = getMediaInfoById(active);
			
				if(info.ctrlStatus == MediaCtrlType.PLAY)
				{
					player.readyMedia(AppConf.rtmpVodAddress,info.path,info.id,info.suffix,info.name,info.detail);
					
					player.seek(info.currentTime);
					
				}
				
//				var info:MultimediaUnit = getMediaInfoById(active);
//				
//				player.readyMedia(AppConf.rtmpVodAddress,info.path,info.id,info.suffix,info.name,info.detail);
//				
//				player.seek(info.currentTime);
//				
//				if(info.ctrlStatus == MediaCtrlType.PLAY)
//					player.resume();
//				else if(info.ctrlStatus == MediaCtrlType.PAUSE)
//					player.pause();
//				else
//					player.stop();
				
			}
			
		}
		
		private function invalidateCommands():void
		{
			registCommand(LocalCommandType.CMD_LOGIN_COMPLETE);
			registCommand(LocalCommandType.CMD_ACTIVITESCREEN_CHANGE);
			registCommand(LocalCommandType.CMD_SUBACTIVITESCREEN_CHANGE);
			registCommand(LocalCommandType.CMD_OPEN_FILE);
			registCommand(LocalCommandType.CMD_SCREEN_CLIP_STATUE);
		}
		
		override public function registView():IView
		{
			return new MediaView();
		}
		
		override public function onCommand(cmd:LocalCommand):void
		{
			if(cmd.command == LocalCommandType.CMD_LOGIN_COMPLETE)
			{
				//removeCommand(LocalCommandType.CMD_LOGIN_COMPLETE);
				
				onLoginInfo(cmd.data as ServerComplexEnterResp);
				
			}else if(cmd.command == LocalCommandType.CMD_ACTIVITESCREEN_CHANGE || cmd.command == LocalCommandType.CMD_SUBACTIVITESCREEN_CHANGE)
			{
				onChangeScreen();
			}else if(cmd.command == LocalCommandType.CMD_OPEN_FILE)
			{
				onOpenFile(cmd.data);
			}else if(cmd.command == LocalCommandType.CMD_SCREEN_CLIP_STATUE)
			{
				onClipScreen();
			}
		}
		
		private function addMediaTool():void
		{
			if(mediaTool == null && ComplexConf.participantType == NebulaParticipantType.CHARGE)
			{
				mediaTool = new MinMediaTool();
				
				mediaTool.controller = this;
				
				mediaTool.x = 20;
				
				if(isSecondScreen)
					mediaTool.x = toolContainer.width - mediaTool.width - 20;
				
				mediaTool.y = container.height - mediaTool.height - 20;
				
				toolContainer.addElement(mediaTool);
				
				mediaTool.invalidate();
				
				mediaTool.setParticipantTypePower(ComplexConf.participantType);
			}
			
			
		}
		
		private function removeMediaMinTool():void
		{
			if(mediaTool != null)
			{
				mediaTool.onDestroy();
				
				toolContainer.removeElement(mediaTool);
				
				mediaTool = null;
			}
			
		}
		
		private function onClipScreen():void
		{
			if(isSecondScreen && !ComplexConf.isClipScreen) //停止辅屏多媒体
			{
				stop();
				
				removeMediaMinTool();
			}
		}
		
		private function onChangeScreen():void
		{
			if(player.id == null) return;
			
			if(isSecondScreen)
			{
				if(ComplexConf.subActiveScreen != NebulaScreenType.MULTIMEDIA)
				{
					if( player.ctrType == MediaCtrlType.PLAY && !player.isVideo )
						addMediaTool();
					else
					{
						stop(player.ctrType != MediaCtrlType.STOP);
					}
					
				}else
				{
					removeMediaMinTool();
					
				}
			}else
			{
				if(ComplexConf.activeScreen != NebulaScreenType.MULTIMEDIA)
				{
					if( player.ctrType == MediaCtrlType.PLAY && !player.isVideo)
						addMediaTool();
					else
					{
						stop(player.ctrType != MediaCtrlType.STOP);
					}
					
				}else
				{
					removeMediaMinTool();
					
				}
			}
			
			
		}
		
		private function onLoginInfo(loginInfo:ServerComplexEnterResp):void
		{
			multimedias = loginInfo.multimedias;

			refreshPlayer();
			
			onChangeScreen();
			
		}
		
		private function onOpenFile(data:Object):void
		{
			if(data.isSubScreen == isSecondScreen && !data.isDoc)
			{
				var changeInfo:ClientComplexChangeScreen;
				
				var info:MultimediaUnit = getMediaInfoById(data.id);
				
				if(data.isSubScreen)
				{
					readyMedia(AppConf.rtmpVodAddress,info.path,info.id,info.suffix,info.name,info.detail);
					
					if(ComplexConf.subActiveScreen != NebulaScreenType.MULTIMEDIA)
					{
						changeInfo = new ClientComplexChangeScreen();
						changeInfo.screen = NebulaScreenType.MULTIMEDIA;
						changeInfo.index = 2;
						
						sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,changeInfo));
						
					}
				}else
				{
					readyMedia(AppConf.rtmpVodAddress,info.path,info.id,info.suffix,info.name,info.detail);
					
					if(ComplexConf.activeScreen != NebulaScreenType.MULTIMEDIA)
					{
						changeInfo = new ClientComplexChangeScreen();
						changeInfo.screen = NebulaScreenType.MULTIMEDIA;
						changeInfo.index = 1;
						
						sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,changeInfo));
						
					}
				}
			}
		}
		
		
		override public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
			if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_MEDIA_CTRL_INFORM)
			{
				onRcvMediaInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexMediaCtrlInform));
				
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_ADD_FILE_INFORM)
			{
				onRcvAddFile(JsonUtils.convertJsonToClass(refContent,ServerComplexAddFileInform))
				
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_ADD_FILEPAGE_INFORM)
			{
				onRcvAddFilePage(JsonUtils.convertJsonToClass(refContent,ServerComplexAddFilePageInform));
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_MEDIA_PROVIDER_INFORM)
			{
				onRcvProviderInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexMediaProviderInform));
			}
		}
		
		private function onRcvProviderInfo(info:ServerComplexMediaProviderInform):void
		{
			if(info.session == AppConf.session && info.platform == AppConf.platform)
			{
				isDispatcher = true;
			}else
			{
				isDispatcher = false;
			}
		}
		
		private function onRcvAddFile(fileInfo:ServerComplexAddFileInform):void
		{
			if(	fileInfo.usingType == NebulaFileUsingType.VIDEO ||  fileInfo.usingType == NebulaFileUsingType.AUDIO)
			{
				var mediaUint:MultimediaUnit = new MultimediaUnit();
				
				mediaUint.id = fileInfo.id;
				mediaUint.name = fileInfo.name;
				mediaUint.detail = fileInfo.detail;
				mediaUint.suffix = fileInfo.suffix;
				mediaUint.fileId = fileInfo.fileId;
				mediaUint.total = fileInfo.total;
				mediaUint.ctrlStatus = MediaCtrlType.PAUSE;
				
				multimedias.contents.push(mediaUint);
				
				
				var isContinue:Boolean = true;
				
				while(isContinue)
				{
					isContinue = false;
					
					for( var i:int = 0; i < releaseQueue.length; i ++)
					{
						if(releaseQueue[i].id == mediaUint.id)
						{
							mediaUint.status = NebulaFileStatus.PREPARED;
							mediaUint.path = releaseQueue[i].path;
							
							releaseQueue.splice(i,1);
							
							isContinue = true;
							break;
						}
					}
				}
				
			}
			

		}
		
		private var releaseQueue:Vector.<ServerComplexAddFilePageInform> = new Vector.<ServerComplexAddFilePageInform>();
		
		
		private function onRcvAddFilePage(info:ServerComplexAddFilePageInform):void
		{
			var isIn:Boolean = false;
			
			for each(var mediaUint:MultimediaUnit in multimedias.contents )
			{
				if(mediaUint.id == info.id)
				{
					mediaUint.status = NebulaFileStatus.PREPARED;
					mediaUint.path = info.path;
					isIn = true;
					break;
				}
			}	
			
			if(!isIn)
				releaseQueue.push(info);
			
		}
		
		private function onRcvMediaInfo(info:ServerComplexMediaCtrlInform):void
		{
			if((info.index == 2 && isSecondScreen) || (info.index == 1 && !isSecondScreen))
			{
				if(player.id != info.id)
				{
					var mediaInfo:MultimediaUnit = getMediaInfoById(info.id);
					
					if(info.ctrlType != MediaCtrlType.STOP)
					readyMedia(AppConf.rtmpVodAddress,mediaInfo.path,mediaInfo.id,mediaInfo.suffix,mediaInfo.name,mediaInfo.detail,false);
				}
				
				seek(info.time,false);
				
				if(ComplexConf.isChargeOnline)
				{
					if(info.ctrlType == MediaCtrlType.PAUSE)
						pause(false);
					else if(info.ctrlType == MediaCtrlType.PLAY)
						play(false);
					else if(info.ctrlType == MediaCtrlType.STOP)
					{
						stop(false);
						removeMediaMinTool();
					}
						
				}else
				{
					pause(false);
				}
				
				
			}
		}
		
		/**
		 * 添加到播放
		 * **/
		public function readyMedia(sevName:String, fileName:String, id:String, suffix:String, name:String,detail:String,isSend:Boolean = true):void
		{
			if(isSecondScreen)
				multimedias.activeMultimedia2 = id;
			else
				multimedias.activeMultimedia = id;
			
			player.onDestroy();

			player.readyMedia(sevName,fileName,id,suffix,name,detail);
			
			play(isSend);
		}
		
		/**
		 * 快进/快退
		 * **/
		public function seek(time:Number,isSend:Boolean = true):void
		{
			player.seek(time);
			
			if(ComplexConf.participantType == NebulaParticipantType.CHARGE && isSend)
			{
				sendPrivoderInfo();
				sendMediaInfo(player.id,player.time,player.ctrType);
			}
				
			
			
		}
		
		/**
		 * 播放
		 * **/
		public function play(isSend:Boolean = true):void
		{
			player.resume();
		
			if(ComplexConf.participantType == NebulaParticipantType.CHARGE && isSend)
			{
				sendPrivoderInfo();
				
				sendMediaInfo(player.id,player.time,player.ctrType);
			}
			
		}
		
		/**
		 * 暂停
		 * **/
		public function pause(isSend:Boolean = true):void
		{
			player.pause();	
			
			if(ComplexConf.participantType == NebulaParticipantType.CHARGE && isSend)
			{
				sendPrivoderInfo();
				sendMediaInfo(player.id,player.time,player.ctrType);
			}
			
			
		}
		
		/**
		 * 停止播放
		 * **/
		public function stop(isSend:Boolean = true):void
		{
			player.stop();	
			
			if(ComplexConf.participantType == NebulaParticipantType.CHARGE && player.id != null && isSend)
			{
				sendPrivoderInfo();
				
				sendMediaInfo(player.id,player.time,player.ctrType);
			}				
				
			
		}
		
		/**
		 * 设置最小化
		 * **/
		public function setSizeMin():void
		{
			var changeInfo:ClientComplexChangeScreen = new ClientComplexChangeScreen();
			changeInfo.screen = NebulaScreenType.BOARD;
			changeInfo.index = isSecondScreen ? 2 : 1;
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,changeInfo));
			
		}
		
		/***
		 * 设置最小化
		 * **/
		public function setSizeMax():void
		{
			var changeInfo:ClientComplexChangeScreen = new ClientComplexChangeScreen();
			changeInfo.screen = NebulaScreenType.MULTIMEDIA;
			changeInfo.index = isSecondScreen ? 2 : 1;
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,changeInfo));
		}
		
		/**
		 * 取消最小化模式
		 * **/
		public function cancelMinMode():void
		{
			stop();
			
			removeMediaMinTool();
		}
		
		/**
		 * 获取需要播放的多媒体信息
		 * **/
		public function getMediaInfoById(id:String):MultimediaUnit
		{
			for each(var mediaInfo:MultimediaUnit in multimedias.contents)
			{
				if(mediaInfo.id == id)
					return mediaInfo;
			}
			
			return null;
		}	
		
		/**
		 * 设置为控制端
		 * **/
		public function sendPrivoderInfo():void
		{
			var info:ClientComplexMediaProvider = new ClientComplexMediaProvider();
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,info));
			
			
		}
		
		/**
		 * 发送多媒体信息到服务端
		 * **/
		public function sendMediaInfo(id:String,time:Number,ctrType:int):void
		{
			
			if(isDispatcher)
			{
				var info:ClientComplexMediaCtrl = new ClientComplexMediaCtrl();
				
				info.index = isSecondScreen ? 2 : 1;
				info.ctrlType = ctrType;
				info.id = id;
				info.time = time;
				
				sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,info));
			}

		}
		
		
	}
}