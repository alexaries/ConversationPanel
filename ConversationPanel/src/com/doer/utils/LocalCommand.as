package com.doer.utils
{
	public class LocalCommand
	{
		private var _command:String = null;
		
		private var _data:Object = null;
		
		public function LocalCommand(command:String,data:Object = null)
		{
			this.command = command;
			this.data = data;
		}

		/**
		 * 命令数据
		 * **/
		public function get data():Object
		{
			return _data;
		}

		/**
		 * @private
		 */
		public function set data(value:Object):void
		{
			_data = value;
		}

		/**
		 * 命令
		 * **/
		public function get command():String
		{
			return _command;
		}

		/**
		 * @private
		 */
		public function set command(value:String):void
		{
			_command = value;
		}

	}
}