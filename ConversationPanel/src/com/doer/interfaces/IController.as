package com.doer.interfaces
{
	import com.doer.utils.LocalCommand;
	
	import spark.components.Group;

	public interface IController
	{
		/**
		 * 是否常驻ui
		 * **/
		function get resident():Boolean
		
		/**
		 * 获取模块id
		 * **/
		function get modeId():int
			
		/**
		 * 该模块持有的view
		 * **/
		function get modeView():IView
			
		/**
		 * 该模块持有的view
		 * **/
		function set modeView(value:IView):void
			
		/**
		 * 设置返回到初始状态
		 * **/
		function reset():void
			
		/**
		 * 注册该模块view
		 * **/
		function registView():IView
			
		/**
		 * 显示此模块的view
		 * **/
		function addView():void
			
		/**
		 * 隐藏此模块的view
		 * **/
		function removeView():void
			
		/**
		 * 销毁资源
		 * **/
		function onDestroy():void
	}
}