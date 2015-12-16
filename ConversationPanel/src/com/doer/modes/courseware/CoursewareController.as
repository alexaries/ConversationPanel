package com.doer.modes.courseware
{
	import com.doer.common.Delegation;
	import com.doer.common.interfaces.IDelegate;
	import com.doer.config.AppConf;
	import com.doer.config.ComplexConf;
	import com.doer.interfaces.ISProcessor;
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.meta.paint.ShapeStyle;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.modes.blackbord.BlackbordMode;
	import com.doer.modes.courseware.mode.CoursewareMode;
	import com.doer.modes.nav.NavToolConf;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ClientComplexChangeScreen;
	import com.metaedu.client.messages.nebula.ClientComplexClean;
	import com.metaedu.client.messages.nebula.ClientComplexDraw;
	import com.metaedu.client.messages.nebula.ClientComplexMove;
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;
	import com.metaedu.client.messages.nebula.NebulaScreenType;
	import com.metaedu.client.messages.nebula.ServerComplexAddFileInform;
	import com.metaedu.client.messages.nebula.ServerComplexAddFilePageInform;
	import com.metaedu.client.messages.nebula.ServerComplexCleanInform;
	import com.metaedu.client.messages.nebula.ServerComplexDrawInform;
	import com.metaedu.client.messages.nebula.ServerComplexEnterResp;
	import com.metaedu.client.messages.nebula.ServerComplexMoveInform;
	import com.metaedu.client.messages.nebula.ServerPassiveOutInform;
	import com.metaedu.client.messages.nebula.ServerSignInResp;
	import com.metaedu.client.messages.nebula.complex.draw.Dot;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import flash.events.IEventDispatcher;
	import flash.utils.setTimeout;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	import view.modes.courseware.CoursewareView;
	
	public class CoursewareController extends AbstrackController implements IDelegate
	{
	
		public var coursewareMode:CoursewareMode = CoursewareMode.getInstance();
		
		public var delegation:Delegation = new Delegation();
		
		public var isOpenFile:Boolean = false;
		
		public function CoursewareController(metaManager:MetaManager, modeId:int, container:Group=null)
		{
			super(metaManager, modeId, container);

			invalidateCommands();
		}
		
		private function invalidateCommands():void
		{
			registCommand(LocalCommandType.CMD_LOGIN_COMPLETE);
			registCommand(LocalCommandType.CMD_NAV_PEN);
			registCommand(LocalCommandType.CMD_NAV_ERASER);
			registCommand(LocalCommandType.CMD_NAV_CLEAR);
			registCommand(LocalCommandType.CMD_NAV_TEXT);
			registCommand(LocalCommandType.CMD_NAV_HAND);
			registCommand(LocalCommandType.CMD_OPEN_FILE);
			
		}
		
		override public function reset():void
		{
			coursewareMode.reset();
			
			if(modeView != null)
				removeView();

		}

		public function saveDelegatePaintdata(data:Object):void
		{
			coursewareMode.savePaintData(data,delegation.curBookId,delegation.curPage);
		
			var draw:ClientComplexDraw = BlackbordMode.changeLocalDataToSendData(data,delegation.isSecondScreen);
			
			draw.screen = NebulaScreenType.DOCUMENT;
			draw.document = delegation.curBookId;
			draw.page = delegation.curPage;
			draw.index = delegation.isSecondScreen ? 2 : 1;
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,draw));
			
		}
		
		public function clear():void
		{
			coursewareMode.clearPaintdata(delegation.curBookId,delegation.curPage);
			
			var clearInfo:ClientComplexClean = new ClientComplexClean();
			
			clearInfo.document = delegation.curBookId;
			clearInfo.page = delegation.curPage;
			clearInfo.screen = NebulaScreenType.DOCUMENT;
			clearInfo.index = delegation.isSecondScreen ? 2 : 1;
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,clearInfo));
			
		}

		public function getInvalidatePaintdata(bookId:String,pageId:int):Array
		{
			return coursewareMode.getInvalidatePaintData(bookId,pageId);
		}
		
		/***
		 * 发送移动消息/翻页消息
		 * **/
		public function sendMoveInfo(x:Number,y:Number):void
		{
			var moveInfo:ClientComplexMove = new ClientComplexMove();
			
			moveInfo.document = delegation.curBookId;
			moveInfo.page = delegation.curPage;
			moveInfo.x = isNaN(x) ? 0 : x;
			moveInfo.y = isNaN(y) ? 0 :y;
			moveInfo.screen = NebulaScreenType.DOCUMENT;
			moveInfo.step = delegation.curFrame;
			moveInfo.index = delegation.isSecondScreen ? 2 : 1;
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,moveInfo));
		
		}
	
		override public function registView():IView
		{
			var course:CoursewareView = new CoursewareView();
			
			course.delegation = delegation;
			
			return course;
		}
		
		override public function onCommand(cmd:LocalCommand):void
		{
			
			if(cmd.command == LocalCommandType.CMD_LOGIN_COMPLETE)
			{
//				removeCommand(LocalCommandType.CMD_LOGIN_COMPLETE); //移除监听
				
				var loginInfo:ServerComplexEnterResp = cmd.data as ServerComplexEnterResp;
				
				onLoginInfo(loginInfo);
			}
			else if(cmd.command == LocalCommandType.CMD_OPEN_FILE)
			{
				onOpenFile(cmd.data);
			}
			else
			{
				if(modeView != null)
				{
					delegation.onCommand(cmd);
				}
			}
		}
		
		private function onOpenFile(data:Object):void
		{
			if(data.isSubScreen == delegation.isSecondScreen && data.isDoc)
			{
				var changeInfo:ClientComplexChangeScreen;
				
				if(data.isSubScreen)
				{
					if(ComplexConf.subActiveScreen != NebulaScreenType.DOCUMENT)
					{
						changeInfo = new ClientComplexChangeScreen();
						changeInfo.screen = NebulaScreenType.DOCUMENT;
						changeInfo.index = 2;
						
						sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,changeInfo));
						
						delegation.curBookId = data.id;
						isOpenFile = true;
						
					}else
					{
						(modeView as CoursewareView).onOpenBook(data.id);
					}
					
				}else
				{
					if(ComplexConf.activeScreen != NebulaScreenType.DOCUMENT)
					{
						changeInfo = new ClientComplexChangeScreen();
						changeInfo.screen = NebulaScreenType.DOCUMENT;
						changeInfo.index = 1;
						
						sendCommand(new LocalCommand(LocalCommandType.CMD_SEND_TO_SERVER,changeInfo));
						
						delegation.curBookId = data.id;
						isOpenFile = true;
						
					}else
					{
						(modeView as CoursewareView).onOpenBook(data.id);
					}
				}
			}
		}
		
		private function onLoginInfo(loginInfo:ServerComplexEnterResp):void
		{
			coursewareMode.addInvalidateDocments(loginInfo.documents,delegation);
			
		}
		
		override public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
			if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_DRAW_INFORM)
			{
				onRcvServerDrawInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexDrawInform));
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_MOVE_INFORM)
			{
				onRcvMoveInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexMoveInform));
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_CLEAN_INFORM)
			{
				onRcvCleanInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexCleanInform));
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_ADD_FILEPAGE_INFORM)
			{
				onRcvFilePageAdd(JsonUtils.convertJsonToClass(refContent,ServerComplexAddFilePageInform));
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_ADD_FILE_INFORM)
			{
				onRcvAddFile(JsonUtils.convertJsonToClass(refContent,ServerComplexAddFileInform))
			}
		}
		
		/**
		 * 收到添加文件消息
		 * **/
		private function onRcvAddFile(fileInfo:ServerComplexAddFileInform):void
		{
			coursewareMode.addFileInfo(fileInfo);
		}
		
		/**
		 * 文档页转换完成
		 * **/
		private function onRcvFilePageAdd(pageInfo:ServerComplexAddFilePageInform):void
		{
			coursewareMode.addPageInfo(pageInfo);
			
			var courseware:CoursewareView = modeView as CoursewareView;
			
			if(courseware != null && courseware.isInvalidated && delegation.curBookId == pageInfo.id)
			{
				courseware.addCurbookPage(pageInfo);
			}
			
		}
		
		/**
		 * 清除
		 * **/
		private function onRcvCleanInfo(cleanInfo:ServerComplexCleanInform):void
		{
			if(cleanInfo.screen == NebulaScreenType.DOCUMENT)
			{
				coursewareMode.clearPaintdata(cleanInfo.document,cleanInfo.page);
				
				var courseware:CoursewareView = modeView as CoursewareView;
				
				if(courseware != null && delegation.curBookId == cleanInfo.document && delegation.curPage == cleanInfo.page && courseware.getCanvas() != null
					&& (cleanInfo.index == 2 && delegation.isSecondScreen || cleanInfo.index == 1 && !delegation.isSecondScreen)
				)
				{
					courseware.getCanvas().clear();
				}
			}
			
		}
		
		
		/**
		 * 收到移动消息
		 * **/
		private function onRcvMoveInfo(moveInfo:ServerComplexMoveInform):void
		{
			
			
			if(moveInfo.screen == NebulaScreenType.DOCUMENT)
			{
				var courseware:CoursewareView = modeView as CoursewareView;
				
				if(moveInfo.index == 2 && delegation.isSecondScreen || moveInfo.index == 1 && !delegation.isSecondScreen)
				{
					if(courseware != null && courseware.isInvalidated)
					{
						if(delegation.curBookId != moveInfo.document )
							courseware.onOpenBook(moveInfo.document,moveInfo.page,moveInfo.step,false);
						else
							courseware.onPage(moveInfo.page,moveInfo.step,false);
					}else
					{
						delegation.curBookId = moveInfo.document;
						
						delegation.curPage = moveInfo.page;
						delegation.curFrame = moveInfo.page;
					}
					
//					if(courseware != null && courseware.csContainer != null)
//						courseware.onPage(moveInfo.page,moveInfo.step,false);
//					else
//					{
//						
//					}
						
					
				}
			}
			
		}
		
		private function onRcvServerDrawInfo(drawInfo:ServerComplexDrawInform):void
		{
			var data:Object = BlackbordMode.changeServDataToLocal(drawInfo);
			
			coursewareMode.savePaintData(data,drawInfo.document,drawInfo.page);
			
			if((ComplexConf.activeScreen == NebulaScreenType.DOCUMENT && drawInfo.index == 1 && !delegation.isSecondScreen) || (drawInfo.index == 2 && delegation.isSecondScreen && ComplexConf.subActiveScreen == NebulaScreenType.DOCUMENT ))
			{
				
				delegation.onRefresh();
			}
			
		}
	
		
	}
}