package com.doer.modes.media
{
	import com.doer.config.ComplexConf;
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.NebulaScreenType;
	
	import spark.components.Group;
	
	import view.modes.media.MediaView;
	
	public class SubMediaController extends MediaController
	{
		public function SubMediaController(metaManager:MetaManager, modeId:int, container:Group=null,toolContainer:Group = null)
		{
			isSecondScreen = true;
			
			super(metaManager, modeId, container,toolContainer);
		}
		
	}
}