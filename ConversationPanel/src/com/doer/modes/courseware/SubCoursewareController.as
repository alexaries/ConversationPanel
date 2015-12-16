package com.doer.modes.courseware
{
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ClientComplexMove;
	import com.metaedu.client.messages.nebula.NebulaScreenType;
	
	import spark.components.Group;
	
	import view.modes.courseware.CoursewareView;
	
	public class SubCoursewareController extends CoursewareController
	{
		public function SubCoursewareController(metaManager:MetaManager, modeId:int, container:Group=null)
		{
			super(metaManager, modeId, container);
			
			delegation.isSecondScreen = true;
			
		}

		override public function registView():IView
		{
			var course:CoursewareView = new CoursewareView();
			course.delegation = delegation;
			
			return course;
		}
		
	}
}