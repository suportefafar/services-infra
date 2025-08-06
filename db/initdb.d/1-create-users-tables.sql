-- Create a dedicated user for your applications
CREATE USER 'mysql_user'@'%' IDENTIFIED BY 'mysql_password';

-- Create databases with appropriate character set and collation
CREATE DATABASE IF NOT EXISTS `institutional`
CHARACTER SET 'utf8mb4'
COLLATE 'utf8mb4_unicode_ci';

CREATE DATABASE IF NOT EXISTS `intranet`
CHARACTER SET 'utf8mb4'
COLLATE 'utf8mb4_unicode_ci';

CREATE DATABASE IF NOT EXISTS `escuta`
CHARACTER SET 'utf8mb4'
COLLATE 'utf8mb4_unicode_ci';

-- Grant privileges to the user on specific databases
-- This is more secure than granting ALL PRIVILEGES on *.*
GRANT ALL PRIVILEGES ON `institutional`.* TO 'mysql_user'@'%';
GRANT ALL PRIVILEGES ON `intranet`.* TO 'mysql_user'@'%';
GRANT ALL PRIVILEGES ON `escuta`.* TO 'mysql_user'@'%';

-- Reload the grant tables to ensure the new privileges are active
FLUSH PRIVILEGES;