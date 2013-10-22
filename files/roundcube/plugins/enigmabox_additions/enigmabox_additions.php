<?php
/**
 * Class and Function List:
 * Function list:
 * - init()
 * - check_email()
 * Classes list:
 * - enigmabox_additions extends rcube_plugin
 */

class enigmabox_additions extends rcube_plugin
{
	
	function init() 
	{
		$this->include_script('eb.js');
	}
}
