# ------------------------------------------------------------------------------
# Weblogic plugin
#
# -----------
# Description
# -----------
#
# starts weblogic servers
#
# -------
# Authors
# -------
#
# * Julien Giovaresco <dev@giovaresco.fr> - https://github.com/jgiovaresco
#
# ------------
# Prerequisite
# ------------
#
# require XML::XPath Perl module
#
# ------------------------------------------------------------------------------

# Directory containing domains of Weblogic 10g
W10g_DOM_DIR=/home/bea/user_projects/domains
# Directory containing domains of Weblogic 11g
W11g_DOM_DIR=/home/bea11g/user_projects/domains
# Directory containing domains of Weblogic 12g
W12g_DOM_DIR=/home/bea12/user_projects/domains

# Command in the domain directory used to start weblogic server
COMMAND="./startWebLogic.sh"

# Default debut port
PORT=8000
# Store the selected domain
SELECTED_DOMAIN=
# flag to know if the cache must be destroy before starting
CLEAN=0
# flag to know if debug mode needs to be enable
DEBUG=0
# Arguments to give to the JVM
ARGS="-Djava.security.egd=file:///dev/urandom"

#
# Starts a weblogic server
# $1 the directory containing the domains
#
function wlsstart() {
	DOMAINS_DIR=${1}
	shift

	while [ "${1}" ] ; do
		case ${1} in
			-d|--debug)
				DEBUG=1
				case ${2} in
					-port|-p)
						PORT=${3}
						shift
						shift
						;;
				esac
				shift
				;;
			--jmx)
				ARGS="${ARGS} -Dcom.sun.management.jmxremote"
				;;
			-u|--usage|-h|--help)
				echo "--------------------------------------------------------"
				echo "Usage : ${0} [-d [-port <debug port>]] [-jmx] [-c] <domain name>"
				echo "--------------------------------------------------------"
				exit 0;
				;;
			-c|--clean)
				CLEAN=1
				shift
				;;
			*)
				SELECTED_DOMAIN=${1}
				shift
				;;
		esac
	done

	if [ -z ${SELECTED_DOMAIN} ]
	then
		selectDomains ${DOMAINS_DIR}
	fi

	startWeblogic ${DOMAINS_DIR} ${SELECTED_DOMAIN} ${CLEAN} ${DEBUG} ${PORT}
}

# Show all domains available
function printDomains()
{
	for DOMAIN_NAME in $(find ${1} -maxdepth 1 -printf %f\\n | sort)
	do
	if [ -d "${1}/${DOMAIN_NAME}" ] ; then
		echo " ${DOMAIN_NAME}"
	fi
	done

}

# Show all domains available to select one
function selectDomains()
{
	# Show all domains available
	DOMAINS=()
	i=1
	for DOMAIN_NAME in $(find ${1} -maxdepth 1 -printf %f\\n | sort)
	do
		if [ -d "${1}/${DOMAIN_NAME}" ] ; then
			DOMAINS+=${DOMAIN_NAME}
			echo "  ${i}: ${DOMAIN_NAME}"
			((i++))
		fi
	done
	read i
	SELECTED_DOMAIN=${DOMAINS[${i}]}
}

#
# $1 The directory containing domains
# $2 The domain name to start
# $3 The clean flag : if its value is 1, cache files are removed
# $4 The debug flag : if its value is 1, debug port is open
# $5 The debug port
function startWeblogic()
{
	DEBUG=
	if [ -d "${1}/${2}" ] ; then
		case ${3} in
			1)
				SERVER_NAME=`xpath -q -e "/domain/server/name/text()" ${1}/${2}/config/config.xml`
				# Remove cache from server directory
				rm -rf ${1}/${2}/logs
				rm -rf ${1}/${2}/log
				rm -rf ${1}/${2}/servers/${SERVER_NAME}/cache
				rm -rf ${1}/${2}/servers/${SERVER_NAME}/data
				rm -rf ${1}/${2}/servers/${SERVER_NAME}/logs
				rm -rf ${1}/${2}/servers/${SERVER_NAME}/stage
				rm -rf ${1}/${2}/servers/${SERVER_NAME}/tmp
			;;
	  	esac
		case ${4} in
			1)
				DEBUG="-Xdebug -Xrunjdwp:transport=dt_socket,address=${5},server=y,suspend=n"
			;;
	  	esac

		# Launch Weblogic Server
		echo ${1}/${2}
		cd ${1}/${2}
		chmod +x *.sh
		pwd
		${COMMAND} ${ARGS} ${DEBUG}
	else
		echo "Domain ${2} does not exist!"
		exit 1
	fi

}

function listWls10gCompletions {
     reply=(
        -d -p -c
        --debug --port --clean --jmx
        `printDomains ${W10g_DOM_DIR}`
    );
}
function listWls11gCompletions {
     reply=(
        -d -p -c
        --debug --port --clean --jmx
        `printDomains ${W11g_DOM_DIR}`
    );
}
function listWls12gCompletions {
     reply=(
        -d -p -c
        --debug --port --clean --jmx
        `printDomains ${W12g_DOM_DIR}`
    );
}

function wls10g()
{
	wlsstart ${W10g_DOM_DIR} "$@"
}
function wls11g()
{
	wlsstart ${W11g_DOM_DIR} "$@"
}
function wls12g()
{
	wlsstart ${W12g_DOM_DIR} "$@"
}

compctl -K listWls10gCompletions wls10g
compctl -K listWls11gCompletions wls11g
compctl -K listWls12gCompletions wls12g
