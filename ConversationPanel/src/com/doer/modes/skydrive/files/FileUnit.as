package com.doer.modes.skydrive.files
{
	import com.metaedu.client.messages.nebula.NebulaFileStatus;
	import com.metaedu.client.messages.nebula.NebulaFileUsingType;

	public class FileUnit
	{
		/**
		 * 上传中
		 * **/
		public static const status_uploading:String = "status_uploading";
		
		/**
		 * 上传完成
		 * **/
		public static const status_upload_complete:String = "status_upload_complete";
		
		/**
		 * 转换中
		 * **/
		public static const status_changing:String = "status_changing";
		
		/**
		 * 转换完成
		 * **/
		public static const status_changing_complete:String = "status_changing_complete";
		
		/**
		 * 转换失败
		 * **/
		public static const status_changing_fail:String = "status_changing_fail";
		
		/**
		 * 不支持的文件
		 * **/
		public static const status_unsupport:String = "status_unsupport";
		
		/**
		 * 文件或文件夹的唯一标示
		 * **/
		public var id:String = "";
		
		/**
		 * 属于哪个文件盘类型
		 * **/
		public var diskType:int = 1; 
		
		/**
		 * 属于的文件夹id
		 * **/
		public var parentId:String = "";
		
		/**
		 * 文件id
		 * **/
		public var fileId:String = "";
		
		
		/**
		 * 大小
		 * **/
		public var size:String = "";
		
		/**
		 * 使用类型
		 * **/
		public var usingType:int = NebulaFileUsingType.DOCUMENT;
		
		/**
		 * 预览状态
		 * **/
		public var transStatus:int = 0;
		
		/***
		 * 最后修改时间
		 * ****/
		public var updateTime:String = "";
		
		/***
		 * 转换进度id
		 * */
		public var taskId:String = "";
		
		/**
		 * 是否文件夹
		 * **/
		[Bindable]
		public var isCatalog:Boolean = false;
		
		/**
		 * 创建时间
		 * **/
		[Bindable]
		public var createTime:String = "";
		
		
		/**
		 * 名字
		 * **/
		[Bindable]
		public var name:String = "";
		
		/**
		 * 后缀
		 * **/
		[Bindable]
		public var suffix:String = "";
		
		/**
		 * 文件状态
		 * **/
		[Bindable]
		public var fileStatus:String = status_upload_complete;
		
		/**
		 * 状态值
		 * **/
		[Bindable]
		public var statusValue:String = "";
		
		public function FileUnit(data:Object = null)
		{
			if(data != null)
			{
				this.id = data.id;
				this.diskType = data.diskType;
				this.parentId = data.parentId;
				this.fileId = data.fileId;
				this.isCatalog = data.isCatalog;
				this.name = data.name;
				this.suffix = data.suffix;
				this.size = data.size;
				this.usingType = data.usingType;
				this.transStatus = data.transStatus;
				this.createTime = data.createTime;
				this.updateTime = data.updateTime;
			}
			
		}
		
		public function checkSupport():void
		{
			var sups:Array = ["mp3","wma","aac","mp4","flv","wmv","avi","doc","docx","ppt","pptx","pdf","xlsx","xls","jpeg","jpg","png","gif"];
			
			var mSuffix:String = suffix.toLocaleLowerCase();
			
			var isInSups:Boolean = false;
			
			for(var i:int = 0; i < sups.length; i ++)
			{
				if(mSuffix == sups[i])
				{
					isInSups = true;
					break;
				}
					
			}
			
			if(!isInSups && !isCatalog)
				fileStatus = status_unsupport;
			
			
		}
		
	}
}