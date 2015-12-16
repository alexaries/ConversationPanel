package com.doer.modes.studentlist
{
	import com.doer.common.Delegation;
	import com.doer.common.Tools;
	import com.doer.config.AppConf;
	import com.doer.config.ComplexConf;
	import com.doer.interfaces.ISProcessor;
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ClientComplexRaise;
	import com.metaedu.client.messages.nebula.ClientComplexRaiseCtrl;
	import com.metaedu.client.messages.nebula.ClientComplexTalkingStatus;
	import com.metaedu.client.messages.nebula.NebulaCharacterType;
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;
	import com.metaedu.client.messages.nebula.NebulaParticipantType;
	import com.metaedu.client.messages.nebula.ServerComplexAudioPublishInform;
	import com.metaedu.client.messages.nebula.ServerComplexAudioUnpublishInform;
	import com.metaedu.client.messages.nebula.ServerComplexEnterInform;
	import com.metaedu.client.messages.nebula.ServerComplexEnterResp;
	import com.metaedu.client.messages.nebula.ServerComplexOtherEnterInform;
	import com.metaedu.client.messages.nebula.ServerComplexOtherQuitInform;
	import com.metaedu.client.messages.nebula.ServerComplexRaiseCtrlInform;
	import com.metaedu.client.messages.nebula.ServerComplexRaiseInform;
	import com.metaedu.client.messages.nebula.ServerComplexTalkingStatusInform;
	import com.metaedu.client.messages.nebula.ServerComplexVideoPublishInform;
	import com.metaedu.client.messages.nebula.ServerComplexVideoUnpublishInform;
	import com.metaedu.client.messages.nebula.ServerPassiveOutInform;
	import com.metaedu.client.messages.nebula.ServerSignInResp;
	import com.metaedu.client.messages.nebula.complex.EnterInfo;
	import com.metaedu.client.messages.nebula.complex.KeyUserInfo;
	import com.metaedu.client.messages.nebula.complex.OnlineUnit;
	import com.metaedu.client.messages.nebula.complex.QuitInfo;
	import com.metaedu.client.messages.nebula.complex.RaiseCtrlType;
	import com.metaedu.client.messages.nebula.complex.TalkingStatus;
	import com.metaedu.client.messages.nebula.group.GroupBasic;
	import com.metaedu.client.messages.nebula.member.MemberBasic;
	import com.metaedu.client.messages.nebula.member.MemberGroupUnit;
	import com.metaedu.client.messages.nebula.member.MemberOrganizationUnit;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import flash.utils.setTimeout;
	
	import spark.components.Group;
	
	import view.modes.live.LiveView;
	import view.modes.studentlist.StudentListView;
	
	public class StudentListController extends AbstrackController
	{
		/** 发言人状态 */
		public var talkings:Vector.<TalkingStatus> = null;
		
		public function StudentListController(metaManager:MetaManager, modeId:int, container:Group=null)
		{
			super(metaManager, modeId, container);
			
			invalidateCommands();
		}
		
		override public function reset():void
		{
			if(modeView != null)
				removeView();
		}
		
		private function invalidateCommands():void
		{
			registCommand(LocalCommandType.CMD_LOGIN_COMPLETE);
			registCommand(LocalCommandType.CMD_NAV_RAISE);
		}
		
		/**
		 * 发送授权学生消息
		 * **/
		public function complexTalk(userId:String,enable:Boolean = true):void
		{
			var msg:ClientComplexTalkingStatus = new ClientComplexTalkingStatus();
			msg.enable = enable;
			msg.id = userId;
			
			if(!enable)
			{
				releaseTalks(userId);
			}else
			{
				if(talkings.length < 3)
					addTalks(userId);
				else
				{
					setTimeout(function():void{Tools.alert("最多只能授权两个学生！");},100);
					
					return;
				}
			}
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,msg));
			
			(modeView as StudentListView).onComplexTalk(getTalkingMembers());
		}
		
		/**
		 * 获取正在发言的学生
		 * **/
		public function getTalkingMembers():Array
		{
			var arr:Array = new Array();
			
			if(talkings != null)
			{
				for(var i:int = 0; i < talkings.length; i ++)
				{
					for each(var member:OnlineUnit in ComplexConf.onlines)
					{
						if(talkings[i].id == member.id && member.id != ComplexConf.chargInfo.id)
						{
							var obj:Object = {
								
								id : member.id,
								name : member.name,
								surname : member.surname,
								isPower : true
							}
							
							arr.push(obj);
							break;
						}
					}
					
				}
				
			}
			
			
			return arr;
			
		}
		
		/**
		 * 获取所有学生
		 * **/
		public function getMembers():Array
		{
			var arr:Array = new Array();
			
			for each(var online:OnlineUnit in ComplexConf.onlines)
			{
				var obj:Object = {
					
					id : online.id,
					isRaise : online.isRaise,
					name : online.name,
					surname : online.surname,
					orzs : null
				}
				
				arr.push(obj);
			}
			
			return arr;
		}
		
		
		override public function registView():IView
		{
			var sview:StudentListView = new StudentListView();
			
			
			sview.x = container.width/2 - sview.width/2;
			
			sview.y = container.height/2 - sview.height/2;
			
			return sview;
		}
		
		override public function onCommand(cmd:LocalCommand):void
		{
			if(cmd.command == LocalCommandType.CMD_LOGIN_COMPLETE)
			{
				//removeCommand(LocalCommandType.CMD_LOGIN_COMPLETE);
				
				onLoginInfo(cmd.data as ServerComplexEnterResp);
			}else if(cmd.command == LocalCommandType.CMD_NAV_RAISE)
			{
				onRaiseHandler(cmd.data.selected);
			}
			
		}
		
		public function onRaiseHandler(isRaise:Boolean):void
		{
			if(ComplexConf.participantType == NebulaParticipantType.JOINER && ComplexConf.enableRaise ||
				ComplexConf.participantType == ComplexConf.Temp_ParticipantType && metaManager.stoParticipantType == NebulaParticipantType.JOINER)
			{
				ComplexConf.isRaise = isRaise;
				
				var msg:ClientComplexRaise = new ClientComplexRaise();
				msg.id = ComplexConf.userId;
				msg.enable = ComplexConf.isRaise;
				
				sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,msg));
				
				for each(var status:OnlineUnit in ComplexConf.onlines)
				{
					if(status.id == ComplexConf.userId)
					{
						status.isRaise = isRaise;
						break;
					}
				}
				
				if(modeView != null)
				{
					(modeView as StudentListView).onRaise(ComplexConf.userId,isRaise);
				}
				
			}else if(ComplexConf.participantType == NebulaParticipantType.CHARGE)
			{
				clearRaise();
	
				sendCommand(new LocalCommand(LocalCommandType.CMD_SET_NAV_NUMS,{hand : getHandNum()}));
				
				var clientMsg:ClientComplexRaiseCtrl = new ClientComplexRaiseCtrl();
				clientMsg.ctrlType = RaiseCtrlType.CLEAR;
				
				sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,clientMsg));
				
			}
			
		}
		
		
		private function onLoginInfo(loginInfo:ServerComplexEnterResp):void
		{
			talkings = loginInfo.talkings;
			
			metaManager.mainClass.numText = "在线人数 ： " + ComplexConf.onlines.length + "人";
			
			if(!AppConf.isRecord)
			{
				metaManager.mainClass.selfNameText = "在线用户 ： " + loginInfo.status.surname + loginInfo.status.name;
				metaManager.mainClass.complexName = ComplexConf.complexName;
				
				
				for each(var status:OnlineUnit in ComplexConf.onlines)
				{
					if(status.id == ComplexConf.userId)
					{
						ComplexConf.isRaise = status.isRaise;
						break;
					}
					
				}
			}
			
			
			if( ComplexConf.participantType == NebulaParticipantType.CHARGE)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_SET_NAV_NUMS,{hand : getHandNum()}));
			}
			
		}
		
		override public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
			switch(refBusinessType)
			{
				case NebulaMessageBusinessType.SERVER_COMPLEX_AUDIO_PUBLISH_INFORM:
				{
					setAudioTalking(JsonUtils.convertJsonToClass(refContent,ServerComplexAudioPublishInform));
					
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_VIDEO_PUBLISH_INFORM:
				{
					
					setVideoTalking(JsonUtils.convertJsonToClass(refContent,ServerComplexVideoPublishInform));
					
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_TALKING_STATUS_INFORM:
				{
					
					onRcvComplexTalk(JsonUtils.convertJsonToClass(refContent,ServerComplexTalkingStatusInform));
					break;
				}
				
				case NebulaMessageBusinessType.SERVER_COMPLEX_OTHER_ENTER_INFORM:
				{
					
					onRcvOtherLogin(JsonUtils.convertJsonToClass(refContent,ServerComplexOtherEnterInform));
					
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_OTHER_QUIT_INFORM:
				{
					onRcvOtherLogout(JsonUtils.convertJsonToClass(refContent,ServerComplexOtherQuitInform));
					
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_RAISE_INFORM:
				{
					onRcvRaise(JsonUtils.convertJsonToClass(refContent,ServerComplexRaiseInform));
					
					break;
				}
					
				case NebulaMessageBusinessType.SERVER_COMPLEX_RAISE_CTRL_INFORM:
				{
					onRcvRaiseCtr(JsonUtils.convertJsonToClass(refContent,ServerComplexRaiseCtrlInform));
					break;
				}
					
				default:
				{
					break;
				}
			}
			
			
		}
		
		/**
		 * 举手控制
		 * **/
		private function onRcvRaiseCtr(info:ServerComplexRaiseCtrlInform):void
		{
			if(info.ctrlType == RaiseCtrlType.CLEAR)
			{
				clearRaise();
			}
			
		}
		
		/**
		 * 清空举手
		 * **/
		private function clearRaise():void
		{
			for each(var status:OnlineUnit in ComplexConf.onlines)
			{
				status.isRaise = false;
			}
			
			if(modeView != null)
			{
				(modeView as StudentListView).clearRaise();
			}
			
			ComplexConf.isRaise = false;
		}
		
		private var raiseQueue:Vector.<ServerComplexRaiseInform> = new Vector.<ServerComplexRaiseInform>();
		
		/**
		 * 收到举手消息
		 * **/
		private function onRcvRaise(info:ServerComplexRaiseInform):void
		{
			
			var isIn:Boolean = false;
			
			for each(var status:OnlineUnit in ComplexConf.onlines)
			{
				if(status.id == info.id)
				{
					isIn = true;
					status.isRaise = info.enable;
					break;
				}
			}
			
			if(!isIn)
				raiseQueue.push(info);
			
			if(ComplexConf.participantType == NebulaParticipantType.CHARGE)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_SET_NAV_NUMS,{hand : getHandNum()}));
			}
			
			
			if(modeView != null)
			{
				(modeView as StudentListView).onRaise(info.id,info.enable);
			}
			
		}
		
		/**
		 * 收到其他人登录消息
		 * **/
		private function onRcvOtherLogin(info:ServerComplexOtherEnterInform):void
		{
			
			ComplexConf.addOnlineMember(info);
			
			var raise:Boolean = false;
			
			if(raiseQueue.length != 0)
			{
				for each(var status:OnlineUnit in ComplexConf.onlines)
				{
					for(var i:int = 0; i < raiseQueue.length; i ++)
					{
						if(status.id == raiseQueue[i].id)
						{
							raise = true;
							status.isRaise = raiseQueue[i].enable;
							raiseQueue.splice(i,1);
							break;
						}
					}
					
				}
			}

			metaManager.mainClass.numText = "在线人数 ： " + ComplexConf.onlines.length + "人";

			if(modeView != null)
			{
				
				for each(var enterInfo:EnterInfo in info.infos)
				{
					var member:OnlineUnit = ComplexConf.getMemberById(enterInfo.id);
					
					(modeView as StudentListView).onOtherLogin(enterInfo.id,member.surname,member.name,null,raise);
				}
				
				
			}
			
		}
		
		/**
		 * 收到其他人登出消息
		 * **/
		private function onRcvOtherLogout(logoutMsg:ServerComplexOtherQuitInform):void
		{
			
			for each(var info:QuitInfo in logoutMsg.infos)
			{
				
				var status:OnlineUnit = ComplexConf.getMemberById(info.id);
				
				ComplexConf.removeOnlineMember(info.id);
				
				if( ComplexConf.participantType == NebulaParticipantType.CHARGE)
				{
					sendCommand(new LocalCommand(LocalCommandType.CMD_SET_NAV_NUMS,{hand : getHandNum()}));
				}
				
				
				if(info.id == ComplexConf.chargInfo.id)
				{
					ComplexConf.isChargeOnline = false;
				}
				
				
				metaManager.mainClass.numText = "在线人数 ： " + ComplexConf.onlines.length + "人";
				
				
				if(modeView != null)
				{
					(modeView as StudentListView).onOtherLogout(info.id);
					(modeView as StudentListView).onComplexTalk(getTalkingMembers());
				}
				
			}
			
			
			
			
		}
		
		
		/**
		 * 收到发言授权
		 * **/
		private function onRcvComplexTalk(complexTalk:ServerComplexTalkingStatusInform):void
		{
			if(complexTalk.id == ComplexConf.userId)
				ComplexConf.isTalking = complexTalk.enable;
			
			if(!complexTalk.enable)
				releaseTalks(complexTalk.id);
			else
				addTalks(complexTalk.id);
		
			
			if(modeView != null)
			{
				(modeView as StudentListView).onComplexTalk(getTalkingMembers());
			}
			
			
		}
		
		/**
		 * 收到别人发布视频
		 * **/
		private function setVideoTalking(videoInfo:ServerComplexVideoPublishInform):void
		{
			var talking:TalkingStatus = null;
			
			if(!isInTalkings(videoInfo.id))
			{
				addTalks(videoInfo.id);
			}
			
			for each(talking in talkings)
			{
				if(talking.id == videoInfo.id)
				{
					talking.videoUrl = videoInfo.url;
					break;
				}
				
			}
			
		}
		
		/**
		 * 收到别人发布音频
		 * **/
		private function setAudioTalking(audioInfo:ServerComplexAudioPublishInform):void
		{
			var talking:TalkingStatus = null;
			
			if(!isInTalkings(audioInfo.id))
			{
				addTalks(audioInfo.id);
			}
			
			for each(talking in talkings)
			{
				if(talking.id == audioInfo.id)
				{
					talking.videoUrl = audioInfo.url;
					break;
				}
				
			}
		
		}
		
		private function isInTalkings(userId:String):Boolean
		{
			for(var i:int = 0; i < talkings.length; i ++)
			{
				if(talkings[i].id == userId)
					return true;
			}
			
			return false;
		}
		
		private function releaseTalks(userId:String):void
		{
			for(var i:int = 0; i < talkings.length; i ++)
			{
				if(talkings[i].id == userId)
				{
					talkings.splice(i,1);
					break;
				}
			}
		}
		
		private function addTalks(userId:String):void
		{
			if(!isInTalkings(userId))
			{
				var talking:TalkingStatus = new TalkingStatus();
				talking.id = userId;
				
				talkings.push(talking);
			}
			
			
		}
		
		private function getHandNum():int
		{
			var num:int = 0;
			
			for each(var status:OnlineUnit in ComplexConf.onlines)
			{
				if(status.isRaise)
					num ++;
			}
			
			return num;
		}
		
		/**
		 * 切换举手权限
		 * **/
		public function onExchangeRaise():void
		{
			ComplexConf.enableRaise = !ComplexConf.enableRaise;
			
			var msg:ClientComplexRaiseCtrl = new ClientComplexRaiseCtrl();
			
			msg.ctrlType = ComplexConf.enableRaise ? RaiseCtrlType.ENABLE : RaiseCtrlType.DISABLE;
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,msg));
			
		}
		
		
		
	}
}