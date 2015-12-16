package com.doer.modes.skydrive.files
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public class FileDataLoader extends URLLoader
	{
		
		private var callBack:Function = null;
		
		private var targetId:String = null;
		
		public function FileDataLoader(request:URLRequest=null)
		{
			super(request);
		}
		
		/**
		 * 加载数据get
		 * **/
		public function loadByGet(url:String,ascookie:String,callBack:Function,targetId:String = null):void
		{
			this.callBack = callBack;
			this.targetId = targetId;
			
			var header:URLRequestHeader = new URLRequestHeader("ascookie",ascookie);
			
			var request:URLRequest = new URLRequest();
			request.requestHeaders.push(header);
			request.url = url;
			
			load(request);
			
			addEventListener(Event.COMPLETE,onLoadComplete);
		}
		
		/**
		 * post方式加载数据
		 * ***/
		public function loadByPost(url:String,ascookie:String,value:URLVariables,callBack:Function,targetId:String = null):void
		{
			this.callBack = callBack;
			this.targetId = targetId;
			
			var header:URLRequestHeader = new URLRequestHeader("ascookie",ascookie);
			
			var request:URLRequest = new URLRequest();
			request.requestHeaders.push(header);
			request.url = url;
			request.data = value;
			request.method = URLRequestMethod.POST;
			
			load(request);
			
			addEventListener(Event.COMPLETE,onLoadComplete);
		}
		
		private function onLoadComplete(e:Event):void
		{
			try
			{
				callBack(JSON.parse(this.data),targetId);
				
			} 
			catch(error:Error) 
			{
				trace(error,this.data)
			}
			
			removeEventListener(Event.COMPLETE,onLoadComplete);
			
			callBack = null;
		}
		
	}
}