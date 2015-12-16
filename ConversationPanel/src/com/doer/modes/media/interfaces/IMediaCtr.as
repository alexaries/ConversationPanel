package com.doer.modes.media.interfaces
{
	public interface IMediaCtr
	{
		/**
		 * 播放时间
		 * **/
		function onMediaTime(time:Number,duration:Number):void
			
		/**
		 * 播放完成
		 * **/
		function onComplete():void
	}
}