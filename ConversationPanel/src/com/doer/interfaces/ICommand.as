package com.doer.interfaces
{
	import com.doer.utils.LocalCommand;

	public interface ICommand
	{
		/**
		 * 收到命令
		 * @param cmd LocalCommand实例
		 * **/
		function onCommand(cmd:LocalCommand):void
		
		/**
		 * 发送命令
		 * @param cmd LocalCommand实例
		 * **/
		function sendCommand(cmd:LocalCommand):void
		
		/**
		 * 注册命令
		 * @param command LocalCommand 类型
		 * **/
		function registCommand(command:String):void
		
		/**
		 * 移除命令
		 * @param command LocalCommand 类型
		 * **/
		function removeCommand(command:String):void
	}
}