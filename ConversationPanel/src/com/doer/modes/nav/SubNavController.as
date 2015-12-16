package com.doer.modes.nav
{
	import com.doer.common.Tools;
	import com.doer.config.ComplexConf;
	import com.doer.config.ModeTypes;
	import com.doer.manager.MetaManager;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.NebulaParticipantType;
	import com.metaedu.client.messages.nebula.NebulaScreenType;
	
	import flash.events.MouseEvent;
	
	import spark.components.Group;
	
	import view.common.buttons.NavButton;
	import view.modes.nav.sub.SubNavContent;
	
	public class SubNavController extends AbstrackController
	{
		/**
		 * view
		 * **/
		public var subNavContent:SubNavContent = null;
		
		public function SubNavController(metaManager:MetaManager, modeId:int, container:Group=null,subNavContent:SubNavContent = null)
		{
			this.subNavContent = subNavContent;
			this.subNavContent.controller = this;
			
			this.modeView = subNavContent;
			
			super(metaManager, modeId, container);
			
			subNavContent.addEventListener(MouseEvent.CLICK,onNavButtonHandler);
			
			invalidateCommands();
		}
		
		private function invalidateCommands():void
		{
			registCommand(LocalCommandType.CMD_NAV_BLACKBORD);
			registCommand(LocalCommandType.CMD_NAV_PEN);
			registCommand(LocalCommandType.CMD_NAV_HAND);
			registCommand(LocalCommandType.CMD_NAV_ERASER);
			registCommand(LocalCommandType.CMD_NAV_TEXT);
			registCommand(LocalCommandType.CMD_SUBACTIVITESCREEN_CHANGE);
			registCommand(LocalCommandType.CMD_NAV_VIDEO_SHARE);
			
		}
		
		private function onNavButtonHandler(e:MouseEvent):void
		{
			
			if(e.target is NavButton && e.target.groupName == "unique")
			{
				e.target.selected = !e.target.selected;
			}
			
			if(e.target is NavButton && e.target.groupName == "tools")
			{
				NavToolConf.getInstance().setTool(e.target.name,e.target.selected,true);
			}
			
			if(e.target is NavButton && e.target.groupName == "color")
			{
				NavToolConf.getInstance().setColorTool(e.target.name,true);
			}
			
			if(e.target is NavButton && e.target.groupName == "size")
			{
				NavToolConf.getInstance().setSizeTool(e.target.name,true);
			}
			
			if(e.target == subNavContent.toolGroup.btnPen)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_PEN,{selected : e.target.selected,isSub:true})); //画笔1
			}
			else if(e.target == subNavContent.toolGroup.btnHand)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_HAND,{selected : e.target.selected,isSub:true})); //拖地
			}
			else if(e.target == subNavContent.toolGroup.btnEraser)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_ERASER,{selected : e.target.selected,isSub:true})); //橡皮
			}
			else if(e.target == subNavContent.toolGroup.btnClear)
			{
				Tools.alert("是否清除绘图？",function():void{
					
					sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_CLEAR,{selected : e.target.selected,isSub:true}));  //清空
					
				});
				
				
			}
			else if(e.target == subNavContent.toolGroup.btnText)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_TEXT,{selected : e.target.selected,isSub:true}));   //文字
			}
			else if(e.target == subNavContent.mainGroup.btnBlackbord)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_BLACKBORD,{id : ModeTypes.MODE_BLACKBORD_ID,selected : e.target.selected,isSub:true})); //黑板
			}
			else if(e.target == subNavContent.mainGroup.btnCourse)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_COURSE,{id : ModeTypes.MODE_COURSE_ID,selected : e.target.selected,isSub:true})); //课件
			}
			else if(e.target == subNavContent.mainGroup.btnMedia)//多媒体
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_MEDIA,{id : ModeTypes.MODE_MEDIA_ID,selected : e.target.selected,isSub:true})); //多媒体
			}
			else if(e.target == subNavContent.mainGroup.btnResource)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_RESOURCES,{id : ModeTypes.MODE_SUB_SKYDRIVE_ID,selected : e.target.selected,isSub : true})); //资源引用
			}
			else if(e.target == subNavContent.mainGroup.btnCamera)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_VIDEO_SHARE,{selected : e.target.selected,isSub:true}));
			}else if(e.target == subNavContent.mainGroup.btnSyn)
			{
				sendCommand(new LocalCommand(LocalCommandType.CMD_NAV_DESKTOP_SYN,{selected : e.target.selected, isSub : true}));
			}
			
		}
		
		override public function onCommand(cmd:LocalCommand):void
		{
			if(cmd.command == LocalCommandType.CMD_SUBACTIVITESCREEN_CHANGE)
			{
				if(ComplexConf.participantType == NebulaParticipantType.CHARGE || ComplexConf.participantType == ComplexConf.Temp_ParticipantType )
					subNavContent.setToolsEnable((ComplexConf.subActiveScreen == NebulaScreenType.BOARD || ComplexConf.subActiveScreen == NebulaScreenType.DOCUMENT));
				
				NavToolConf.getInstance().isSynTools = (ComplexConf.activeScreen == ComplexConf.subActiveScreen && ComplexConf.activeScreen == NebulaScreenType.BOARD)
					
				
			}else if(cmd.command == LocalCommandType.CMD_NAV_VIDEO_SHARE)
			{
				if(!cmd.data.selected)
				{
					subNavContent.mainGroup.btnCamera.selected = false;
				}
			}
		}
		
		override public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
			
		}
		
		
		
		
	}
}