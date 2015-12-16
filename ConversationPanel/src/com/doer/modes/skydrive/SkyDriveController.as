package com.doer.modes.skydrive
{
	import com.doer.common.Tools;
	import com.doer.config.AppConf;
	import com.doer.config.ComplexConf;
	import com.doer.config.ModeTypes;
	import com.doer.interfaces.IView;
	import com.doer.manager.MetaManager;
	import com.doer.modes.abstrack.AbstrackController;
	import com.doer.modes.courseware.CoursewareController;
	import com.doer.modes.courseware.mode.CoursewareMode;
	import com.doer.modes.media.MediaController;
	import com.doer.modes.nav.MainNavController;
	import com.doer.modes.nav.SubNavController;
	import com.doer.modes.skydrive.files.FileUnit;
	import com.doer.modes.skydrive.files.UsedFileInfo;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.NebulaFileStatus;
	import com.metaedu.client.messages.nebula.NebulaFileUsingType;
	import com.metaedu.client.messages.nebula.NebulaMessageBusinessType;
	import com.metaedu.client.messages.nebula.ServerComplexAddFileInform;
	import com.metaedu.client.messages.nebula.ServerComplexAddFilePageInform;
	import com.metaedu.client.messages.nebula.ServerComplexEnterResp;
	import com.metaedu.client.messages.nebula.ServerComplexQueryFileResponse;
	import com.metaedu.client.messages.nebula.complex.DocumentUnit;
	import com.metaedu.client.messages.nebula.complex.MediaCtrlType;
	import com.metaedu.client.messages.nebula.complex.MultimediaUnit;
	import com.metaedu.client.messages.utils.TimeUtils;
	import com.metaedu.client.utils.text.JsonUtils;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.events.ResizeEvent;
	
	import spark.components.Group;
	
	import view.modes.nav.main.MainNavContent;
	import view.modes.skydrive.SkyDriveView;
	
	public class SkyDriveController extends AbstrackController
	{
		public var mode:SkyDriveMode = SkyDriveMode.getInstance();
		
		public var isSecondScreen:Boolean = false;
		
		/**
		 * 当前正在打开的文件夹id
		 * **/
		public var curFolderId:String = "";
		
		/**
		 * 需要被打开的文件id
		 * **/
		public var curFileId:String = null;
		
		public function SkyDriveController(metaManager:MetaManager, modeId:int, container:Group=null)
		{
			super(metaManager, modeId, container);
			
			registCommand(LocalCommandType.CMD_LOGIN_COMPLETE);	
			
			SkyDriveMode.getInstance().addEventListener(SkyDriveMode.LOAD_FOLDER_COMPLETE,onLoadFileComplete);
			
		}
		
		override public function reset():void
		{
			if(modeView != null)
				removeView();
			
			mode.clearData();
		}
		
		override public function registView():IView
		{
			var v:SkyDriveView = new SkyDriveView();
			
			v.x = container.width / 2 - v.width/2;
			v.y = container.height / 2 - v.height/2;
			
			return v;
		}
		
		override public function onCommand(cmd:LocalCommand):void
		{
			if(cmd.command == LocalCommandType.CMD_LOGIN_COMPLETE)
			{
//				removeCommand(LocalCommandType.CMD_LOGIN_COMPLETE);
				
				onLoginInfo(cmd.data as ServerComplexEnterResp);
				
				mode.loadSkyDriveFolder(curFolderId);
			}
		}
		
		private function onLoginInfo(info:ServerComplexEnterResp):void
		{
			for(var i:int = 0; i < info.documents.contents.length; i ++)
			{
				var docInfo:UsedFileInfo = new UsedFileInfo();
				docInfo.name = info.documents.contents[i].name;
				docInfo.statue = info.documents.contents[i].pages.length == 0 ? UsedFileInfo.TRANSING : UsedFileInfo.PREPARED;
				docInfo.id = info.documents.contents[i].id;
				docInfo.fileId = info.documents.contents[i].fileId;
				docInfo.suffix = info.documents.contents[i].suffix;
				docInfo.pages = info.documents.contents[i].pages.length;
				docInfo.usingType = NebulaFileUsingType.DOCUMENT;
				
				mode.usedFileInfos.push(docInfo);
				
			}
			
			for(i = 0; i < info.multimedias.contents.length; i ++)
			{
				docInfo = new UsedFileInfo();
				docInfo.name = info.multimedias.contents[i].name;
				docInfo.statue = info.multimedias.contents[i].status == NebulaFileStatus.PREPARED ?  UsedFileInfo.PREPARED : UsedFileInfo.TRANSING;
				docInfo.id = info.multimedias.contents[i].id;
				docInfo.fileId = info.multimedias.contents[i].fileId;
				docInfo.suffix = info.multimedias.contents[i].suffix;
				docInfo.total = info.multimedias.contents[i].total;
				docInfo.pages = 1;
				docInfo.usingType = NebulaFileUsingType.VIDEO;
				
				mode.usedFileInfos.push(docInfo);
			}
			
			mode.checkIsOpenDirect();
		}
		
		override public function onRcv(refContent:String, refBusinessType:int, refTimeStamp:String=''):void
		{
			if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_QUERY_FILE_RESPONSE)
			{
				onRcvFileChangeInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexQueryFileResponse));
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_ADD_FILE_INFORM)
			{
				onRcvAddFile(JsonUtils.convertJsonToClass(refContent,ServerComplexAddFileInform));
			}else if(refBusinessType == NebulaMessageBusinessType.SERVER_COMPLEX_ADD_FILEPAGE_INFORM)
			{
				onRcvAddFilePageInfo(JsonUtils.convertJsonToClass(refContent,ServerComplexAddFilePageInform));
			}
		}
		
		/**
		 * 文档转换信息
		 * **/
		private function onRcvFileChangeInfo(info:ServerComplexQueryFileResponse):void
		{
			var file:FileUnit = mode.getFileUintByTaskId(info.taskId);
			
			if(info.status == NebulaFileStatus.UNSUPPORT)
			{
				if(file != null)
				{
					file.fileStatus = FileUnit.status_unsupport;
					mode.unsurportList.push(file.id);
				}else
				{
					mode.unsurportList.push(info.taskId);
				}
				
			}
				
		}
		
		/**
		 * 收到文件上传消息
		 * **/
		private function onRcvAddFile(info:ServerComplexAddFileInform):void
		{
			var docInfo:UsedFileInfo = new UsedFileInfo();
			docInfo.name = info.name;
			docInfo.statue = UsedFileInfo.TRANSING;
			docInfo.id = info.id;
			docInfo.suffix = info.suffix;
			docInfo.total = info.total;
			docInfo.usingType = info.usingType;
			docInfo.fileId = info.fileId;
			
			mode.usedFileInfos.unshift(docInfo);

			var isContinue:Boolean = true;
			
			while(isContinue)
			{
				isContinue = false;
				
				for( var i:int = 0; i < releaseQueue.length; i ++)
				{
					if(releaseQueue[i].id == docInfo.id)
					{
						docInfo.pages ++;
						
						releaseQueue.splice(i,1);
						isContinue = true;
						break;
					}
				}
			}
			
				
			if(modeView != null)
			{
				(modeView as SkyDriveView).refreshUsedContent();
			}
			
			mode.checkIsOpenDirect();
			
			sendCommand(new LocalCommand(LocalCommandType.CMD_SKYDRIVE_REFRESH));
		}
		
		private var releaseQueue:Vector.<ServerComplexAddFilePageInform> = new Vector.<ServerComplexAddFilePageInform>();
		
		/**
		 * 收到转换消息
		 * **/
		private function onRcvAddFilePageInfo(info:ServerComplexAddFilePageInform):void
		{
			var isAdded:Boolean = false;
			
			for each(var docInfo:UsedFileInfo in mode.usedFileInfos)
			{
				if(docInfo.id == info.id)
				{
					isAdded = true;
					docInfo.pages ++;
					break;
				}
			}
			
			if(!isAdded)
				releaseQueue.push(info);
			
			mode.checkIsOpenDirect();
			
		}
		
		/**
		 * 打开文件
		 * **/
		public function openFile(id:String,fileId:String,isDoc:Boolean,isSubScreen:Boolean):void
		{
			sendCommand(new LocalCommand(LocalCommandType.CMD_OPEN_FILE,{id : id,fileId: fileId, isDoc : isDoc, isSubScreen : isSubScreen}));
		}
		
		/**
		 * 刷新
		 * **/
		public function onFreshData():void
		{
			
			curFolderId = "";
			
			mode.skyDriveFile = new Object();
			
			mode.loadSkyDriveFolder("");
		}
		
		/**
		 * 打开网盘文件
		 * **/
		public function openSkydrive(id:String,fileId:String,usingType:int,fileStatus:String,isCatalog:Boolean):void
		{
			if(isCatalog)
			{
				curFolderId = id;
				
				var arr:Array = mode.getFolderContentById(id);
				
				mode.loadSkyDriveFolder(id);
				
			}else
			{
				curFileId = fileId;
				
				if(usingType == NebulaFileUsingType.DOCUMENT || usingType == NebulaFileUsingType.PICTURE)
				{
					
					var courseId:int = isSecondScreen ? ModeTypes.MODE_COURSE_ID : ModeTypes.MODE_SUB_COURSE_ID;
					
					var courseController:CoursewareController = metaManager.getControllerById(courseId) as CoursewareController;
					
					if(courseController.delegation.curBookId == id && courseController.modeView != null)
					{
						Tools.alert("该文件已经被打开过");
						return;
					}
					
					if(courseController.delegation.curBookId == id)
					{
						courseController.delegation.curBookId = "";
						courseController.delegation.curPage = 0;
						courseController.delegation.curFrame = 0;
						
						courseController.sendMoveInfo(0,0);
					}
						
					
					if(fileStatus == FileUnit.status_upload_complete)
						mode.uploadFile(id);
					else
						openFile(id,fileId,true,isSecondScreen);
					
				}else if(usingType == NebulaFileUsingType.AUDIO || usingType == NebulaFileUsingType.VIDEO)
				{
					
					var mediaId:int = isSecondScreen ? ModeTypes.MODE_MEDIA_ID : ModeTypes.MODE_SUB_MEDIA_ID;
					
					var mediaController:MediaController = metaManager.getControllerById(mediaId) as MediaController;
					
					if(mediaController.modeView != null && mediaController.player.id == id)
					{
						Tools.alert("该文件已经被打开过");
						return;
					}
					
					if(mediaController.player.id == id)
					{
						mediaController.player.disponse();
						
						mediaController.sendMediaInfo("",0,MediaCtrlType.PLAY);
					}
						
					
					if(fileStatus == FileUnit.status_upload_complete)
						mode.uploadFile(id);
					else
						openFile(id,fileId,false,isSecondScreen);
					
				}
				
			}
		}
		
		/**
		 * 文件夹加载完成
		 * **/
		private function onLoadFileComplete(e:Event):void
		{
			if(modeView != null)
			{
				(modeView as SkyDriveView).refreshSkyDriveContent();
				(modeView as SkyDriveView).refreshUsedContent();
			}
				
		}
		
		/**
		 * 上传中的数据
		 * **/
		public var temp_fileDatas:Vector.<FileUnit> = new Vector.<FileUnit>();
		
		
		/**
		 * 开启加载
		 * **/
		public function openUpload():void
		{
			var file:FileReference = new FileReference();
			
			file.browse();
			
			file.addEventListener(Event.SELECT,onSelected);
		}
		
		private function onSelected(e:Event):void
		{
			var file:FileReference = e.target as FileReference;
			
			file.removeEventListener(Event.SELECT,onSelected);
			
			var oneGb:Number = 1024 * 1024 * 1024;
			
			if(file.size > oneGb )
			{
				
				Tools.alert("文件大小不能超过1G！");
				
				return;	
			}
			
			
			var urlRequest:URLRequest = new URLRequest();
			
			var value:Object = new Object();
			
			value['complexId'] = ComplexConf.complexId;
			value['userId'] = ComplexConf.userId;
			value['folderId'] = curFolderId;
			
			urlRequest.url = "http://" + AppConf.webAddr + "/netdisk/data/complex-file.htm" + "?data=" + JSON.stringify(value) + "&simSession=" + AppConf.session;
			
			file.upload(urlRequest,"file");
			
			file.addEventListener(ProgressEvent.PROGRESS,onProgress);
			file.addEventListener(Event.COMPLETE,onUploadComplete);
			file.addEventListener(IOErrorEvent.IO_ERROR,onError);
			file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,onUploadData);
			
			var temp:FileUnit = new FileUnit();
			
			var index:int = 0;
			var baseName:String = file.name.substr(0,file.name.lastIndexOf("."));
			var suffix:String = file.name.substring(file.name.lastIndexOf(".") + 1,file.name.length);
			var name:String = file.name;
			
			while(true)
			{
				var fileUint:FileUnit = mode.getFileUintByName(name,curFolderId);
				
				if(fileUint == null)
				{
					temp.name = name;
					
					break;
					
				}else
				{
					index ++;
					
					name = baseName + "(" + index + ")" + "." + suffix; 
				}
			}
			
			
			temp.suffix = suffix;
			temp.fileStatus = FileUnit.status_uploading;
			temp.statusValue = "0%";
			temp.name = name;
			
			temp_fileDatas.push(temp);
		
			(modeView as SkyDriveView).refreshSkyDriveContent();
		}
		
		private function onUploadData(e:DataEvent):void
		{
			var data:Object = JSON.parse(e.data);
			
			var fileUint:FileUnit = new FileUnit(data.unit);
			
			fileUint.checkSupport();
			
			for (var i:int = 0; i < temp_fileDatas.length; i ++)
			{
				if(temp_fileDatas[i].name == fileUint.name)
				{
					temp_fileDatas.splice(i,1);
					break;
				}
			}
			
			mode.addFileUintToSkydrive(fileUint);
			
			mode.checkIsOpenDirect();
			
			(modeView as SkyDriveView).refreshSkyDriveContent();
			
		}
		
		private function onProgress(e:ProgressEvent):void
		{
			var file:FileReference = e.target as FileReference;
			
			for each(var fileUint:FileUnit in temp_fileDatas)
			{
				if(fileUint.name == file.name)
				{
					fileUint.statusValue = Math.round(e.bytesLoaded / e.bytesTotal * 100) + "%";
					break;
				}
			}
			
		}
		
		private function onUploadComplete(e:Event):void
		{
			var file:FileReference = e.target as FileReference;
			
			file.removeEventListener(ProgressEvent.PROGRESS,onProgress);
			file.removeEventListener(Event.COMPLETE,onUploadComplete);
			file.removeEventListener(IOErrorEvent.IO_ERROR,onError);
			
		}
		
		private function onError(e:IOErrorEvent):void
		{
			Tools.alert("上传错误！");
		}
		
		private function getFileFilter():FileFilter {
			
			return new FileFilter("file ( *.doc, *.docx, *.ppt, *.pptx, *.pdf, *.mp3, *.wma, *.aac, *.flv,*.mp4,*.avi,*.wmv,*.xls,*.xlsx)",
				"*.doc; *.docx; *.ppt; *.pptx; *.pdf; *.mp3;*.wma;*.aac; *.flv;*.mp4;*.avi;*.wmv;*.xls;*.xlsx;");
			
		}
		
		/**
		 * 获取需要被显示的数据
		 * **/
		public function getSkyDriveFileData(usingType:int):Object
		{
			var datas:Array = new Array();
			var driveArr:Array = mode.skyDriveFile[curFolderId];
			
			
			if(driveArr != null)
			{
				for(var i:int = 0; i < driveArr.length; i ++)
				{
					if(usingType == -1)
					{
						datas.push(driveArr[i]);
					}else
					{
						if(driveArr[i].usingType == usingType)
							datas.push(driveArr[i]);
					}
					
					
				}
			}
			
			for(i = 0; i < temp_fileDatas.length; i ++)
				datas.unshift(temp_fileDatas[i]);
			
			var cFile:FileUnit = mode.getFileUnitById(curFolderId);
			
			var folderData:Object = {
				
				folderName: cFile == null ? null : cFile.name,
				folderContent : datas
				
			}
			
			return folderData;
		}
		
		public function onClose():void
		{
			removeView();
			
			if(isSecondScreen)
				(metaManager.getControllerById(ModeTypes.MODE_SUBNAVGROUP_ID) as SubNavController).subNavContent.mainGroup.btnResource.selected = false;
			else
				(metaManager.getControllerById(ModeTypes.MODE_MAINNAVGROUP_ID) as MainNavController).mainNavContent.mainGroup.btnResource.selected = false;
			
			
		}
		
	}
}