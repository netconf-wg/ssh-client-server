pyang -p ../ -f tree --tree-print-groupings ../ietf-ssh-client\@*.yang > ietf-ssh-client-tree.txt.tmp
pyang -p ../ -f tree --tree-print-groupings ../ietf-ssh-server\@*.yang > ietf-ssh-server-tree.txt.tmp

fold -w 71 ietf-ssh-client-tree.txt.tmp > ietf-ssh-client-tree.txt
fold -w 71 ietf-ssh-server-tree.txt.tmp > ietf-ssh-server-tree.txt

rm *-tree.txt.tmp
