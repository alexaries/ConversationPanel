package com.doer.common.mouse
{
	import flash.display.Bitmap;
	import flash.geom.Point;
	
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;
	import com.doer.common.interfaces.IMouseStyle;

	public class MouseFactory
	{
		private static var instance:MouseFactory = null;
		
		private var mouseClass:Object = new Object();
		
		private var curMouse:String = null;
		
		public var mouseStyle:IMouseStyle = null;
		
		public static function getInstance():MouseFactory
		{
			if(instance == null)
				instance = new MouseFactory(new Inner());
			
			return instance;
		}
		
		public function MouseFactory(inner:Inner)
		{
		}
		
		/**
		 * 注册鼠标
		 * @param icon ： 图标
		 * @param name ： 鼠标标示
		 * @param point ： 鼠标注册点
		 * **/
		public function regist(icon:Class,name:String):void
		{
			mouseClass[name] = icon;
		}
		
		/**
		 * 移除鼠标
		 * **/
		public function remove(name:String):void
		{
			mouseClass[name] = null;
		}
		
		/**
		 * 显示鼠标
		 * **/
		public function show(name:String,w:Number = 0,h:Number = 0,point:Point = null):void
		{
			var data:Class = mouseClass[name];
			
			if(data != null && curMouse == null)
			{
				curMouse = name;
				
				if(w == 0 && h == 0)
				{
					if(point == null)
						CursorManager.setCursor(data,CursorManagerPriority.HIGH);
					else
						CursorManager.setCursor(data,CursorManagerPriority.HIGH,point.x,point.y);
				}
					
				else
				{
					if(point == null)
						CursorManager.setCursor(data,CursorManagerPriority.HIGH);
					else
						CursorManager.setCursor(data,CursorManagerPriority.HIGH,point.x,point.y);
					
					mouseStyle.setSize(w,h);
				}

			}
				
		}
		
		/**
		 * 隐藏当前正在显示的鼠标
		 * **/
		public function hide():void
		{
			curMouse = null;
			
			mouseStyle = null;
			
			CursorManager.removeAllCursors();
		}
		
		
	}
}

class Inner{}