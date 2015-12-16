package com.doer.modes.nav
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class NavToolConf extends EventDispatcher
	{
		/**
		 * 小号
		 * **/
		public static const SIZE_1:Number = 1;
		
		/**
		 * 中号
		 * **/
		public static const SIZE_2:Number = 2;
		
		/**
		 * 大号
		 * **/
		public static const SIZE_3:Number = 3;
		
		/**
		 * 颜色1
		 * **/
		public static const COLOR_1:uint = 0xffffff;
		
		/**
		 * 颜色2
		 * **/
		public static const COLOR_2:uint = 0x000000;
		
		/**
		 * 颜色3
		 * **/
		public static const COLOR_3:uint = 0xff0000;
		
		/**
		 * 画笔工具
		 * **/
		public static const TOOL_PEN:String = "tool_pen";
		
		/**
		 * 橡皮工具
		 * **/
		public static const TOOL_ERASER:String = "tool_eraser";
		
		/**
		 * 文字工具
		 * **/
		public static const TOOL_TEXT:String = "tool_text";
		
		/**
		 * 拖拽工具
		 * **/
		public static const TOOL_HAND:String = "tool_hand";
		
		/**
		 * 主屏画笔颜色
		 * **/
		public  var mainPenColor:uint = COLOR_2;
		
		/**
		 * 主屏画笔size
		 * **/
		public  var mainPenSize:int = SIZE_2;
		
		/**
		 * 主屏橡皮粗细
		 * **/
		public  var mainEraserSize:int = SIZE_2;
		
		/**
		 * 主屏文字颜色
		 * **/
		public  var mainTextColor:uint = COLOR_2;
		
		/**
		 * 主屏文字size
		 * **/
		public  var mainTextSize:int = SIZE_2;
		
		/**
		 * 主屏工具
		 * **/
		public  var mainTool:String = TOOL_HAND;
		
		/**
		 * 辅屏画笔颜色
		 * **/
		public  var subPenColor:uint = COLOR_2;
		
		/**
		 * 辅屏画笔size
		 * **/
		public  var subPenSize:int = SIZE_2;
		
		/**
		 * 辅屏橡皮size
		 * **/
		public  var subEraserSize:int = SIZE_2;
		
		/**
		 * 辅屏文字颜色
		 * **/
		public  var subTextColor:uint = COLOR_2;
		
		/**
		 * 辅屏文字size
		 * **/
		public  var subTextSize:int = SIZE_2;
		
		/**
		 * 辅屏工具
		 * **/
		public  var subTool:String = TOOL_HAND;
		
		private var _isSynTools:Boolean = false;
		
		private static var instance:NavToolConf = null;
		
		/**
		 * 是否强制主辅屏工具一致
		 * **/
		public function get isSynTools():Boolean
		{
			return _isSynTools;
		}

		/**
		 * @private
		 */
		public function set isSynTools(value:Boolean):void
		{
			_isSynTools = value;
			
			if(value)
			{
				setValueSyn(false);
				
				dispatchEvent(new Event("toolChange"));
				dispatchEvent(new Event("colorChange"));
				dispatchEvent(new Event("sizeChange"));
			}
			
		}

		public static function getInstance():NavToolConf
		{
			if(instance == null)
				instance = new NavToolConf();
			
			return instance;
		}
		
		public function reset():void
		{
			mainTool = TOOL_HAND;
			mainEraserSize = SIZE_1;
			mainPenColor = COLOR_1;
			mainPenSize = SIZE_1;
			mainTextColor = COLOR_1;
			mainTextSize = SIZE_1;
			
			subTool = TOOL_HAND;
			subEraserSize = SIZE_1;
			subPenColor = COLOR_1;
			subPenSize = SIZE_1;
			subTextColor = COLOR_1;
			subTextSize = SIZE_1;
			
			dispatchEvent(new Event("toolChange"));
			dispatchEvent(new Event("colorChange"));
			dispatchEvent(new Event("sizeChange"));
		}
		
		/**
		 * 设置属性同步
		 * **/
		private function setValueSyn(isSubScreen:Boolean):void
		{
			if(!isSubScreen)
			{
				subTool = mainTool;
				subPenColor = mainPenColor;
				subPenSize = mainPenSize;
				subEraserSize = mainEraserSize;
				subTextColor = mainTextColor;
				subTextSize = mainTextSize;
				
			}else
			{
				mainTool = subTool;
				mainPenColor = subPenColor;
				mainPenSize = subPenSize;
				mainEraserSize = subEraserSize;
				mainTextColor = subTextColor;
				mainTextSize = subTextSize;
			}
			
		}
		
		/**
		 * 获取工具是否被选中
		 * **/
		[Bindable("toolChange")]
		public function getToolSelected(toolName:String,isSubScreen:Boolean):Boolean
		{
			if(isSubScreen)
				return subTool == toolName;
			
			return mainTool == toolName;
		}
		
		/**
		 * 获取颜色工具是否被选中
		 * **/
		[Bindable("colorChange")]
		public function getColorToolSelected(toolName:String,isSubScreen:Boolean):Boolean
		{
			
			if(isSubScreen)
			{
				if(subTool == TOOL_PEN)
					return subPenColor == NavToolConf[toolName];
				else if(subTool == TOOL_TEXT)
					return subTextColor == NavToolConf[toolName];
					
			}else
			{
				if(mainTool == TOOL_PEN)
					return mainPenColor == NavToolConf[toolName];
				else if(mainTool == TOOL_TEXT)
					return mainTextColor == NavToolConf[toolName];
			}
			
			return false;
		}
		
		/**
		 * 获取size工具是否被选中
		 * **/
		[Bindable("sizeChange")]
		public function getSizeToolSelected(toolName:String,isSubScreen:Boolean):Boolean
		{
			if(!isSubScreen)
			{
				if(mainTool == TOOL_PEN)
					return mainPenSize == NavToolConf[toolName];
				else if(mainTool == TOOL_TEXT)
					return mainTextSize == NavToolConf[toolName];
				else if(mainTool == TOOL_ERASER)
					return mainEraserSize == NavToolConf[toolName];
			}else
			{
				if(subTool == TOOL_PEN)
					return subPenSize == NavToolConf[toolName];
				else if(subTool == TOOL_TEXT)
					return subTextSize == NavToolConf[toolName];
				else if(subTool == TOOL_ERASER)
					return subEraserSize == NavToolConf[toolName];
			}
			
			return false;
		}
		
		/**
		 * 设置工具
		 * **/
		public  function setTool(name:String,selected:Boolean,isSubScreen:Boolean):void
		{
			if(isSubScreen)
			{
				if(!selected)
					subTool = name;
				else
					subTool = TOOL_HAND;
			}else
			{
				if(!selected)
					mainTool = name;
				else
					mainTool = TOOL_HAND;
			}
			
			if(isSynTools)
			{
				setValueSyn(isSubScreen);
			}
			
			dispatchEvent(new Event("toolChange"));
			dispatchEvent(new Event("colorChange"));
			dispatchEvent(new Event("sizeChange"));
		}
		
		/**
		 * 设置颜色工具
		 * **/
		public  function setColorTool(name:String,isSubScreen:Boolean):void
		{
			if(isSubScreen)
			{
				if(subTool == TOOL_PEN)
					subPenColor = NavToolConf[name];
				else if(subTool == TOOL_TEXT)
					subTextColor = NavToolConf[name];
				
			}else
			{
				if(mainTool == TOOL_PEN)
					mainPenColor = NavToolConf[name];
				else if(mainTool == TOOL_TEXT)
					mainTextColor = NavToolConf[name];
			}
			
			if(isSynTools)
			{
				setValueSyn(isSubScreen);
			}
			
			dispatchEvent(new Event("colorChange"));
		}
		
		/**
		 * 设置size工具
		 * **/
		public  function setSizeTool(name:String,isSubScreen:Boolean):void
		{
			if(isSubScreen)
			{
				if(subTool == TOOL_PEN)
					subPenSize = NavToolConf[name];
				else if(subTool == TOOL_TEXT)
					subTextSize = NavToolConf[name];
				else if(subTool == TOOL_ERASER)
					subEraserSize = NavToolConf[name];
				
			}else
			{
				if(mainTool == TOOL_PEN)
					mainPenSize = NavToolConf[name];
				else if(mainTool == TOOL_TEXT)
					mainTextSize = NavToolConf[name];
				else if(mainTool == TOOL_ERASER)
					mainEraserSize = NavToolConf[name];
			}
			
			if(isSynTools)
			{
				setValueSyn(isSubScreen);
			}
			
			dispatchEvent(new Event("sizeChange"));
			
		}
		
		/**
		 * 获取文字大小
		 * **/
		public  function getTextSize(isSub:Boolean):Number
		{
			var size:int = isSub ? subTextSize : mainTextSize;
			
			if(size == SIZE_1)
				return 40;
			else if(size == SIZE_2)
				return 60;
			
			return 80;
		}
		
		/**
		 * 获取橡皮粗细
		 * **/
		public  function getEraserSize(isSub:Boolean):Number
		{
			var size:int = isSub ? subEraserSize : mainEraserSize;
			
			if(size == SIZE_1)
				return 40;
			else if(size == SIZE_2)
				return 80;
			
			return 150;
		}
		
		/**
		 * 获取画笔粗细
		 * **/
		public  function getPenSize(isSub:Boolean):Number
		{
			var size:int = isSub ? subPenSize : mainPenSize;
			
			if(size == SIZE_1)
				return 2;
			else if(size == SIZE_2)
				return 4;
			
			return 8;
		}
		
	}
}


