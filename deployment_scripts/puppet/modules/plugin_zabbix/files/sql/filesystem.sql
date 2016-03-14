INSERT INTO `regexps` (`regexpid`, `name`, `test_string`) VALUES (1,'File systems for discovery','ext3');
INSERT INTO `expressions` (`expressionid`,`regexpid`,`expression`,`expression_type`,`exp_delimiter`,`case_sensitive`) values (1,1,'^(btrfs|ext2|ext3|ext4|jfs|reiser|xfs|ffs|ufs|jfs|jfs2|vxfs|hfs|ntfs|fat32|zfs)$',3,',',0);
