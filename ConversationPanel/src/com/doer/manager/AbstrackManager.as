package com.doer.manager
{
	import com.doer.config.ComplexConf;
	import com.doer.config.ModeTypes;
	import com.doer.interfaces.ICommand;
	import com.doer.interfaces.IController;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandEvent;
	import com.doer.utils.LocalCommandType;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import flashx.textLayout.events.ModelChange;
	
	import mx.containers.ControlBar;
	import mx.core.IVisualElement;
	
	import view.ConversationPanel;
	
	public class AbstrackManager extends EventDispatcher implements ICommand
	{
		/**
		 * 主类引用
		 * **/
		public var mainClass:ConversationPanel = null;
		
		/**
		 * 所有模块容器
		 * **/
		public var controllers:Vector.<AbstrackController> = new Vector.<AbstrackController>();
		
		public function AbstrackManager(mainClass:ConversationPanel)
		{
			this.mainClass = mainClass;
			
			onInvalidateChildren(); //注册模块
			
		}
	
		/**
		 * 开始初始化
		 * **/
		protected function onInvalidateChildren():void
		{
			
		}
		
		/**
		 * 注册子模块控制器
		 * **/
		protected final function regist(controller:AbstrackController):void
		{
			controllers.push(controller);
		}
		
		/**
		 * 根据id获取子模块
		 * **/
		public function getControllerById(id:int):AbstrackController
		{
			for(var i:int = 0; i < controllers.length; i ++)
			{
				if(controllers[i].modeId == id)
					return controllers[i];
			}
			
			return null;
		}
		
		/**
		 * 移除并销毁模块
		 * **/
		public function removeControllerById(id:int):void
		{
			for(var i:int = 0; i < controllers.length; i ++)
			{
				if(controllers[i].modeId == id)
				{
					
					controllers[i].onDestroy();
					controllers.splice(i,1);
					
					break;
				}
			}
		}
		
		public function onCommand(cmd:LocalCommand):void
		{
		}
		
		public final function sendCommand(cmd:LocalCommand):void
		{
			dispatchEvent(new LocalCommandEvent(cmd.command,cmd.data));
		}
		
		public final function registCommand(command:String):void
		{
			addEventListener(command,onMetaEvent);
		}
		
		/**
		 * command事件
		 * **/
		protected final function onMetaEvent(e:LocalCommandEvent):void
		{
			onCommand(new LocalCommand(e.type,e.param));
		}
		
		public final function removeCommand(command:String):void
		{
			if(hasEventListener(command))
				removeEventListener(command,onMetaEvent);
		}
		
		public function onDestroy():void
		{
			
			ComplexConf.commander = null;
			ComplexConf.activeScreen = -1;
			ComplexConf.subActiveScreen = -1;
			
			ComplexConf.participantType = -1;
			
			for each(var controller:AbstrackController in controllers)
			{
				controller.onDestroy();
			}
			
			controllers = null;
			
			
		}
		
	}
}