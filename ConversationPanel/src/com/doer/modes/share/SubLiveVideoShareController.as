package com.doer.modes.share
{
	import com.doer.config.ComplexConf;
	import com.doer.config.ModeTypes;
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.modes.live.LiveController;
	import com.doer.modes.live.tools.LiveVideoInfo;
	import com.doer.modes.live.video.LiveVideoRender;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ClientComplexLiveCtrl;
	import com.metaedu.client.messages.nebula.NebulaScreenType;
	import com.metaedu.client.messages.nebula.ServerComplexEnterResp;
	import com.metaedu.client.messages.nebula.ServerComplexLiveCtrlInform;
	import com.metaedu.client.messages.nebula.complex.LiveContainer;
	
	import flash.utils.setTimeout;
	
	import spark.components.Group;
	
	import view.modes.share.LiveVideoShareView;
	
	public class SubLiveVideoShareController extends LiveVideoShareController
	{
		public function SubLiveVideoShareController(metaManager:MetaManager, modeId:int, container:Group=null)
		{
			super(metaManager, modeId, container);
			
			this.screenIndex = 2;
			
		}		
	}
}