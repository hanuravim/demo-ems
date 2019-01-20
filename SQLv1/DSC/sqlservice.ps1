#get what drives exist exist on the server
$volumes = @(Get-CimInstance -Class Win32_Volume  | foreach {$_.driveLetter})
#list named drives
$volume = @('E:','L:','S:')
#compare drives
$compare = 0; foreach ($letter in $volumes) { if ($volume -contains $letter) { $compare++ } }
"{0} matches found" -f $compare 

#count
$count = ($compare | Measure-Object -Sum).Sum

If ($count.value -ne 3)
    {
        
        #connect to sql server
        $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $SqlConnection.ConnectionString = "Server=localhost;Database=master;Integrated Security=True"
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        
        #build query to gather database file destinations
        $SqlCmd.CommandText = "SELECT 
        	[database_id]
        	,[type]
        	,[name]
        	,[physical_name]
        	,CASE 
        		WHEN [type] = 0 THEN 'S:\systemData\'
        		WHEN [type] = 1 THEN 'L:\log\'
        	END AS [destinationDir]	
        FROM sys.master_files
        WHERE database_id <= 4 and database_id > 1
        AND physical_name NOT LIKE 'S:\systemData\%'
        AND physical_name NOT LIKE 'L:\log\%'"
        $SqlCmd.Connection = $SqlConnection
        $SqlConnection.Open();
        $SqlCmd.CommandType = [System.Data.CommandType]'Text'; 
        $Adapter = New-Object System.Data.SqlClient.SqlDataAdapter $SqlCmd;
        
        #load file source and destinations to dataset
        $dataSet = New-Object System.Data.DataSet;
        if($dataSet -ne $null){
        $Adapter.Fill($DataSet) | Out-Null;
        
        #build second query to adjust sql system database physical paths within SQL Server
        $SqlCmd2 = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd2.CommandText = "
        SET NOCOUNT ON 
        
        --Declare variables
        DECLARE @ePath NVARCHAR(15) = 'E:\data'
        DECLARE @lPath NVARCHAR(15) = 'L:\log'
        DECLARE @sPath NVARCHAR(15) = 'S:\systemData'
        
        DECLARE @dirTemp TABLE (subdirectory sysname)
        DECLARE @eDir NVARCHAR(15) = (SELECT LEFT(@ePath, CHARINDEX('\', @ePath) ))
        DECLARE @lDir NVARCHAR(15) = (SELECT LEFT(@lPath, CHARINDEX('\', @lPath) ))
        DECLARE @sDir NVARCHAR(15) = (SELECT LEFT(@sPath, CHARINDEX('\', @sPath) ))
        
        --Validate Directories exists
        --Insert subdirectory data 
        INSERT INTO @dirTemp
        EXEC master..xp_subdirs @eDir
        
        INSERT INTO @dirTemp
        EXEC master..xp_subdirs @lDir
        
        INSERT INTO @dirTemp
        EXEC master..xp_subdirs @sDir
        
        --IF doesnt exist, create'D:\data'
        IF (SELECT subdirectory FROM @dirTemp WHERE subdirectory = RIGHT(@ePath, CHARINDEX('\' , REVERSE(@ePath) ) - 1 )) IS NULL
        EXEC master..xp_create_subdir @ePath;
        
        --If doesn't exist, create 'L:\log'
        IF (SELECT subdirectory FROM @dirTemp WHERE subdirectory = RIGHT(@lPath, CHARINDEX('\' , REVERSE(@lPath) ) - 1 )) IS NULL
        EXEC master..xp_create_subdir @lPath;
        
        --If doesn't exist, create 'S:\systemData'
        IF (SELECT subdirectory FROM @dirTemp WHERE subdirectory = RIGHT(@sPath, CHARINDEX('\' , REVERSE(@sPath) ) - 1 )) IS NULL
        EXEC master..xp_create_subdir @sPath;
        
        --Begin process of altering database files
        DECLARE @alterFileTable TABLE ([database_id] INT, [type] INT, [name] sysname, [physical_name] sysname)
        DECLARE @SQLString NVARCHAR(MAX)
        
        --Gather list of files to alter 
        INSERT INTO @alterFileTable 
        SELECT 
        	[database_id]
        	,[type]
        	,[name]
        	,[physical_name]
        FROM sys.master_files
        WHERE database_id <= 4 and database_id > 1
        AND physical_name NOT LIKE @ePath + '%'
        OR database_id <= 4 and database_id > 1
        AND physical_name NOT LIKE @lPath + '%'
        OR database_id <= 4 and database_id > 1
        AND physical_name NOT LIKE @sPath + '%'
        
        --Declare variables for loop
        DECLARE @database sysname 
        DECLARE @type INT
        DECLARE @name sysname 
        DECLARE @physicalName sysname
        
        
        --Begin loop to redirect system database files. 
        WHILE EXISTS(SELECT [database_id] FROM @alterFileTable) 
        	BEGIN 
        
        		SELECT TOP 1
        			@database		= DB_NAME([database_id])
        			,@type			= [type]
        			,@name			= [name]
        			,@physicalName	= [physical_name]
        		FROM @alterFileTable
        
        		SELECT @SQLString = 'ALTER DATABASE ' + QUOTENAME(@database) + ' MODIFY FILE ( NAME = ' + @name + ', FILENAME = ''' + CASE WHEN @type = 0 THEN @sPath WHEN @type = 1 THEN @lPath END + '\' + RIGHT(@physicalName, CHARINDEX('\' , REVERSE(@physicalName) ) - 1 ) + ''');'
        		
        		EXECUTE (@SQLString)
        
        		DELETE FROM @alterFileTable WHERE [database_id] = DB_ID(@database) AND [name] = @name AND physical_name = @physicalName
        	END
        "
        $SqlCmd2.Connection = $SqlConnection
        $SqlCmd2.CommandType = [System.Data.CommandType]'Text'; 
        $SqlCmd2.ExecuteNonQuery()
        $SqlConnection.Close();
        
        #Stop SQL Services to allow for copy of data files
        Stop-Service -Name SQLSERVERAGENT -Force;
        
        Stop-Service -Name MSSQLSERVER -Force;
        
        #Copy database files to proper location while SQL Service is off
        $DataSet.Tables.Rows | ForEach-Object { Copy-Item -Path $_.physical_name -Destination $_.destinationDir}
        
        #Start SQL Services with files in new locations
        Start-Service -Name MSSQLSERVER;
        
        Start-Service -Name SQLSERVERAGENT;
        }
        else{Write-Host 'Dataset is empty'}
    }
ELSE
    {
        Write-Warning -Message 'Mapped volumes do not match.  Please ensure the volumes E, L and S are mapped properly.'
    }
