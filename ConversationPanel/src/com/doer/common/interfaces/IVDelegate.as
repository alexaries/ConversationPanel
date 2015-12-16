package com.doer.common.interfaces
{
	import com.doer.meta.MetaCanvas;
	
	import mx.core.IVisualElementContainer;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	
	import view.common.text.TextLayer;

	public interface IVDelegate
	{
		/**
		 * 获取绘图类
		 * **/
		function getCanvas():MetaCanvas
		
		/**
		 * 文字层放置区域
		 * **/
		function getLayer():TextLayer
			
		/**
		 * 准备拖拉
		 * **/
		function readyDrag():void
			
		/**
		 * 清除拖拉
		 * **/
		function clearDrag():void
	}
}