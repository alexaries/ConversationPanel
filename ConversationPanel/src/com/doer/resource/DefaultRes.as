package com.doer.resource
{
	import flash.display.Bitmap;
	import flash.events.EventDispatcher;

	public class DefaultRes extends EventDispatcher
	{
		
		private var colorRes:DefaultColor = new DefaultColor();
		
		private var imageRes:DefaultImages = new DefaultImages();
		
		/**
		 * 根据名字获取图片
		 * @param name ： 图片名字
		 * **/
		public function getBitmapByName(name:String):Bitmap
		{
			
			try
			{
				if(imageRes[name] != null)
					return new imageRes[name] as Bitmap;
			} 
			catch(error:Error) 
			{
				
			}
			
			
			return new imageRes.defaultIcon as Bitmap;
		}
		
		/**
		 * 根据名字获取颜色
		 * @param name ： 颜色名
		 * **/
		public function getColorByName(name:String):uint
		{
			return colorRes.getColorByName(name);;
		}
		
		
	}
}