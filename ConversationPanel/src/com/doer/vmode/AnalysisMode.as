package com.doer.vmode
{
	import com.doer.config.AppConf;
	import com.doer.config.ComplexConf;
	import com.metaedu.client.messages.nebula.ServerComplexEnterResp;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class AnalysisMode extends EventDispatcher
	{
		private var urlLoad:URLLoader = null;
		
		public var datas:Array = null;
		
		public var loginInfo:ServerComplexEnterResp = null;
		
		public function loadData():void
		{
			urlLoad = new URLLoader();
			
			var url:URLRequest = new URLRequest();
			url.url = "http://" + AppConf.webAddr + "/lesson/record-data/" + ComplexConf.complexId + ".htm";
			
			urlLoad.load(url);
			urlLoad.addEventListener(Event.COMPLETE,onLoadComplete);
			
		}
		
		private function onLoadComplete(e:Event):void
		{
			
			datas = new Array();
			
			var arr:Array = (urlLoad.data as String).split("|");
			
			for(var i:int = 0; i < arr.length; i ++)
			{
				var str:String = arr[i];
				
				var numStr:String = str.substr(0,str.indexOf("{"));
				
				var jsonStr:String = str.substr(str.indexOf("{"),str.length);
				
				var timeStr:String = numStr.substr(0,6);
				var typeStr:String = numStr.substr(6,numStr.length);
				
				var time:Number = Number(timeStr);
				var type:Number = Number(typeStr);
			
				var obj:Object = {time : time * 1000, type : type, data : jsonStr,index : i};
				
				datas.push(obj);
				
			}
			
			loginInfo = JsonUtils.convertJsonToClass(datas[0].data,ServerComplexEnterResp);
			
			dispatchEvent(new Event(Event.COMPLETE));
			
		}
		
		/**
		 * 获取总时长
		 * **/
		public function getTotalTime():Number
		{
			return datas[datas.length - 1].time - datas[0].time;
		}
		
		
		
	}
}