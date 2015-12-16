package com.doer.modes.skydrive
{
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	
	import flash.utils.setTimeout;
	
	import spark.components.Group;
	
	import view.modes.skydrive.SkyDriveView;
	
	public class SubSkyDriveController extends SkyDriveController
	{
		public function SubSkyDriveController(metaManager:MetaManager, modeId:int, container:Group=null)
		{
			isSecondScreen = true;
			
			super(metaManager, modeId, container);
			
			registCommand(LocalCommandType.CMD_SKYDRIVE_REFRESH);
		}
		
		override public function onCommand(cmd:LocalCommand):void
		{
			if(cmd.command == LocalCommandType.CMD_SKYDRIVE_REFRESH)
			{
				if(modeView != null)
				{
					(modeView as SkyDriveView).refreshUsedContent();
				}
			}
		}
		
		override public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
			
		}
		
		override public function registView():IView
		{
			var v:SkyDriveView = new SkyDriveView();
			
			v.x = container.width / 2 - v.width/2;
			v.y = container.height / 2 - v.height/2;
			v.isSecondScreen = true;
			
			return v;
		}
		
	}
}