package com.doer.modes.abstrack
{
	import com.doer.interfaces.ICommand;
	import com.doer.interfaces.IController;
	import com.doer.interfaces.ISProcessor;
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandEvent;
	import com.metaedu.client.messages.nebula.ServerPassiveOutInform;
	
	import flash.display.DisplayObject;
	import flash.utils.setTimeout;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	public class AbstrackController implements IController,ICommand,ISProcessor
	{
		/**
		 * 模块id
		 * **/
		private var _modeId:int = -1;
		
		/**
		 * 该模块持有的view
		 * **/
		private var _modeView:IView = null;
		
		/**
		 * 该controller注册的command
		 * **/
		private var commands:Array = null;
		
		/**
		 * 管理类引用
		 * **/
		public var metaManager:MetaManager = null;
		
		/**
		 * 容器
		 * **/
		public var container:Group = null;
		
		
		/**
		 * @param metaManager : 管理类引用
		 * @param modeId ： 模块id
		 * @param container ： 容器
		 * **/
		public function AbstrackController(metaManager:MetaManager,modeId:int,container:Group = null)
		{
			
			this.container = container;
			this._modeId = modeId;
			this.metaManager = metaManager;
			this.commands = new Array();
		}
		
		public function get resident():Boolean
		{
			return false;
		}

		public final function get modeId():int
		{
			return _modeId;
		}
		
		public final function get modeView():IView
		{
			return _modeView;
		}
		
		public final function set modeView(value:IView):void
		{
			_modeView = value;
		}
		
		public final function removeView():void
		{
			if(modeView != null)
			{
				if((modeView as IVisualElement).hasEventListener(FlexEvent.CREATION_COMPLETE))
					(modeView as IVisualElement).removeEventListener(FlexEvent.CREATION_COMPLETE,onCreateComplete);
				
				modeView.onDestroy();
				
				var mv:IVisualElement = modeView as IVisualElement;
				
				container.removeElement(mv);
				
				modeView = null;
			}
		}
		
		public final function addView():void
		{
			if(modeView == null)
			{
				modeView = registView();
				
				modeView.controller = this;
				
				var mv:IVisualElement = modeView as IVisualElement;
				mv.addEventListener(FlexEvent.CREATION_COMPLETE,onCreateComplete);
				
				container.addElement(mv);
				
			}
			
		}
		
		public function reset():void
		{
			
		}
		
		protected function onCreateComplete(e:FlexEvent):void
		{
			(modeView as IVisualElement).removeEventListener(FlexEvent.CREATION_COMPLETE,onCreateComplete);
			
			modeView.invalidate();
			
		}
		
		public final function sendCommand(cmd:LocalCommand):void
		{
			metaManager.dispatchEvent(new LocalCommandEvent(cmd.command,cmd.data));
		}
		
		public final function registCommand(command:String):void
		{
			metaManager.addEventListener(command,onMetaEvent);
			
			commands.push(command);
			
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
			if(metaManager.hasEventListener(command))
				metaManager.removeEventListener(command,onMetaEvent);
		}
		
		public function registView():IView
		{
			return null;
		}
		
		public function onDestroy():void
		{
//			for(var i:int = 0; i < commands.length; i ++)
//			{
//				metaManager.removeEventListener(commands[i],onMetaEvent);
//			}
			
			if(container != null && modeView != null)
			removeView();
			
			this.commands = null;
			this.metaManager = null;
			this.container = null;
			
			
		}
		
		public function onCommand(cmd:LocalCommand):void
		{
			
		}
		
		public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
			
		}
		
		public function signOutPassive(refMsg:ServerPassiveOutInform):void
		{
			
		}
		
		
		
	}
}