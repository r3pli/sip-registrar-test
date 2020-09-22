#!/bin/bash

set -e
set -u

_check_requirements() {
  if ! command -v sipp &>/dev/null; then
    echo "SIPp could not be found. Please install before using this script."
    return 1
  fi

  return 0
}

_read_known_registrars() {
  local _known_registrars_file
  local _registrars
  local _line

  _registrars=""
  _known_registrars_file="${PWD}/known_registrars"

  while IFS= read -r _line; do
    if [[ $_line != \#* ]]; then
      _registrars="${_registrars}${_line}, "
    fi
  done <"$_known_registrars_file"

  echo "${_registrars%,}"

  return 0
}

_initiate_test() {
  local _line
  local _details
  local _second_ip
  local _ipv4

  _line="${3}"
  _ipv4=false
  _second_ip=false

  IFS=' ' read -r -a _details <<<"$_line"

  if [[ ${_details[1]} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    _ipv4=true
  fi

  if [[ -v "_details[2]" ]]; then
    _second_ip=true
  fi

  if sipp ${_details[0]} -aa -d 30 -r 1 -rp 1s -sf sipp_scenario.xml -l 1 -m 1 -ap ${2} -s ${1} &>/dev/null; then
    if [ "$_ipv4" = true ]; then
      if [ "$_second_ip" = true ]; then
        if [ ${#_details[2]} -lt 24 ]; then
          echo -e "${_details[0]}\t${_details[1]}\t\t\t${_details[2]}\t\t\e[92mSuccess\e[39m"
        else
          echo -e "${_details[0]}\t${_details[1]}\t\t\t${_details[2]}\t\e[92mSuccess\e[39m"
        fi
      else
        echo -e "${_details[0]}\t${_details[1]}\t\t\tN/A\t\t\t\t\e[92mSuccess\e[39m"
      fi
    else
      if [ ${#_details[1]} -lt 24 ]; then
        echo -e "${_details[0]}\t${_details[1]}\t\tN/A\t\t\t\t\e[92mSuccess\e[39m"
      else
        echo -e "${_details[0]}\t${_details[1]}\tN/A\t\t\t\t\e[92mSuccess\e[39m"
      fi
    fi
  else
    if [ "$_ipv4" = true ]; then
      if [ "$_second_ip" = true ]; then
        if [ ${#_details[2]} -lt 24 ]; then
          echo -e "${_details[0]}\t${_details[1]}\t\t\t${_details[2]}\t\t\e[91mFailed\e[39m"
        else
          echo -e "${_details[0]}\t${_details[1]}\t\t\t${_details[2]}\t\e[91mFailed\e[39m"
        fi
      else
        echo -e "${_details[0]}\t${_details[1]}\t\t\tN/A\t\t\t\t\e[91mFailed\e[39m"
      fi
    else
      if [ ${#_details[1]} -lt 24 ]; then
        echo -e "${_details[0]}\t${_details[1]}\t\tN/A\t\t\t\t\e[91mFailed\e[39m"
      else
        echo -e "${_details[0]}\t${_details[1]}\tN/A\t\t\t\t\e[91mFailed\e[39m"
      fi
    fi
  fi

  return 0
}

_test_registrars() {
  local _registrars
  local _registrar_lines
  local _line

  _registrars="${3}"
  IFS=',' read -r -a _registrar_lines <<<"$_registrars"

  echo -e "REGISTRAR\t\t\tIP\t\t\t\t2. IP\t\t\t\tSTATUS"
  for _line in "${_registrar_lines[@]}"; do
    if [[ ! -z "${_line// /}" ]]; then
      _initiate_test "${1}" "${2}" "${_line}"
    fi
  done

  return 0
}

_main() {
  local _registrars
  local _user
  local _password

  _password=""

  if test ${#} -eq 0; then
    echo "Please provider SIP username."
    return 0
  fi

  while getopts ":u:p" opt; do
    case ${opt} in
    u)
      _user=$OPTARG
      ;;
    p)
      echo -n "Please enter your SIP password:"
      read -s _password
      echo ""
      ;;
    \?)
      echo "Invalid option: $OPTARG" 1>&2
      return 1
      ;;
    :)
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      return 1
      ;;
    esac
  done
  shift $((OPTIND - 1))

  _check_requirements
  _registrars="$(_read_known_registrars)"
  _test_registrars "${_user}" "${_password}" "${_registrars}"

  return 0
}

_main "${@}"
