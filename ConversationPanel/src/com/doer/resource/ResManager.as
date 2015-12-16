package com.doer.resource
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;

	public class ResManager extends EventDispatcher
	{
		public static const change:String = "change";
		
		private static var instance:ResManager = null;
		
		private var loader:Loader = null;
	
		private var defaultRes:DefaultRes = null;
		
		private var resObj:Object = null;
		
		public static function getInstance():ResManager
		{
			if(instance == null)
				instance = new ResManager(new inne());
			
			return instance;
		}
		
		public function ResManager(inn:inne)
		{
			defaultRes = new DefaultRes();
		}
		
		/**
		 * 加载样式swf
		 * @param styleAddress ： 样式swf所在地址
		 * **/
		public function loadStyle(styleAddress:String):void
		{
			loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadComplete);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecError);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onIoError);
			
			loader.load(new URLRequest(styleAddress));
		}
		
		private function onLoadComplete(e:Event):void
		{
			resObj = loader.content as Object;
			
			dispatchEvent(new Event("change"));
		}
		
		private function onSecError(e:SecurityErrorEvent):void
		{
			
		}
		
		private function onIoError(e:IOErrorEvent):void
		{
			
		}
		
		/**
		 * 获取图片
		 * **/
		[Bindable("change")]
		public function getBitmap(name:String):Bitmap
		{
			if(resObj == null)
				return defaultRes.getBitmapByName(name);
				
			return resObj.getBitmapByName(name);
		}
		
		/**
		 * 获取颜色
		 * **/
		[Bindable("change")]
		public function getColor(name:String):uint
		{
			if(resObj == null)
				return defaultRes.getColorByName(name);
			
			return resObj.getColorByName(name);
		}
		
		
	}
}

class inne{};