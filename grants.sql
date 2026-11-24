-- ПМ.07, вариант 17 «Ремонт компьютерной техники». MariaDB 10, Ubuntu Server 22.04.
-- Выполнять начальным администратором сервера (root), а не пользователем admin.
-- Пароли заменены заглушками: реальные значения в репозиторий не передаются.

CREATE DATABASE IF NOT EXISTS pm07_v17 CHARACTER SET utf8mb4;
CREATE DATABASE IF NOT EXISTS pm07_v17_restore CHARACTER SET utf8mb4;

CREATE USER IF NOT EXISTS 'admin'@'%'    IDENTIFIED BY 'CHG_ADMIN';
CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED BY 'CHG_APP';
CREATE USER IF NOT EXISTS 'readonly'@'%' IDENTIFIED BY 'CHG_READ';

GRANT ALL PRIVILEGES ON pm07_v17.* TO 'admin'@'%';
GRANT ALL PRIVILEGES ON pm07_v17_restore.* TO 'admin'@'%';
GRANT SELECT,INSERT,UPDATE,DELETE ON pm07_v17.* TO 'app_user'@'%';
GRANT SELECT ON pm07_v17.* TO 'readonly'@'%';

-- контроль выдачи прав
SHOW GRANTS FOR 'admin'@'%';
SHOW GRANTS FOR 'app_user'@'%';
SHOW GRANTS FOR 'readonly'@'%';
