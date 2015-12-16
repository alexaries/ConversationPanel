package com.doer.config
{
	public class ScreenParams
	{
		/**
		 * 单屏幕靠左
		 * **/
		public static const SCREEN_SINGLE_LEFT:String = "SCREEN_SINGLE_LEFT";
		
		/**
		 * 单屏幕靠右
		 * **/
		public static const SCREEN_SINGLE_RIGHT:String = "SCREEN_SINGLE_RIGHT";
		
		/**
		 * 双屏幕靠左
		 * **/
		public static const SCREEN_DOUBLE_LEFT:String = "SCREEN_DOUBLE_LEFT";
		
		/**
		 * 双屏幕居中
		 * **/
		public static const SCREEN_DOUBLE_MIDDLE:String = "SCREEN_DOUBLE_MIDDLE";
		
		
		/**
		 * 双屏幕靠右
		 * **/
		public static const SCREEN_DOUBLE_RIGHT:String = "SCREEN_DOUBLE_RIGHT";
		
		/**
		 * 屏幕宽度
		 * **/
		public var screenWidth:int = 0;
		
		/**
		 * 屏幕高度
		 * **/
		public var screenHeight:int = 0;
		
		public function ScreenParams(screenWidth:Number,screenHeight:Number)
		{
			this.screenWidth = screenWidth;
			this.screenHeight = screenHeight;
		}
		
		public function toString():String
		{
			return screenWidth + "*" + screenHeight;
		}
		
	}
}