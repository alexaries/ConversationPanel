package com.doer.utils
{
	/**
	 * 本地消息枚举
	 * **/
	public class LocalCommandType
	{
		//导航区开始
		/**
		 * 导航画笔
		 * **/
		public static const CMD_NAV_PEN:String = "CMD_NAV_PEN";
		
		/**
		 * 导航橡皮
		 * **/
		public static const CMD_NAV_ERASER:String = "CMD_NAV_ERASER";
		
		/**
		 * 导航清空
		 * **/
		public static const CMD_NAV_CLEAR:String = "CMD_NAV_CLEAR";
		
		/**
		 * 导航文字
		 * **/
		public static const CMD_NAV_TEXT:String = "CMD_NAV_TEXT";
		
		/**
		 * 拖动
		 * **/
		public static const CMD_NAV_HAND:String = "CMD_NAV_HAND";
		
		/**
		 * 导航黑板
		 * **/
		public static const CMD_NAV_BLACKBORD:String = "CMD_NAV_BLACKBORD";
		
		/**
		 * 导航课件
		 * **/
		public static const CMD_NAV_COURSE:String = "CMD_NAV_COURSE";
		
		/**
		 * 导航聊天
		 * **/
		public static const CMD_NAV_CHAT:String = "CMD_NAV_CHAT";
		
		/**
		 * 导航快速问答
		 * **/
		public static const CMD_NAV_FASTQUESTION:String = "CMD_NAV_FASTQUESTION";
		
		/**
		 * 导航多媒体
		 * **/
		public static const CMD_NAV_MEDIA:String = "CMD_NAV_MEDIA";
		
		/**
		 * 导航学生列表
		 * **/
		public static const CMD_NAV_STUDENTLIST:String = "CMD_NAV_STUDENTLIST";
		
		/**
		 * 导航资源引用
		 * **/
		public static const CMD_NAV_RESOURCES:String = "CMD_NAV_RESOURCES";
		
		/**
		 * 上传
		 * **/
		public static const CMD_NAV_UPLOAD:String = "CMD_NAV_UPLOAD";
		
		
		/**
		 * 举手
		 * **/
		public static const CMD_NAV_RAISE:String = "CMD_NAV_RAISE";
		
		/**
		 * 设置
		 * **/
		public static const CMD_NAV_SET:String = "CMD_NAV_SET";
		
		/**
		 * 视频分享
		 * **/
		public static const CMD_NAV_VIDEO_SHARE:String = "CMD_NAV_VIDEO_SHARE";
		
		/**
		 * 桌面同步
		 * **/
		public static const CMD_NAV_DESKTOP_SYN:String = "CMD_NAV_DESKTOP_SYN";
		
		/**
		 * 打开文件
		 * **/
		public static const CMD_OPEN_FILE:String = "CMD_OPEN_FILE";
		
		//内部信令
		
		/**
		 * 发送到服务端
		 * **/
		public static const CMD_SEND_TO_SERVER:String = "CMD_SEND_SERVER";
		
		/**
		 * 登录完成
		 * **/
		public static const CMD_LOGIN_COMPLETE:String = "CMD_LOGIN_CONVERSATION_COMPLETE";
		
		/**
		 * 与会者权限变更
		 * **/
		public static const CMD_PARTICIPANTTYPE_CHANGE:String = "CMD_PARTICIPANTTYPE_CHANGE";
		
		/**
		 * 主屏幕变更
		 * **/
		public static const CMD_ACTIVITESCREEN_CHANGE:String = "CMD_ACTIVITESCREEN_CHANGE";
		
		/**
		 * 聊天权限变更
		 * **/
		public static const CMD_CHAT_POWER_CHANGE:String = "CMD_CHAT_POWER_CHANGE";
		
		
		/**
		 * 设置导航栏状态数值
		 * **/
		public static const CMD_SET_NAV_NUMS:String = "CMD_SET_NAV_NUMS";
		
		/**
		 * 辅屏幕状态改变
		 * **/
		public static const CMD_SUBACTIVITESCREEN_CHANGE:String = "CMD_SUBACTIVITESCREEN_CHANGE";
		
		/**
		 * 屏幕状态改变
		 * **/
		public static const CMD_SCREEN_CLIP_STATUE:String = "CMD_SCREEN_CLIP_STATUE";
		
		
		/**
		 * 设置信息改变
		 * **/
		public static const CMD_SETTER_CHANGE:String = "CMD_SETTER_CHANGE";
		
		/**
		 * 视频1打开/关闭状态
		 * **/
		public static const CMD_VIDEO1_CHANGE:String = "CMD_VIDEO1_CHANGE";
		
		/**
		 * 视频2打开/关闭状态
		 * **/
		public static const CMD_VIDEO2_CHANGE:String = "CMD_VIDEO2_CHANGE";
		
		/**
		 * 音频打开/关闭状态
		 * **/
		public static const CMD_AUDIO_CHANGE:String = "CMD_AUDIO_CHANGE";
		
		/**
		 * live摄像头初始化完毕
		 * **/
		public static const CMD_LIVE_INVALIDATED:String = "CMD_LIVE_INVALIDATED";
		
		/**
		 * live渲染信息变更
		 * **/
		public static const CMD_RENDER_CHANGE:String = "CMD_RENDER_CHANGE";
		
		/**
		 * 云盘刷新数据
		 * **/
		public static const CMD_SKYDRIVE_REFRESH:String = "CMD_SKYDRIVE_REFRESH";
		
	}
}