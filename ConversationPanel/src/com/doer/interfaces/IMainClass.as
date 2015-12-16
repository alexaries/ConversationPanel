package com.doer.interfaces
{
	import spark.components.Group;

	public interface IMainClass
	{
		/**
		 * 连接后回调
		 * **/
		function onConnect():void
			
		/**
		 * 登录到会话后回调
		 * **/
		function onLogin():void
			
		/**
		 * 会话关闭
		 * **/
		function onLogout():void
		
		/**
		 * 退出登录
		 * **/
		function onQuit():void
			
		/**
		 * 切换屏幕模式
		 * **/
		function onChangeScreenMode(args:String=null):void
		
		/**
		 * 获取弹出层
		 * **/
		function get alertContent():Group
	}
}