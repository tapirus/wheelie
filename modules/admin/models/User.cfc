<cfscript>	
	component extends="models.Model"
	{					
		function init()
		{			
			// Before after save
			beforeSave("sanitize,checkAndSecurePassword,preventRoleHacking");
			
			// Validations		
			validatesConfirmationOf(properties="password", message="Your passwords must match!");			
			validatesPresenceOf("firstname,lastname,email");			
			validatesFormatOf(property="email", type="email"); 	
			validatesUniquenessOf("email"); 
			
			// Relations
			hasMany("Logs");
			belongsTo(name="Log");
			
			super.init();
			
			// Permission check override			
			beforeDelete('checkForDeletePermission');
			beforeCreate('checkForCreatePermission');
			beforeUpdate('checkForUpdatePermission');
		}	
		
		// Permission Checks
		private function checkForCreatePermission()	
		{
			if(isNull(this.createdby))
			{
				this.createdby = 0;
			}
			checkForPermission(type="save", checkid=0 & "," & this.createdby); // Allow whoever created it or the owner to edit
		}
		
		private function checkForUpdatePermission()	
		{
			checkForPermission(type="save", checkid=this.id & "," & this.createdby);
		}
		
		private function checkForDeletePermission()
		{
			checkForPermission(type="delete", checkid=this.id & "," & this.createdby);
		}
	 	
		// Clean strings
		private function sanitize()
		{
			try {
				this.firstname 	= htmlEditFormat(this.firstname);
				this.lastname 	= htmlEditFormat(this.lastname);		
				this.address1 	= htmlEditFormat(this.address1);		
				this.address2	= htmlEditFormat(this.address2);		
				this.state 		= htmlEditFormat(this.state);		
				this.zip 		= htmlEditFormat(this.zip);
				this.country 	= htmlEditFormat(this.country);
				this.phone 		= htmlEditFormat(this.phone);
			} catch(any e) {}
		}
		
		// Security
		private function checkAndSecurePassword()
		{
			if (StructKeyExists(this, "password") AND !len(this.password)) 
			{ 
				StructDelete(this,"password");
			}
			else if (StructKeyExists(this, "password") AND StructKeyExists(this, "passwordConfirmation")) 
			{ 
				this.password = passcrypt(this.password, "encrypt");
			} 			 
		}
		
		private function preventRoleHacking()
		{
			if(StructKeyExists(this, "role") AND checkPermission("user_save_role"))
			{				
				if(!checkPermission("user_save_role_admin") AND ListFind("admin,editor",lcase(this.role)))
				{ 
					StructDelete(this,"role");
				}
				
			} 
			else 
			{
				StructDelete(this,"role");
			}
		}
	}
</cfscript>	