#!/bin/bash

echo 'Manage Apache2 virtual host - V1.0
'

# initial setup ---------------------

gSitesEnabled='/etc/apache2/sites-enabled/'
gSitesAvailable='/etc/apache2/sites-available/'
gDefultRootDir='/var/www/'

gAction='create'
gRootDir=''
gDeleteClean=false

# function definitions -----------------

function restartapache2 {
    echo 'Apache2 restarted'
    systemctl restart apache2
}

#last steps before exit
function winddown { #exit code
    exitCode=$1
    # unset the functions
    unset -f printhelp
    unset -f restartapache2
    unset -f createnewconf
    unset -f createvh
    unset -f deletevh
    unset -f winddown

    exit $exitCode
}

function createnewconf { #gDomain, gRootDir
    domain=$1 #gDomain
    rootDir=$2 #gRootDir
    domainFileAvailable=$gSitesAvailable$domain.conf

    if echo "<VirtualHost *:80>
    ServerAdmin webmaster@$domain
    ServerName $domain
    ServerAlias www.$domain
    DocumentRoot $rootDir			
    <Directory $rootDir>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride all
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/${domain}_error.log
    LogLevel error
    CustomLog \${APACHE_LOG_DIR}/${domain}_access.log combined
</VirtualHost>" > $domainFileAvailable
    then
        echo $"New Virtual Host configuration created"
    else
        echo $"There is an ERROR creating $domain file"
        echo 'Stopping the script'
        winddown -1
    fi
}

function createvh { #gDomain, gRootDir
    domain=$1 #gDomain
    rootDir=$2 #gRootDir

    # check if domain already running
    domainFileEnabled=$gSitesEnabled$domain.conf    
    if [ -e $domainFileEnabled ]; then
        echo 'Domain already exists! Try deleting the existing domain first'
        echo 'Stopping the script'
        winddown 1
    fi

    # check if domain already exists and ready to be enable 
    domainFileAvailable=$gSitesAvailable$domain.conf
    if [ -e $domainFileAvailable ]; then
        while true; do
            read -p "Domain config already available! want to keep the existing configaration [Y|n]?" keepCurrDomain
            if [[ "$keepCurrDomain" =~ Y|y|N|n ]]; then 
                break
            else
                echo 'Invalid option'
            fi
        done

        if [[ "$keepCurrDomain" =~ N|n ]]; then 
            echo 'Backup existing configaration'
            mv $domainFileAvailable $domainFileAvailable.$(date +%s).bak
            createnewconf $domain $rootDir
        fi
    else
        createnewconf $domain $rootDir
    fi

    #enable the domain
    a2ensite $domain > /dev/null
    echo 'Site enabled'

    restartapache2

    cat addhost_windows.hlp | more
}

function deletevh { #gDomain
    domain=$1 #gDomain

    # check if domain already running
    domainFileEnabled=$gSitesEnabled$domain.conf    
    if [ -e $domainFileEnabled ]; then
        a2dissite $domain > /dev/null
        echo 'Site disabled'
    else
        echo 'No active Domain'
    fi

    #option to keep the conf file
    domainFileAvailable=$gSitesAvailable$domain.conf
    while true; do
        read -p "Do you want to keep the configuration file [Y|n]?" keepCurrConf
        if [[ "$keepCurrConf" =~ Y|y|N|n ]]; then 
            break
        else
            echo 'Invalid option'
        fi
    done

    if [[ "$keepCurrConf" =~ N|n ]]; then 
        echo 'Removing existing configaration'
        rm $domainFileAvailable
    fi

    restartapache2

    cat addhost_windows.hlp | more
}

# Main ----------------------------------------

if [[ "$1" == -h ]]; then
    cat virtualhost.hlp | more
    winddown 0
fi

#first param is the domain
gDomain=$1
shift

if [[ "$gDomain" == -* ]]; then
    echo 'First parameter needs to be a domain (new or existing)'
    echo 'Error!! Stopping the script'
    winddown -1
fi

if [ "$(whoami)" != 'root' ]; then
	echo $"You have no permission to run $0 as non-root user. Use sudo"
	winddown -1;
fi

while [ "$#" -ne 0 ]; do
    case "$1" in
        -p)
            gRootDir=$2
            shift;;
        -d)
            gAction='delete';;
        -h)
            gAction='help'
            break;;
        *)
            gAction='invalid'
            echo 'Invalid option detected.'
            break;;
    esac
    shift
done

case "$gAction" in
    create)
        createvh $gDomain $gRootDir;;
    delete)
        deletevh $gDomain;;
    help)
        cat virtualhost.hlp | more;;
    invalid|*)
        echo 'Error!! Stopping the script'
        winddown -1;;
esac

winddown 1