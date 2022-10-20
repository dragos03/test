#!/bin/bash

#this script fixes the ownership and permissions for a cPanel account

#reading the cPanel user
read -p "Please enter the cPanel username: " user
group=$user

#test if the cPanel user exists

#if not, prompt again

#fixing ownership
chown -R $user:$group /home/$user/public_html
chown $user:nobody /home/$user/public_html

#fixing permissions
find /home/$user/public_html/* \( -type d -exec chmod 755 {} \; \) , \( -type f -exec chmod 644 {} \; \);
