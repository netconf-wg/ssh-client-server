pyang -p ../ -f tree --tree-line-length 69 --tree-print-groupings ../ietf-ssh-client\@*.yang > ietf-ssh-client-tree.txt
pyang -p ../ -f tree --tree-line-length 69 --tree-print-groupings ../ietf-ssh-server\@*.yang > ietf-ssh-server-tree.txt
pyang -p ../ -f tree --tree-line-length 69 --tree-print-groupings ../ietf-ssh-common\@*.yang > ietf-ssh-common-tree.txt

pyang -p ../ -f tree --tree-line-length 69 --tree-print-groupings --tree-no-expand-uses ../ietf-ssh-client\@*.yang > ietf-ssh-client-tree-no-expand.txt
pyang -p ../ -f tree --tree-line-length 69 --tree-print-groupings --tree-no-expand-uses ../ietf-ssh-server\@*.yang > ietf-ssh-server-tree-no-expand.txt
