package com.doer.manager
{
	import com.doer.config.AppConf;
	import com.doer.config.ComplexConf;
	import com.doer.config.ModeTypes;
	import com.doer.interfaces.IController;
	import com.doer.interfaces.ISProcessor;
	import com.doer.modes.ModeController;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.modes.blackbord.BlackbordController;
	import com.doer.modes.blackbord.SubBlackBordController;
	import com.doer.modes.chat.ChatController;
	import com.doer.modes.courseware.CoursewareController;
	import com.doer.modes.courseware.SubCoursewareController;
	import com.doer.modes.fastquestion.FastQuestionController;
	import com.doer.modes.live.LiveController;
	import com.doer.modes.media.MediaController;
	import com.doer.modes.media.SubMediaController;
	import com.doer.modes.nav.MainNavController;
	import com.doer.modes.nav.SubNavController;
	import com.doer.modes.share.LiveVideoShareController;
	import com.doer.modes.share.SubLiveVideoShareController;
	import com.doer.modes.skydrive.SkyDriveController;
	import com.doer.modes.skydrive.SubSkyDriveController;
	import com.doer.modes.studentlist.StudentListController;
	import com.doer.modes.syn.SubSynDesktopController;
	import com.doer.modes.syn.SynDesktopController;
	import com.doer.modes.tools.ToolController;
	import com.doer.net.login.LoginController;
	import com.doer.net.socket.SocketController;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.doer.vmode.VideoAnalysis;
	import com.metaedu.client.messages.nebula.ClientComplexChangeScreen;
	import com.metaedu.client.messages.nebula.NebulaCharacterType;
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;
	import com.metaedu.client.messages.nebula.NebulaMessagePackage;
	import com.metaedu.client.messages.nebula.NebulaParticipantType;
	import com.metaedu.client.messages.nebula.NebulaScreenType;
	import com.metaedu.client.messages.nebula.ServerComplexChangeScreenInform;
	import com.metaedu.client.messages.nebula.ServerComplexTalkingStatusInform;
	import com.metaedu.client.messages.nebula.ServerGroupsTotalResp;
	import com.metaedu.client.messages.nebula.ServerPassiveOutInform;
	import com.metaedu.client.messages.nebula.ServerSignInResp;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	
	import view.ConversationPanel;
	import view.modes.nav.NavView;
	
	public class MetaManager extends AbstrackManager 
	{
		private var analysis:VideoAnalysis = null;
		
		/**
		 * 临时权限存储
		 * **/
		public var stoParticipantType:int = -1;
		
		
		public function MetaManager(metaEdu:ConversationPanel)
		{
			super(metaEdu);
		
			if(AppConf.isRecord)
			{
				analysis = new VideoAnalysis(this,metaEdu.videoMask);
			}
			
		}
		
		/**
		 * 重置状态
		 * **/
		public function reset():void
		{
			ComplexConf.activeScreen = -1;
			ComplexConf.participantType = -1;
			ComplexConf.isTalking = false;
			ComplexConf.isRaise = false;
			
			for(var i:int = 0; i < controllers.length; i ++)
			{
				controllers[i].reset();
			}
		}
		
		/**
		 * 开始初始化
		 * **/
		override protected function onInvalidateChildren():void
		{
			regist(new ModeController(this,ModeTypes.MODE_MANAGER_ID));//模块以及屏幕管理
			regist(new SocketController(this,ModeTypes.MODE_SOCKET_ID));//socket模块
			regist(new LoginController(this,ModeTypes.MODE_LOGIN_ID));//社交信息
			
			regist(new MainNavController(this,ModeTypes.MODE_MAINNAVGROUP_ID,mainClass.navGroup,mainClass.navGroup.mainContent)); //注册nav导航
			regist(new SubNavController(this,ModeTypes.MODE_SUBNAVGROUP_ID,mainClass.navGroup,mainClass.navGroup.subContent));
			
			regist(new BlackbordController(this,ModeTypes.MODE_BLACKBORD_ID,mainClass.mainContent)); //注册黑板
			regist(new SubBlackBordController(this,ModeTypes.MODE_SUB_BLACKBORD_ID,mainClass.subContent)); //注册黑板
			
			regist(new CoursewareController(this,ModeTypes.MODE_COURSE_ID,mainClass.mainContent)); //注册课件
			regist(new SubCoursewareController(this,ModeTypes.MODE_SUB_COURSE_ID,mainClass.subContent)); //注册课件
			
			regist(new LiveVideoShareController(this,ModeTypes.MODE_LIVEVIDEO_SHARE_ID,mainClass.mainContent));
			regist(new SubLiveVideoShareController(this,ModeTypes.MODE_SUB_LIVEVIDEO_SHARE_ID,mainClass.subContent));
			
			regist(new FastQuestionController(this,ModeTypes.MODE_FASTQUESTION_ID,mainClass.mainContent)); //注册快速问答
			
			regist(new MediaController(this,ModeTypes.MODE_MEDIA_ID,mainClass.mainContent,mainClass.mainDockContent)); //注册多媒体
			regist(new SubMediaController(this,ModeTypes.MODE_SUB_MEDIA_ID,mainClass.subContent,mainClass.subDockContent)); //注册多媒体
			
			regist(new SynDesktopController(this,ModeTypes.MODE_SYN_DESKTOP_ID,mainClass.mainContent));
			regist(new SubSynDesktopController(this,ModeTypes.MODE_SUB_SYN_DESKTOP_ID,mainClass.subContent));
			
			
			regist(new SkyDriveController(this,ModeTypes.MODE_SKYDRIVE_ID,mainClass.mainDockContent)); //注册资源搜索
			regist(new SubSkyDriveController(this,ModeTypes.MODE_SUB_SKYDRIVE_ID,mainClass.subDockContent)); //注册资源搜索
			
			
			regist(new StudentListController(this,ModeTypes.MODE_STUDENTLIST_ID,mainClass.mainDockContent)); //注册学生列表
			regist(new ChatController(this,ModeTypes.MODE_CHAT_ID,mainClass.mainDockContent)); //注册聊天
			regist(new LiveController(this,ModeTypes.MODE_LIVEVIDEO_ID,null,mainClass.liveView));//流媒体直播
			
			regist(new ToolController(this,ModeTypes.MODE_TOOLS_ID,mainClass.mainDockContent)); //设置模块
			
		}
		
		/**
		 * 收到服务端消息
		 * **/
		public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
			switch(refBusinessType)
			{
				case NebulaMessageBusinessType.SERVER_COMPLEX_AUDIO_PROVIDER_ASK_INFORM://收到被要求设置音频提供端
				case NebulaMessageBusinessType.SERVER_COMPLEX_AUDIO_PROVIDER_ANSWER_INFORM: //收到其他端要求设置音频消息
				case NebulaMessageBusinessType.SERVER_COMPLEX_VIDEO_PROVIDER_ANSWER_INFORM://收到其他的设置视频提供端
				case NebulaMessageBusinessType.SERVER_COMPLEX_VIDEO_PROVIDER_ASK_INFORM://收到被要求提供视频
				case NebulaMessageBusinessType.SERVER_COMPLEX_VIDEO_PUBLISH_INFORM:
				case NebulaMessageBusinessType.SERVER_COMPLEX_AUDIO_PUBLISH_INFORM:
				{
					getControllerById(ModeTypes.MODE_LIVEVIDEO_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					
					if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_VIDEO_PROVIDER_ANSWER_INFORM)
						getControllerById(ModeTypes.MODE_LIVEVIDEO_SHARE_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					
					break;
				}
				
				case NebulaMessageBusinessType.SERVER_COMPLEX_TALKING_STATUS_INFORM: //授权发言
				{
					onRcvComplexTalk(JsonUtils.convertJsonToClass(refContent,ServerComplexTalkingStatusInform));
					
					getControllerById(ModeTypes.MODE_STUDENTLIST_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					getControllerById(ModeTypes.MODE_LIVEVIDEO_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					getControllerById(ModeTypes.MODE_BLACKBORD_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					
					
					break;
				}
				
			 	case NebulaMessageBusinessType.SERVER_COMPLEX_AUDIO_UNPUBLISH_INFORM:
				case NebulaMessageBusinessType.SERVER_COMPLEX_VIDEO_UNPUBLISH_INFORM:
				case NebulaMessageBusinessType.SERVER_COMPLEX_AUDIO_PROVIDER_ASK_INFORM:
				{
					getControllerById(ModeTypes.MODE_LIVEVIDEO_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_OTHER_QUIT_INFORM:
				case NebulaMessageBusinessType.SERVER_COMPLEX_OTHER_ENTER_INFORM:
				{
					getControllerById(ModeTypes.MODE_STUDENTLIST_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					getControllerById(ModeTypes.MODE_LIVEVIDEO_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					break;
				}
				
				case NebulaMessageBusinessType.SERVER_COMPLEX_CHANGE_SCREEN_INFORM:
				{
					getControllerById(ModeTypes.MODE_MEDIA_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					getControllerById(ModeTypes.MODE_MANAGER_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_MOVE_INFORM:
				case NebulaMessageBusinessType.SERVER_COMPLEX_DRAW_INFORM:
				case NebulaMessageBusinessType.SERVER_COMPLEX_CLEAN_INFORM:
				{
					
					getControllerById(ModeTypes.MODE_BLACKBORD_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					getControllerById(ModeTypes.MODE_SUB_BLACKBORD_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					
					getControllerById(ModeTypes.MODE_COURSE_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					getControllerById(ModeTypes.MODE_SUB_COURSE_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_CHAT_INFORM:
				{
					
					getControllerById(ModeTypes.MODE_CHAT_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_MEDIA_PROVIDER_INFORM:
				case NebulaMessageBusinessType.SERVER_COMPLEX_MEDIA_CTRL_INFORM:
				{
					getControllerById(ModeTypes.MODE_MEDIA_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					getControllerById(ModeTypes.MODE_SUB_MEDIA_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_RAISE_INFORM:
				{
					getControllerById(ModeTypes.MODE_STUDENTLIST_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					getControllerById(ModeTypes.MODE_MAINNAVGROUP_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_RAISE_CTRL_INFORM :
				{
					getControllerById(ModeTypes.MODE_STUDENTLIST_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					getControllerById(ModeTypes.MODE_MAINNAVGROUP_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_CHAT_CTRL_INFORM:
				{
					getControllerById(ModeTypes.MODE_MAINNAVGROUP_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_VIDEO2_PUBLISH_INFORM:
				{
					getControllerById(ModeTypes.MODE_LIVEVIDEO_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_CHANGE_SCREEN_MODE_INFORM:
				{
					getControllerById(ModeTypes.MODE_MANAGER_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_LIVE_CTRL_INFORM:
				{
					getControllerById(ModeTypes.MODE_LIVEVIDEO_SHARE_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					getControllerById(ModeTypes.MODE_SUB_LIVEVIDEO_SHARE_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_DESKTOP_PUBLISH_INFORM:
				{
					getControllerById(ModeTypes.MODE_SYN_DESKTOP_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					getControllerById(ModeTypes.MODE_SUB_SYN_DESKTOP_ID).onRcv(refContent,refBusinessType,refTimeStamp);
				}
				
				case NebulaMessageBusinessType.SERVER_COMPLEX_ADD_FILE_INFORM:
				case NebulaMessageBusinessType.SERVER_COMPLEX_ADD_FILEPAGE_INFORM:
				{
					getControllerById(ModeTypes.MODE_COURSE_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					getControllerById(ModeTypes.MODE_MEDIA_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					getControllerById(ModeTypes.MODE_SKYDRIVE_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					break;
				}
				
				case NebulaMessageBusinessType.SERVER_COMPLEX_QUERY_FILE_RESPONSE:
				{
					getControllerById(ModeTypes.MODE_SKYDRIVE_ID).onRcv(refContent,refBusinessType,refTimeStamp);
					break;
				}
					
				default:
				{
					
					trace("有消息未处理： " + refBusinessType , refContent)
					
					break;
				}
			}
			
		}
		
		/**
		 * 收到被授权消息设置学生权限
		 * **/
		private function onRcvComplexTalk(talkInfo:ServerComplexTalkingStatusInform):void
		{
			if(talkInfo.id == ComplexConf.userId)
			{
				if(talkInfo.enable)
				{
					stoParticipantType = ComplexConf.participantType;
					
					ComplexConf.participantType = ComplexConf.Temp_ParticipantType;
					
				}else
				{
					ComplexConf.participantType = stoParticipantType;
					
					stoParticipantType = -1;
				}
				
			}
			
			
		}
		
	}
}