/*
=======================================================================
ARCHIVO     : XP_CMDSHELL.SQL
AUTOR       : Jose Mariano Alvarez
CREADO      : 17-DICIEMBRE-2017
DESCRIPCION : Pruebas con el xp_cmdshell
REFERENCIAS :

¿Cómo ejecutar xp_cmdshell con mínimos permisos?
http://blog.josemarianoalvarez.com/2017/12/14/ejecutar-xp_cmdshell-minimos-permisos/
		
##xp_cmdshell_proxy_account## No se pudo crear la credencial
http://blog.josemarianoalvarez.com/2017/12/12/xp_cmdshell_proxy_account-no-se-pudo-crear-la-credencial/

xp_cmdshell emite CALL TO LOGONUSERW FAILED WITH ERROR CODE 1385
http://blog.josemarianoalvarez.com/2017/12/06/xp_cmdshell-emite-call-to-logonuserw-failed-with-error-code-1385/
	

CAMBIOS     :
======================================================================= 
*/


-----------------------------------------------
-- Usando un Login como sysadmin
-----------------------------------------------

--Habilitar la ejecucion del xp_cmdshell
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO


-- Ahora puedo ejecutar como sysadmin
exec xp_cmdshell 'dir c:\*.*'

-----------------------------------------------
-- Voy a probar como usuario comun
-----------------------------------------------

--Creo el login para prueba sin permisos
CREATE LOGIN [Prueba_xp_cmdshell]
WITH 
	PASSWORD=N'Pass1234',
	DEFAULT_DATABASE=[master],
	CHECK_EXPIRATION=OFF, 
	CHECK_POLICY=OFF


-----------------------------------------------
-- En otra ventana ingreso con el login Prueba_xp_cmdshell
-----------------------------------------------
	
-- No puedo ejecutar con el login Prueba_xp_cmdshell 
exec xp_cmdshell 'dir c:\*.*'


--Msg 229, Level 14, State 5, Procedure xp_cmdshell, Line 1 [Batch Start Line 0]
--The EXECUTE permission was denied on the object 'xp_cmdshell', database 'mssqlsystemresource', schema 'sys'.


-----------------------------------------------
-- En la ventana del syadmin le asigno los 
-- permisos de ejecucion en la base de datos master
-----------------------------------------------

-- Creo el usuario
USE [master]
GO
CREATE USER [Prueba_xp_cmdshell] 
FOR LOGIN [Prueba_xp_cmdshell]
GO

-- Asigno el permiso de ejecucion al usuario
GRANT EXECUTE ON [sys].[xp_cmdshell] 
TO [Prueba_xp_cmdshell]
GO


-----------------------------------------------
-- En la ventana del login Prueba_xp_cmdshell
-----------------------------------------------

-- No puedo ejecutar como Prueba_xp_cmdshell 
exec xp_cmdshell 'dir c:\*.*'

--Msg 15153, Level 16, State 1, Procedure xp_cmdshell, Line 1 [Batch Start Line 0]
--The xp_cmdshell proxy account information cannot be retrieved or is invalid. Verify that the '##xp_cmdshell_proxy_account##' credential exists and contains valid information.


-----------------------------------------------
-- Asigno la proxy account
-----------------------------------------------

--En la ventana del syadmin trato de asignar la proxy account
EXEC sp_xp_cmdshell_proxy_account
N'SqlTotal\JoseMariano',
N'Pass1234'

-- Msg 15137, Level 16, State 1, Procedure sp_xp_cmdshell_proxy_account, Line 1 [Batch Start Line 57]
-- An error occurred during the execution of sp_xp_cmdshell_proxy_account. Possible reasons: 
-- the provided account was invalid or the '##xp_cmdshell_proxy_account##' credential could not be created. 
-- Error code: 1326(The user name or password is incorrect.), Error Status: 0.

-- No se puede porque la aplicación no tiene privilegios elevados
-- Si abre un management Studio "AS ADMINISTRATOR" en el servidor 
-- donde esta la instancia del SQL Server funciona sin inconvenientes



-- Otra forma de hacerlo sin elevar privilegios
create credential ##xp_cmdshell_proxy_account## 
with 
	identity = N'SqlTotal\JoseMariano', 
	secret = N'Pass1234'

-- Se puede eliminar la credencial 
drop credential ##xp_cmdshell_proxy_account## 
	

create credential ##xp_cmdshell_proxy_account## 
with 
	identity = N'ultraseven\prueba', 
	secret = N'Pass1234'


