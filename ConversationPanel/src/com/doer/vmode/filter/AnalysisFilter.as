package com.doer.vmode.filter
{
	/**
	 * 消息过滤器基类
	 * **/
	public class AnalysisFilter
	{
		
		/**
		 * 过滤的消息类型
		 * **/
		public var messageType:int = 0;
		
		
		public function AnalysisFilter(messageType:int)
		{
			this.messageType = messageType;
		}
		
		
		/**
		 * 过滤消息
		 * **/
		public function filt(message:Array):Array
		{
			var tmp:Object = null;
			
			var arr:Array = new Array();
			
			for(var i:int = 0; i < message.length; i ++)
			{
				var isInChain:Boolean = false;
				
				if(message[i].type == messageType)
				{
					tmp = message[i];
					
					isInChain = true;
					
				}
				
				if(!isInChain)
					arr.push(message[i]);
				
			}
			
			if(tmp != null)
				arr.push(tmp);
			
			arr = bubbleSort(arr);
			
			return arr;
		}
		
		/**
		 * 排序
		 * **/
		private function bubbleSort(arr:Array):Array
		{
			for(var i:int = 0; i < arr.length; i++)
			{
				for(var j:int = i + 1; j < arr.length; j++)
				{
					if(arr[i].index > arr[j].index)
					{
						var tmp:Object = arr[j];
						arr[j] = arr[i];
						arr[i] = tmp;
					}
				}
			}
			return arr;
		}
		
	}
}