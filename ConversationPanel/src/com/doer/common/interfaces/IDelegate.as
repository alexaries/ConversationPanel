package com.doer.common.interfaces
{
	import flash.events.IEventDispatcher;

	public interface IDelegate
	{		
		/**
		 * 获取初始化绘图数据
		 * **/
		function getInvalidatePaintdata(bookId:String,pageId:int):Array
			
		/***
		 * 保存绘图数据
		 * */
		function saveDelegatePaintdata(data:Object):void
			
		/**
		 * 清空绘图数据
		 * **/
		function clear():void
	}
}