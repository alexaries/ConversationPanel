package com.doer.modes.tools
{
	import com.doer.config.AppConf;
	import com.doer.config.ComplexConf;
	import com.doer.config.ModeTypes;
	import com.doer.manager.MetaManager;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.modes.live.LiveController;
	import com.doer.modes.live.tools.LiveVideoInfo;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.utils.setTimeout;
	
	import mx.events.ResizeEvent;
	
	import spark.components.Group;
	
	import view.modes.share.LiveShareTool;
	import view.modes.tools.media.MinMediaTool;
	import view.modes.tools.setter.LiveSetter;
	
	public class ToolController extends AbstrackController
	{
		public var cNames:Array = null;
		
		public var mNames:Array = null;
		
		public function ToolController(metaManager:MetaManager, modeId:int, container:Group=null)
		{
			super(metaManager, modeId, container);
			
			invalidateCommands();
			
			container.addEventListener(ResizeEvent.RESIZE,onParentResize);
			
			cNames = new Array();
			
			for(var i:int = 0; i < Camera.names.length; i ++)
			{
				if(Camera.names[i] != AppConf.vituralCameraName)
					cNames.push({label : i == 0 ? "视频设备" : "视频设备(" + i + ")" , index : i});
			}
			
			mNames = new Array();
			
			for(i = 0; i < Microphone.names.length; i ++)
			{
				mNames.push(i == 0 ? "音频设备" : "音频设备(" + i + ")");
			}
			
			
		}
		
		override public function reset():void
		{
			if(setterView != null)
				removeSetterView();
		}
		
		private function onParentResize(e:ResizeEvent):void
		{
			if(setterView != null)
			{
				if(!ComplexConf.isClipScreen)
					setterView.x = container.width / 2 - setterView.width / 2;
				else
					setterView.x = container.width / 4 - setterView.width / 2;
			}
		}
		
		private function invalidateCommands():void
		{
			registCommand(LocalCommandType.CMD_NAV_SET);
			
		}
		
		override public function onCommand(cmd:LocalCommand):void
		{
			if(cmd.command == LocalCommandType.CMD_NAV_SET)
			{
				if(cmd.data.selected)
				{
					addSetterView();
				}else
				{
					removeSetterView();
				}
			}
		}
		
		private var setterView:LiveSetter = null;
		
		/**
		 * 添加设置view
		 * **/
		private function addSetterView():void
		{
			setterView = new LiveSetter();
			
			setterView.controller = this;
			
			if(!ComplexConf.isClipScreen)
				setterView.x = container.width / 2 - setterView.width / 2;
			else
				setterView.x = container.width / 4 - setterView.width / 2;
			
			setterView.y = container.height / 2 - setterView.height / 2;
			
			container.addElement(setterView);
			
			setterView.invalidate();
			
		}
		
		/**
		 * 移除设置view
		 * **/
		private function removeSetterView():void
		{
			setterView.onDestroy();
			container.removeElement(setterView);
			
			setterView = null;
		}
		
		/**
		 * 设置修改
		 * **/
		public function onRefreshSetterValue():void
		{
			sendCommand(new LocalCommand(LocalCommandType.CMD_SETTER_CHANGE));
		}
		
		/**
		 * 视频状态修改
		 * **/
		public function onRefreshVideo1Value():void
		{
			sendCommand(new LocalCommand(LocalCommandType.CMD_VIDEO1_CHANGE));
		}
		
		/**
		 * 视频状态修改
		 * **/
		public function onRefreshVideo2Value():void
		{
			sendCommand(new LocalCommand(LocalCommandType.CMD_VIDEO2_CHANGE));
		}
		
		/**
		 * 音频状态修改
		 * **/
		public function onRefreshAudioValue():void
		{
			sendCommand(new LocalCommand(LocalCommandType.CMD_AUDIO_CHANGE));
		}
		
		/**
		 * 关闭view
		 * **/
		public function onCloseSetterView():void
		{
			sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_SET,{selected : false}));
		}
		
		
	}
}