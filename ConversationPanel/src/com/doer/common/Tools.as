package com.doer.common
{
	import com.doer.common.tooltip.ToolTip;
	import com.doer.config.AppConf;
	import com.doer.interfaces.IMainClass;
	import com.doer.meta.MetaCanvas;
	import com.metaedu.client.messages.nebula.NebulaPlatformType;
	
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	import spark.components.Group;
	
	import view.common.Alert;

	public class Tools
	{
		/**
		 * 添加一个tips工具
		 * @param text : tips文字
		 * @param x : 位置
		 * @param y : 位置
		 * @param context : 父容器
		 * @param delay ： 单位毫秒后消失
		 * **/
		public static function showToolTip(text:String,x:Number,y:Number,context:* = null,delay:uint = 0):ToolTip
		{
			var toolTip:ToolTip = new ToolTip();
			toolTip.invalidateText(text);
			toolTip.x = x;
			toolTip.y = y;
			
			if(context == null)
				context = (FlexGlobals.topLevelApplication as IMainClass).alertContent;
			
			context.addElement(toolTip);
			
			if(delay != 0)
			{
				setTimeout(function():void{
					
					toolTip.onDestroy();
					context.removeElement(toolTip);
					
				},delay);
			}
			
			return toolTip;
			
		}
		
		/**
		 * 移除tips
		 * **/
		public static function destroyToolTip(toolTip:ToolTip):void
		{
			toolTip.onDestroy();
			(toolTip.parent as Object).removeElement(toolTip);
		}
		
		private static var alertPanel:Alert = null;
		
		private static var onYes:Function = null;
		
		private static var onCancel:Function = null;
		
		/**
		 * 弹出框
		 * **/
		public static function alert(text:String,onYesHandler:Function = null,onCancelHandler:Function = null,isForce:Boolean = false):Alert
		{
			if(alertPanel != null)
			{
				removeAlert();
			}
			
			
			if(AppConf.platform == NebulaPlatformType.BOARD && isForce)
			{
				
				if(onYesHandler != null)
				{
					onYesHandler();
				}
				
			}else
			{
				onYes = onYesHandler;
				onCancel = onCancelHandler;
				
				alertPanel = new Alert();
				
				var context:Group = (FlexGlobals.topLevelApplication as IMainClass).alertContent;
				context.addElement(alertPanel);
				alertPanel.labelText = text;
				
				alertPanel.addEventListener(Alert.YES,removeAlert);
				alertPanel.addEventListener(Alert.CANCEL,removeAlert);
				
			}

			return alertPanel;
			
		}
	
		/***
		 * 移除弹出框
		 * */
		public static function removeAlert(e:Event = null):void
		{
			if(e != null)
			{
				if(e.type == Alert.YES && onYes != null)
					onYes();
				
				if(e.type == Alert.CANCEL && onCancel != null)
					onCancel();
					
			}
			
			if(alertPanel != null)
			{
				alertPanel.removeEventListener(Alert.YES,removeAlert);
				alertPanel.removeEventListener(Alert.CANCEL,removeAlert);
				
				var context:Group = (FlexGlobals.topLevelApplication as IMainClass).alertContent;
				context.removeElement(alertPanel);
				
				alertPanel = null;
			}
			
			onYes = null;
			onCancel = null;
		}
		
	}
}