package com.doer.modes.blackbord
{
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	
	import spark.components.Group;
	
	import view.modes.blackbord.BlackbordView;
	
	public class SubBlackBordController extends BlackbordController
	{
		public function SubBlackBordController(manager:MetaManager, modeId:int, container:Group)
		{
			super(manager, modeId, container);
			
			delegation.isSecondScreen = true;
			
		}
		
	}
}