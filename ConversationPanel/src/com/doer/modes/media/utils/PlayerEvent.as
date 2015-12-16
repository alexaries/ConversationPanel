package com.doer.modes.media.utils
{
	import flash.events.Event;
	
	public class PlayerEvent extends Event
	{
		public var param:Object = null;
		
		public function PlayerEvent(type:String,param:Object = null)
		{
			
			this.param = param;
			
			super(type, false, false);
		}
	}
}