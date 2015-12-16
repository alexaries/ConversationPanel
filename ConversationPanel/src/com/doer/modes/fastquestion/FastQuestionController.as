package com.doer.modes.fastquestion
{
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.utils.LocalCommand;
	
	import spark.components.Group;
	
	import view.modes.fastquestion.FastQuestionView;
	
	public class FastQuestionController extends AbstrackController
	{
		public function FastQuestionController(metaManager:MetaManager, modeId:int,container:Group = null)
		{
			super(metaManager, modeId, container);
		}
		
	
		override public function registView():IView
		{
			return new FastQuestionView();
		}
		
		
		override public function onCommand(cmd:LocalCommand):void
		{
			
		}
		
		
		
	}
}