package com.doer.vmode.filter
{
	public class IndexAnalysisFilter extends AnalysisFilter
	{
		public function IndexAnalysisFilter(messageType:int)
		{
			super(messageType);
		}
		
		/**
		 * 过滤消息
		 * **/
		override public function filt(message:Array):Array
		{
			var tmp1:Object = null;
			var tmp2:Object = null;
			
			var arr:Array = new Array();
			
			for(var i:int = 0; i < message.length; i ++)
			{
				var isInChain:Boolean = false;
				
				if(message[i].type == messageType)
				{
					var data:Object = JSON.parse(message[i].data);
					
					if(data.index == 1)
					{
						tmp1 = message[i];
					}else
					{
						tmp2 = message[i];
					}
					
					isInChain = true;
					
				}
				
				if(!isInChain)
					arr.push(message[i]);
				
			}
			
			if(tmp1 != null)
				arr.push(tmp1);
			
			if(tmp2 != null)
				arr.push(tmp2);
			
			arr.sortOn("time");
			
			
			
			return arr;
		}
		
	}
}