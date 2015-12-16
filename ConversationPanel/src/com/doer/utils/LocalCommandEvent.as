package com.doer.utils
{
	import flash.events.Event;
	
	public class LocalCommandEvent extends Event
	{
		public var param:Object = null;
		
		public function LocalCommandEvent(type:String,param:Object)
		{
			this.param = param;
			
			super(type, false, false);
		}
	}
}