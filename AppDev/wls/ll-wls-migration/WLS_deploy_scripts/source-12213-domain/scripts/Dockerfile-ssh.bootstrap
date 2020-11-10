for key in rsa dsa ecdsa; do
        if [ ! -e /etc/ssh/ssh_host_${key}_key ]; then
                ssh-keygen -t ${key} -f /etc/ssh/ssh_host_${key}_key
        fi      
done            

echo "root:hackme" | chpasswd && /usr/sbin/sshd -D
