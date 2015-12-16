package com.doer.modes.skydrive
{
	import com.doer.config.AppConf;
	import com.doer.config.ComplexConf;
	import com.doer.modes.skydrive.files.FileDataLoader;
	import com.doer.modes.skydrive.files.FileUnit;
	import com.doer.modes.skydrive.files.UsedFileInfo;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;

	public class SkyDriveMode extends EventDispatcher
	{
		private static var instance:SkyDriveMode = null;
		
		/**
		 * 加载文件夹完成
		 * **/
		public static const LOAD_FOLDER_COMPLETE:String = "LOAD_FOLDER_COMPLETE";
		
		public static function getInstance():SkyDriveMode
		{
			if(instance == null)
				instance = new SkyDriveMode();
			
			return instance;
		}
		
		/**
		 * 文档列表数据
		 * **/
		public var usedFileInfos:Vector.<UsedFileInfo> = new Vector.<UsedFileInfo>();
		
		/**
		 * 文件夹数据
		 * **/
		public var skyDriveFile:Object = new Object();
		
		/**
		 * 不支持的列表
		 * **/
		public var unsurportList:Array = new Array();
		
		/**
		 * 清空数据
		 * **/
		public function clearData():void
		{
			skyDriveFile = new Object();
			
			usedFileInfos = new Vector.<UsedFileInfo>();
		}
		
		/**
		 * 获取文件夹内容
		 * **/
		public function getFolderContentById(id:String):Array
		{
			return skyDriveFile[id];
		}
		
		/**
		 * 添加文件到文件夹
		 * **/
		public function addFileUintToSkydrive(file:FileUnit):void
		{
			if(skyDriveFile[file.parentId] == null)
				skyDriveFile[file.parentId] = new Array();
			
			skyDriveFile[file.parentId].unshift(file);
			
		}
		
		/**
		 * 是否可以直接打开
		 * **/
		public function checkIsOpenDirect():void
		{
			for each(var arr:Array in skyDriveFile)
			{
				for(var i:int = 0; i < arr.length; i ++)
				{
					for each(var info:UsedFileInfo in usedFileInfos)
					{
						if(info.id == arr[i].id && info.pages != 0)
						{
							arr[i].fileStatus = FileUnit.status_changing_complete;
							break;
						}
					}
				}
			}
		}
		
		/**
		 * 获取指定文件或者文件夹
		 * **/
		public function getFileUnitById(id:String):FileUnit
		{
			for each(var arr:Array in skyDriveFile)
			{
				for(var i:int = 0; i < arr.length; i ++)
				{
					if(arr[i].id == id)
						return arr[i];
				}
			}
			
			return null;
		}
		
		/**
		 * 获取指定名字的文件
		 * **/
		public function getFileUintByName(name:String,folderName:String):FileUnit
		{
			var arr:Array = skyDriveFile[folderName];
			
			if(arr != null)
			{
				for(var i:int = 0; i < arr.length; i ++)
				{
					if(arr[i].name == name)
						return arr[i];
				}
			}

			return null;
		}
		
		/**
		 * 根据taskid获取文件
		 * **/
		public function getFileUintByTaskId(taskId:String):FileUnit
		{
			for each(var arr:Array in skyDriveFile)
			{
				for(var i:int = 0; i < arr.length; i ++)
				{
					if(arr[i].taskId == taskId)
						return arr[i];
				}
			}
			
			return null;
		}
		
		/**
		 * 获取网盘文件夹数据
		 * **/
		public function loadSkyDriveFolder(id:String):void
		{
			var data:Object = {
				
				folderId : id,
				sortKey : 1,
				sortType : 1
			};
		
			var value:URLVariables = new URLVariables();
			value['data'] = JSON.stringify(data);
			value['userId'] = ComplexConf.userId;
			
			new FileDataLoader().loadByPost("http://" + AppConf.webAddr + "/netdisk/data/explor-folder.htm",ComplexConf.userId,value,onLoadDriveFolder,id);
		}
		
		private function onLoadDriveFolder(data:Object,targetId:String):void
		{
			var arr:Array = new Array();
			
			for(var i:int = 0; i < data.units.length; i ++)
			{
				var unit:FileUnit = new FileUnit(data.units[i]);
				
				unit.checkSupport();
				
				arr.push(unit);
			}
			
			skyDriveFile[targetId] = arr;
			
			checkIsOpenDirect();
			
			checkIsUnsurport();
			
			dispatchEvent(new Event(LOAD_FOLDER_COMPLETE));
		}
		
		public function checkIsUnsurport():void
		{
			for each(var arr:Array in skyDriveFile)
			{
				for(var i:int = 0; i < arr.length; i ++)
				{
					for each(var id:String in unsurportList)
					{
						if(arr[i].id == id)
						{
							(arr[i] as FileUnit).fileStatus = FileUnit.status_unsupport;
							break;
						}
					}
				}
			}
		}
		
		/**
		 * 上传文件
		 * **/
		public function uploadFile(id:String):void
		{
			
			var info:FileUnit = getFileUnitById(id);
			
			info.fileStatus = FileUnit.status_changing;
			
			var data:Object = {
				
				complexId : ComplexConf.complexId,
				userId : ComplexConf.userId,
				id : info.id,
				fileId : info.fileId
			};
			
			var value:URLVariables = new URLVariables();
			
			value['data'] = JSON.stringify(data);
			value['simSession'] = AppConf.session;
			
			new FileDataLoader().loadByPost("http://" + AppConf.webAddr + "/netdisk/data/complex-file.htm",AppConf.session,value,onUploadFileComplete,id);
		}
		
		private function onUploadFileComplete(data:Object,targetId:String):void
		{
			var info:FileUnit = getFileUnitById(targetId);
			
			info.taskId = data["taskId"];
			
		}
		
		
		
	}
}