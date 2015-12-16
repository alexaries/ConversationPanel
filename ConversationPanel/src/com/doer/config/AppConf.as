package com.doer.config
{
	import com.metaedu.client.messages.nebula.NebulaPlatformType;

	public class AppConf
	{
		/**
		 * 虚拟摄像头明
		 * **/
		public static var vituralCameraName:String = "e2eSoft VCam (WDM)";
		
		/**
		 *  设备标记 
		 * */
		public static var deviceMark:String = '';
		
		/** 
		 * 平台标识（默认Web）
		 * */
		public static var platform:int = NebulaPlatformType.WEB;
		
		/** 
		 * 登陆令牌 
		 * */
		public static var session:String = '';
		
		/**
		 * 是否录像模式
		 * **/
		public static var isRecord:Boolean = false;
			
		/**
		 * 消息服务地址
		 * **/
		public static var messageAddr:String = "192.168.18.21";
		
		/**
		 * rtmp服务地址
		 * **/
		public static var streamAddr:String = "192.168.18.7";
		
		/**
		 * web服务地址
		 * **/
		public static var webAddr:String = "192.168.18.21:8080";
		
		/**
		 * 文件地址
		 * **/
		public static var fileAddr:String = "192.168.18.22";
		
//		/**
//		 * 消息服务地址
//		 * **/
//		public static var messageAddr:String = "123.59.86.40";
//		
//		/**
//		 * rtmp服务地址
//		 * **/
//		public static var streamAddr:String = "180.150.179.65";
//		
//		/**
//		 * web服务地址
//		 * **/
//		public static var webAddr:String = "123.59.86.34";
//		
//		/**
//		 * 文件地址
//		 * **/
//		public static var fileAddr:String = "123.59.86.34";

		private static var _rtmpLiveAddress:String = null;
		
		private static var _rtmpVodAddress:String = null;
		
		
		/**
		 * 点播地址
		 * **/
		public static function get rtmpVodAddress():String
		{
			return "rtmp://" + streamAddr + "/vod" ;
		}

		/**
		 * rtmpAddress
		 * **/
		public static function get rtmpLiveAddress():String
		{
			return "rtmp://" + streamAddr + "/live" ;
		}

	}
}