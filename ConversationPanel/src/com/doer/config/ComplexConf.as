package com.doer.config
{
	import com.doer.interfaces.IMainClass;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.NebulaPlatformType;
	import com.metaedu.client.messages.nebula.NebulaScreenType;
	import com.metaedu.client.messages.nebula.ServerComplexOtherEnterInform;
	import com.metaedu.client.messages.nebula.complex.EnterInfo;
	import com.metaedu.client.messages.nebula.complex.KeyUserInfo;
	import com.metaedu.client.messages.nebula.complex.OnlineUnit;
	import com.metaedu.client.messages.nebula.group.GroupBasic;
	import com.metaedu.client.messages.nebula.member.MemberBasic;
	
	import flash.external.ExternalInterface;
	import flash.system.fscommand;
	
	import mx.core.FlexGlobals;

	public class ComplexConf
	{
		/**
		 * 临时权限
		 * **/
		public static const Temp_ParticipantType:int = -1000;
		
		/**
		 * 16 ： 9的分辨率
		 * **/
		public static const VIDEO_16_9:String = "800x480";
		
		/**
		 * 4 : 3分辨率
		 * **/
		public static const VIDEO_4_3:String = "640x480";
		
		/**
		 * WEB分辨率
		 * **/
		public static const VIDEO_4_3_WEB:String = "320x240";
		
		private static var _activeScreen:int = -1;
		
		private static var _participantType:int = -1;
		
		private static var _enableChat:Boolean = true;
		
		private static var _subActiveScreen:int = -1;
		
		private static var _isClipScreen:Boolean = false;
		
		private static var _screenMode:String = ScreenParams.SCREEN_SINGLE_LEFT;
		
		/**
		 * 指令发送器
		 * **/
		public static var commander:AbstrackController = null;
		
		/**
		 * 名字
		 * **/
		public static var name:String = null;
		
		/**
		 * 姓
		 * **/
		public static var surname:String = null;
		
		/**
		 * 性别
		 * **/
		public static var sex:int = 0;
		
		/**
		 * 用户id
		 * **/
		public static var userId:String = null;
		
		/**
		 * 头像
		 * **/
		public static var avatar:String = null;
		
		/**
		 * 账号
		 * **/
		public static var account:String = null;
		
		/**
		 * 白板序列号
		 * **/
		public static var bordAccount:String = null;
		
		/**
		 * 密码
		 * **/
		public static var password:String = null;
		
		/**
		 * 机构id
		 * **/
		public static var institutionId:String = null;
		
		/** 
		 * 机构的名称，未绑定机构则无值 
		 * */
		public static var institutionName:String = "";
		
		/**
		 *  超级黑板指定名称，自由黑板（未绑定机构）则为 IP:PORT
		 *  */
		public static var deviceName:String = "";
		
		/**
		 * 回话id
		 * **/
		public static var complexId:String = null;
		
		/**
		 * 回话名
		 * **/
		public static var complexName:String = null;
		
		/**
		 * 主讲人信息
		 * **/
		public static var chargInfo:KeyUserInfo = null;
		
		/**
		 * 主讲是否在线
		 * **/
		public static var isChargeOnline:Boolean = false;
		
		/**
		 * 是否通用登录
		 * **/
		public static var isGeneralLogin:Boolean = false;
		
		/**
		 * 是否举手
		 * **/
		[Bindable]
		public static var isRaise:Boolean = false;
		
		/**
		 * 是否正在发言
		 * **/
		[Bindable]
		public static var isTalking:Boolean = false;
		
		/**
		 * 是否登录完成
		 * **/
		[Bindable]
		public static var isLoginComplete:Boolean = false;
		
		/**
		 * 是否双摄像头
		 * **/
		[Bindable]
		public static var isDoubleCamera:Boolean = true;
		
		/**
		 * 主摄像头是否打开
		 * **/
		[Bindable]
		public static var isMainCameraOn:Boolean = false;
		
		/**
		 * 辅摄像头是否打开
		 * **/
		[Bindable]
		public static var isSubCameraOn:Boolean = false;
		
		/**
		 * 麦克风是否打开
		 * **/
		[Bindable]
		public static var isMicphoneOn:Boolean = false;
		
		/**
		 * 主摄像头索引
		 * **/
		[Bindable]
		public static var mainCameraIndex:int = -1;
		
		/**
		 * 辅摄像头索引
		 * **/
		[Bindable]
		public static var subCameraIndex:int = -1;
		
		/**
		 * 麦克风索引
		 * **/
		[Bindable]
		public static var micphoneIndex:int = 0;
		
		/**
		 * 麦克风音量
		 * **/
		[Bindable]
		public static var micphoneVolume:Number = 80;
		
		/**
		 * 声音音量
		 * **/
		[Bindable]
		public static var soundVolume:Number = 80;
		
		/**
		 * 是否允许举手
		 * **/
		[Bindable]
		public static var enableRaise:Boolean = true;
		
		
		/**
		 * 主摄像头分辨率
		 * **/
		public static var videoDetail1:String = VIDEO_16_9;
		
		/**
		 * 辅摄像头分辨率
		 * **/
		public static var videoDetail2:String = VIDEO_16_9;
		
		/**
		 * 同步桌面分辨率
		 * **/
		public static var synVideoDetail:String = VIDEO_16_9;
		
		/**
		 * 是否白板模式
		 * **/
		public static var isBordMode:Boolean = true;
		
		/**
		 * 在线人
		 * **/
		public static var onlines:Vector.<OnlineUnit> = null;
		
		/**
		 * 屏幕信息
		 * **/
		public static var screens:Vector.<ScreenParams> = null;
		
		/**
		 * 屏幕模式
		 * **/
		[Bindable]
		public static function get screenMode():String
		{
			return _screenMode;
		}

		/**
		 * @private
		 */
		public static function set screenMode(value:String):void
		{
			_screenMode = value;
			
			//fscommand(value);
			
			try
			{
				ExternalInterface.call(value);
			} 
			catch(error:Error) 
			{
				
			}
			
		}

		[Bindable]
		/**
		 * 是否分屏模式
		 * **/
		public static function get isClipScreen():Boolean
		{
			return _isClipScreen;
		}

		/**
		 * @private
		 */
		public static function set isClipScreen(value:Boolean):void
		{
			_isClipScreen = value;
			
			if(commander != null)
			commander.sendCommand(new LocalCommand(LocalCommandType.CMD_SCREEN_CLIP_STATUE));
			
			checkQuitShare();
			
		}

		/**
		 * 辅屏状态
		 * **/
		[Bindable]
		public static function get subActiveScreen():int
		{
			return _subActiveScreen;
		}

		/**
		 * @private
		 */
		public static function set subActiveScreen(value:int):void
		{
			_subActiveScreen = value;
			
			if(commander != null)
			commander.sendCommand(new LocalCommand(LocalCommandType.CMD_SUBACTIVITESCREEN_CHANGE));
			
			checkQuitShare();
			
		}

		/**
		 * 是否允许聊天
		 * **/
		[Bindable]
		public static function get enableChat():Boolean
		{
			return _enableChat;
		}

		/**
		 * @private
		 */
		public static function set enableChat(value:Boolean):void
		{
			_enableChat = value;
			
			if(commander != null)
			commander.sendCommand(new LocalCommand(LocalCommandType.CMD_CHAT_POWER_CHANGE));
			
		}
		
		/**
		 * 当前显示主屏幕
		 * **/
		[Bindable]
		public static function get activeScreen():int
		{
			return _activeScreen;
		}

		/**
		 * @private
		 */
		public static function set activeScreen(value:int):void
		{
			_activeScreen = value;
			
			if(commander != null)
			commander.sendCommand(new LocalCommand(LocalCommandType.CMD_ACTIVITESCREEN_CHANGE));
			
			checkQuitShare();
			
		}
		
		private static function checkQuitShare():void
		{
			if(isClipScreen)
			{
				if(activeScreen != NebulaScreenType.DESKTOP && subActiveScreen != NebulaScreenType.DESKTOP)
				{
					try
					{
						ExternalInterface.call(screenMode);
						//fscommand(screenMode);
					} 
					catch(error:Error) 
					{
						
					}
					
				}
					
			}else
			{
				if(activeScreen != NebulaScreenType.DESKTOP)
				{
					try
					{
						ExternalInterface.call(screenMode);
						//fscommand(screenMode);
					} 
					catch(error:Error) 
					{
						
					}
					
				}
					
			}
		}
		
		
		/**
		 * 角色权限
		 * **/
		[Bindable]
		public static function get participantType():int
		{
			return _participantType;
		}

		/**
		 * @private
		 */
		public static function set participantType(value:int):void
		{
			_participantType = value;
			
			if(commander != null)
			commander.sendCommand(new LocalCommand(LocalCommandType.CMD_PARTICIPANTTYPE_CHANGE));
		
			
		}

		/***
		 * 获取个人成员
		 * **/
		public static function getMemberById(id:String):OnlineUnit
		{
			for each(var status:OnlineUnit in onlines)
			{
				if(id == status.id)
					return status;
			}
			
			return null;
		}
		
		/**
		 * 添加设计个人信息
		 * **/
		public static function addOnlineMember(info:ServerComplexOtherEnterInform):void
		{
			for each(var enterInfo:EnterInfo in info.infos)
			{
				var onlineStatus:OnlineUnit = new OnlineUnit();
				onlineStatus.id = enterInfo.id;
				onlineStatus.surname = enterInfo.surname;
				onlineStatus.name = enterInfo.name;
				onlineStatus.sex = enterInfo.sex;
				
				onlines.push(onlineStatus);
				
				if(enterInfo.id == ComplexConf.chargInfo.id)
					ComplexConf.isChargeOnline = true;
						
				
				
			}
			
		
		}
		
		/**
		 * 移除个人信息
		 * **/
		public static function removeOnlineMember(id:String):void
		{
			for(var i:int = 0; i < onlines.length; i ++)
			{
				if(onlines[i].id == id)
				{
					onlines.splice(i,1);
					break;
				}
			}
			
		}
		
	}
}
