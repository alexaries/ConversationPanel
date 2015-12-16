package com.doer.interfaces
{
	public interface IView
	{
		/**
		 * 控制器
		 * **/
		function set controller(value:IController):void
		
		/**
		 * 该模块控制器
		 * **/
		function get controller():IController
		
		/**
		 * 是否初始化完成
		 * **/
		function get isInvalidated():Boolean
			
		/**
		 * 设置角色权限
		 * **/
		function setParticipantTypePower(participantType:int):void
			
		/**
		 * 销毁资源
		 * **/
		function onDestroy():void
			
		/**
		 * 被添加到可视化树之后开始初始化
		 * **/
		function invalidate():void
			
	}
}