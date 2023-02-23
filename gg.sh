

##################################################################
###### Ask for URL (if none, generate one) #######################
##################################################################
clear; sleep .1; echo -e " \t\v --  Wordpress Installer\v\v"
read -p "    ${pink}--${normal} ${blue}Base url: like: -- ${normal}myaddress.net -- ${blue}(leave as is if unsure):${white} " userurl ;
if [[ -z "$userurl" ]]; then
userurl="wordpress$(date +%d%m%y%S)" ;
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

sleep 0.1;echo
sleep 0.1;echo "    ${cyan}--${normal} OK ${pink}--${normal} $userurl "
sleep 0.1;echo
sleep 0.1;echo
# read -p "    ${yellow}--${normal} ${blue}New directory: like: ${pink}--${normal} ${white}new-wp-site ${pink}--${normal} ${blue}(leave empty if unsure):${white} " userdir
sleep 0.1;echo
sleep 0.1;echo
sleep 0.1;echo "    ${darkcyan}--${normal} OK ${pink}--${normal}"


install_dir="/var/www/${userurl}"

read -p "    ${red}--${normal}  Change site directory? [y/N] " yn; 
if [ "$yn" != "${yn#[Yy]}" ];
then echo "    ${pink}--${normal}  Yes - OK";

read -ep "    ${blue}--${normal}  Change directory: --> " -i "${install_dir}" install_dir
install_dir="${install_dir}/${userurl}"
echo "    ${pink}--${normal}  OK"
else
echo "    ${white}--${normal}  NO - OK";
fi
mv -n ${install_dir} ${install_dir}_backup 2>/dev/null;
sleep 0.2;echo "    ${pink}--${normal} Creating folders... "
sleep 0.2;echo "    ${pink}--${normal} OK                  "
sleep 0.2;echo "    ${pink}--${normal} Web directory: ${install_dir}"
mkdir -p -m 0775 ${install_dir} ;
sleep 0.1 ;
chown www-data: ${install_dir} -R ;

apt install -qq -y lynx ;
sleep 0.1;echo ${gray}
echo "    -- OK - Moving on... ";

sleep 0.1;echo "$darkgray  ####################-${bold}${normal}nginx-site-config${darkgray}-################################ "
sleep 0.1;echo "
server {
listen 80 default_server;
listen [::]:80 default_server;
listen 443 ssl default_server;
listen [::]:443 ssl default_server;
include snippets/snakeoil.conf;
root ${install_dir};
index index.php index.html index.htm;
server_name ${userurl};
location / {
try_files \$uri \$uri/ =404;
}
}
" > /etc/nginx/sites-available/${userurl} ;
ln /etc/nginx/sites-available/${userurl} /etc/nginx/sites-enabled/${userurl}
sleep 0.2;echo 
#rm /etc/nginx/sites-enabled/*
service mariadb restart;
echo
sleep ;echo 
sleep 0.02;echo "$yellow  ##########################################################################"
sleep 0.02;echo "$yellow  ###########${normal}-Generating-MySql-credentials-${yellow}#################################"
sleep 0.02;echo "$yellow  ##########################################################################"

sleep 0.02;echo;
sleep 0.02;echo;
sleep 0.02;echo -e "${blue}         ####${normal}\033[5m RaNdoMiZing\033[0m ${pink}####"
db_name="wp`date +%N`";
sleep 0.2;echo ;
db_user="`date +%B%N`";
sleep 0.2;echo ;
db_password=`date|md5sum|cut -c 1-14`;
sleep 0.5;echo ; echo "        $bold $purple done  ✓ $normal"
sleep 0.1;echo "       ${pink}--${normal} $blue your credentials $normal"
sleep 0.1;echo "
    $green ###################################### ${normal}
    $darkblue db_name:$gray $db_name            
    $darkblue db_user:$gray $db_user            
    $darkblue db_password:$gray $db_password    
    $green ###################################### ${normal}


"
mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE $db_name;
CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_password';
GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

service mariadb restart;
cd ${install_dir}
echo " ${darkgray} ${darkgray}";
wget "http://wordpress.org/latest.tar.gz";
chown www-data: ./ -R; 
chmod 775 ./ -R
echo ; sleep 0.1 ; 
tar -xzf latest.tar.gz --overwrite --strip-components=1;
echo ; sleep 0.1 ;
chown www-data: ./ -R
chmod 775 ./ -R
chown www-data: ./ -R
echo "$green             ###################################################"
echo "$green             ####${normal} Creating WP-config and set DB credentials${green} #### "
mv ${install_dir}/wp-config-sample.php ${install_dir}/wp-config.php ; sleep 0.2 ;
sed -i "s/database_name_here/$db_name/g" ${install_dir}/wp-config.php ; sleep 0.2 ;
sed -i "s/username_here/$db_user/g" ${install_dir}/wp-config.php ; sleep 0.2 ;
sed -i "s/password_here/$db_password/g" ${install_dir}/wp-config.php ; sleep 0.2 ;
echo "$green             ###################################################${normal}"
mv -n ${install_dir}/index.html ${install_dir}/index.html_backup 2>/dev/null;
##### Set WP Salts
grep -A50 'table_prefix' $install_dir/wp-config.php > /tmp/wp-tmp-config
sed -i '/**#@/,/$p/d' $install_dir/wp-config.php
lynx --dump -width 200 https://api.wordpress.org/secret-key/1.1/salt/ >> $install_dir/wp-config.php
cat /tmp/wp-tmp-config >> $install_dir/wp-config.php && rm /tmp/wp-tmp-config -f
#############
echo "
@ini_set( 'upload_max_filesize' , '128M' );
@ini_set( 'post_max_size', '132M');
@ini_set( 'memory_limit', '256M' );
@ini_set( 'max_execution_time', '300' );
@ini_set( 'max_input_time', '300' );
" >> $install_dir/wp-config.php
echo "Removing default WordPress themes..."
rm -rf wp-content/themes/twentytwentytwo
rm -rf wp-content/themes/twentytwentythree
echo "Removing default WordPress plugins..."
cd ${install_dir}/wp-content/plugins
rm -rf akismet
rm -rf hello.php
echo "Fetching simple-history plugin...";
wget https://downloads.wordpress.org/plugin/simple-history.zip;
unzip -q simple-history.zip;
wget https://downloads.wordpress.org/plugin/filester.zip;
unzip -q filester.zip
wget https://downloads.wordpress.org/plugin/webp-express.zip;
unzip -q webp-express.zip
wget https://downloads.wordpress.org/plugin/really-simple-ssl.zip;
unzip -q really-simple-ssl.zip
cd ${install_dir}/wp-content/themes
wget -O blank1.zip https://github.com/0smik/blank1/archive/refs/heads/main.zip
unzip -q blank1.zip
mv blank1-main blank1

echo "Defining the default theme...";
echo "
define( 'WP_DEFAULT_THEME', 'blank1' );" >> ${install_dir}/wp-config.php
echo >> /home/.$userurl-$userdir-LOGIN.txt MYSQL --- db-name-db-user:  $db_name  ------  db-pw:  $db_password  -----
echo " -- Database credentials saved in: ----------------------"
echo " -- /home/.$userurl-$userdir-LOGIN.txt (Hidden folder).--"
systemctl restart nginx
echo "    ----------------------------------------------------------   "
tput setaf 7 ; echo "              - - -> http://$userurl$userdir <- - -       "
echo -n "         - - - > NETWORK-IP: http://"; hostname -I
echo -n "    - - - > PUBLIC-IP; http://"; dig +short myip.opendns.com @resolver1.opendns.com