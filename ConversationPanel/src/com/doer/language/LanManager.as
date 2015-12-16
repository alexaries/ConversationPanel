package com.doer.language
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	public class LanManager extends EventDispatcher
	{
		private static const BUNDLE_NAME:String = "language";
		private static var resourceManager:IResourceManager = null;
		private static var instance:LanManager = null;
		private static var currentLanguage:String = "zh_CN";
		
		public static function getInstance():LanManager {
			if(instance == null) {
				instance = new LanManager();
				resourceManager = ResourceManager.getInstance();
				resourceManager.initializeLocaleChain([currentLanguage]);
			}
			return instance;
		}
		
		public function changeLanguage(languageName:String):void {
			resourceManager.localeChain.localeChain = [languageName];
			currentLanguage = languageName;
			dispatchChange();
		}
		
		[Bindable("change")]
		public function getImage(resName:String):Class {
			var result:Class = resourceManager.getClass(BUNDLE_NAME, resName
				, currentLanguage);
			return result;
		}
		
		[Bindable("change")]
		public function getString(resName:String, para:Array = null):String {
			var result:String = resourceManager.getString(BUNDLE_NAME, resName, para
				, currentLanguage);
			return result;
		}
		
		private function dispatchChange():void
		{
			dispatchEvent(new Event("change"));
		}
	}
}