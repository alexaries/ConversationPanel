package com.doer.modes.syn
{
	import com.doer.manager.MetaManager;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ClientComplexDesktopCtrl;
	import com.metaedu.client.messages.nebula.ClientComplexDesktopPublish;
	
	import spark.components.Group;
	
	public class SubSynDesktopController extends SynDesktopController
	{
		public function SubSynDesktopController(metaManager:MetaManager, modeId:int, container:Group=null)
		{
			super(metaManager, modeId, container);
		}
	
	}
}