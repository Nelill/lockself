-- Create user www. It used by the application to read the db.
-- IP has to be modified with the IP/Range of the application servers.
-- PASSWORD has to be modified with the password you want to give to this user.
CREATE USER 'admin_iph'@'lockself_lockself-api-3_1' IDENTIFIED BY '123456789';

-- Grant rights to the www user.
-- Replace IP with the IP/Range of the application servers.
GRANT SELECT,INSERT,UPDATE,DELETE ON lockself.* TO 'admin_iph'@'lockself_lockself-api-3_1';

-- Create user lockself_migration. It used by the application to migrate the db.
-- IP has to be modified with the IP/Range of the application servers.
-- PASSWORD has to be modified with the password you want to give to this user.
CREATE USER 'lockself_migration'@'lockself_lockself-api-3_1' IDENTIFIED BY '123456';

-- Grant rights to the lockself_migration user.
-- Replace IP with the IP/Range of the application servers.
GRANT SELECT,INSERT,UPDATE,DELETE,ALTER,CREATE,DROP,INDEX ON lockself.* TO 'lockself_migration'@'lockself_lockself-api-3_1';