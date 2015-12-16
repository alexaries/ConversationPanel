package com.doer.modes.media.interfaces
{
	public interface IPlayer
	{
		
		/**
		 * 当前多媒体正在播放的时间
		 * **/
		function get time():Number
		
		/**
		 * 当前多媒体的总时长
		 * **/
		function get duration():Number
		
		/**
		 * 获取播放器状态
		 * */
		function get ctrType():int
		
		/**
		 * 准备播放器
		 * **/
		function readyMedia(sevName:String,fileName:String,id:String,suffix:String,name:String,detail:String):void
			
		/**
		 * 恢复播放
		 * **/
		function resume():void
			
		/**
		 * 暂停
		 * **/
		function pause():void
			
		/**
		 * 停止播放
		 * **/
		function stop():void
			
		/**
		 * 设置播放时间
		 * **/
		function seek(time:Number):void
			
		/**
		 * 销毁资源
		 * **/
		function onDestroy():void
	}
}