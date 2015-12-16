package com.doer.utils
{
	import flash.events.Event;

	public class LocalEvent extends Event
	{
		public var param:Object = null;
		
		public function LocalEvent(type:String,param:Object)
		{
			this.param = param;
			
			super(type);
		}
	}
}